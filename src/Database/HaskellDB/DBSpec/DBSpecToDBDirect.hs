-----------------------------------------------------------
-- |
-- Module      :  DBSpecToDBDirect
-- Copyright   :  HWT Group (c) 2004, dp03-7@mdstud.chalmers.se
-- License     :  BSD-style
-- 
-- Maintainer  :  dp03-7@mdstud.chalmers.se
-- Stability   :  experimental
-- Portability :  non-portable
--
-- Converts a DBSpec-generated database to a set of
-- (FilePath,Doc), that can be used to generate definition 
-- files usable in HaskellDB (the generation itself is done 
-- in DBDirect)
-----------------------------------------------------------
module Database.HaskellDB.DBSpec.DBSpecToDBDirect
    (specToHDB) 
    where
import Database.HaskellDB.BoundedString
import Database.HaskellDB.FieldType

import Database.HaskellDB
import Database.HaskellDB.PrimQuery
import Database.HaskellDB.DBSpec.DBInfo

import Database.HaskellDB.DBSpec.PPHelpers

import Text.PrettyPrint.HughesPJ

-- | Common header for all files
header :: Doc
header = ppComment ["Generated by DB/Direct"]

-- | Adds an appropriate -fcontext-stackXX OPTIONS pragma at the top
--   of the generated file. Not currently in use since -fcontext-stackXX
--   apparently cannot be used in that context.
contextStackPragma :: DBInfo -> Doc
contextStackPragma dbi
    = text "{-# OPTIONS -fglasgow-exts -fcontext-stack" 
      <> text (show (40 + detNum dbi)) <+> text "#-}"
    where
    detNum (DBInfo {tbls=t}) = maximum (map detOnTbl t)
    detOnTbl (TInfo {cols=c}) = length c

-- | All imports generated files have dependencies on. Nowadays, this 
--   should only be Database.HaskellDB.DBLayout
imports :: Doc
imports = text "import Database.HaskellDB.DBLayout"

-- | Converts a database specification to a "finished" set of files
specToHDB :: DBInfo -> [(FilePath,Doc)]
specToHDB dbinfo = genDocs (constructNonClashingDBInfo dbinfo)

-- | Does the actual conversion work
genDocs :: DBInfo -> [(FilePath,Doc)]
genDocs dbinfo 
    = ("./" ++ ((moduleName . dbname) dbinfo) ++ ".hs",
--       contextStackPragma dbinfo $$
       header
       $$ text "module" <+> text ((moduleName . dbname) dbinfo) 
       <+> text "where"
       <> newline
       $$ imports
       <> newline
       $$ vcat (map (text . (("import qualified " ++ 
			      ((moduleName . dbname) dbinfo) ++ ".") ++)) 
		tbnames)
       <> newline
       $$ dbInfoToDoc dbinfo)
        : map (tInfoToModule ((moduleName . dbname) dbinfo)) (tbls dbinfo)
    where
    tbnames = map (moduleName . tname) (tbls dbinfo)
      
-- | Makes a module from a TInfo
tInfoToModule :: String -- ^ The name of our main module
	      -> TInfo -> (FilePath,Doc)
tInfoToModule dbname tinfo@TInfo{tname=name,cols=col}
    = ("./" ++ dbname ++ "/" ++ (moduleName name) ++ ".hs",
       header
       $$ text "module" <+> 
       text ((moduleName dbname) ++ "." ++ (moduleName name)) <+> 
       text "where"
       <> newline
       $$ imports
       <> newline
       $$ ppComment ["Table"]
       $$ ppTable tinfo       
       $$ ppComment ["Fields"]
       $$ vcat (map ppField (columnNamesTypes tinfo)))

-- | Pretty prints a TableInfo
ppTable :: TInfo -> Doc
ppTable (TInfo tiName tiColumns) =  
    hang (text (identifier tiName) <+> text "::" <+> text "Table") 4 
	 (parens (ppColumns tiColumns)
	 <>  newline)
    $$  
    text (identifier tiName) <+> text "=" <+> 
    hang (text "baseTable" <+> 
	  doubleQuotes (text (checkChars $ checkLower tiName)) <+> 
	  text "$") 0
	     (vcat $ punctuate (text " #") (map ppColumnValue tiColumns))
	     <>  newline

-- | Pretty prints a list of ColumnInfo
ppColumns :: [CInfo] -> Doc
ppColumns []      = text ""
ppColumns [c]     = parens (ppColumnType c <+> text "RecNil")
ppColumns (c:cs)  = parens (ppColumnType c $$ ppColumns cs)

-- | Pretty prints the type field in a ColumnInfo	
ppColumnType :: CInfo -> Doc 
ppColumnType (CInfo ciName (ciType,ciAllowNull))
	=   text "RecCons" <+> 
	    ((text $ toType ciName) <+> parens (text "Expr"
	    <+> (if (ciAllowNull)
	      then parens (text "Maybe" <+> text (pshow ciType))
	      else text (pshow ciType)
	    )))

-- | Pretty prints the value field in a ColumnInfo
ppColumnValue :: CInfo -> Doc 
ppColumnValue (CInfo ciName _)
	=   text "hdbMakeEntry" <+> text (toType ciName)

-- | Pretty prints Field definitions
ppField :: (String,String) -> Doc
ppField (name,typeof) = 
    ppComment [toType name ++ " Field"]
    <> newline $$
    text "data" <+> bname <+> equals <+> bname -- <+> text "deriving Show"
    <> newline $$
    hang (text "instance FieldTag" <+> bname <+> text "where") 4 
         (text "fieldName _" <+> equals <+> doubleQuotes 
	         (text (checkChars $ checkLower name)))
    <> newline $$
    
    iname <+> text "::" <+> text "Attr" <+> bname <+> text typeof
    $$ 
    iname <+> equals <+> text "mkAttr" <+> bname
    <> newline
	where
	bname = text (toType name)
	iname = text (identifier name)

-- | Extracts all the column names from a TableInfo
columnNames :: TInfo -> [String]
columnNames table = map cname (cols table)

-- | Extracts all the column types from a TableInfo
columnTypes :: TInfo -> [String]
columnTypes table = 
    [if b then ("(Maybe " ++ t ++ ")") else t | (t,b) <- zippedlist]
    where
    zippedlist = zip typelist null_list
    typelist  = map (pshow . fst . descr) (cols table)
    null_list = map (snd . descr) (cols table)

-- | Combines the results of columnNames and columnTypes
columnNamesTypes :: TInfo -> [(String,String)]
columnNamesTypes table@(TInfo tname fields) 
    = zip (columnNames table) (columnTypes table)
