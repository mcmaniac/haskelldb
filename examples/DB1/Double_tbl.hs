{-# LANGUAGE EmptyDataDecls, TypeSynonymInstances #-}
{-# OPTIONS_GHC -fcontext-stack44 #-}
---------------------------------------------------------------------------
-- Generated by DB/Direct
---------------------------------------------------------------------------
module DB1.Double_tbl where

import Database.HaskellDB.DBLayout

---------------------------------------------------------------------------
-- Table type
---------------------------------------------------------------------------

type Double_tbl =
    (RecCons F01 (Expr (Maybe Double))
     (RecCons F02 (Expr Double)
      (RecCons F03 (Expr (Maybe Double))
       (RecCons F04 (Expr Double) RecNil))))

---------------------------------------------------------------------------
-- Table
---------------------------------------------------------------------------
double_tbl :: Table Double_tbl
double_tbl = baseTable "double_tbl" $
             hdbMakeEntry F01 #
             hdbMakeEntry F02 #
             hdbMakeEntry F03 #
             hdbMakeEntry F04

---------------------------------------------------------------------------
-- Fields
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- F01 Field
---------------------------------------------------------------------------

data F01 = F01

instance FieldTag F01 where fieldName _ = "f01"

f01 :: Attr F01 (Maybe Double)
f01 = mkAttr F01

---------------------------------------------------------------------------
-- F02 Field
---------------------------------------------------------------------------

data F02 = F02

instance FieldTag F02 where fieldName _ = "f02"

f02 :: Attr F02 Double
f02 = mkAttr F02

---------------------------------------------------------------------------
-- F03 Field
---------------------------------------------------------------------------

data F03 = F03

instance FieldTag F03 where fieldName _ = "f03"

f03 :: Attr F03 (Maybe Double)
f03 = mkAttr F03

---------------------------------------------------------------------------
-- F04 Field
---------------------------------------------------------------------------

data F04 = F04

instance FieldTag F04 where fieldName _ = "f04"

f04 :: Attr F04 Double
f04 = mkAttr F04
