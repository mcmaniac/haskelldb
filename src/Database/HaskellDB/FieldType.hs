-----------------------------------------------------------
-- |
-- Module      :  FieldType
-- Copyright   :  HWT Group (c) 2003, dp03-7@mdstud.chalmers.se
-- License     :  BSD-style
-- 
-- Maintainer  :  dp03-7@mdstud.chalmers.se
-- Stability   :  experimental
-- Portability :  portable
--
-- Defines the types of database columns, and functions
-- for converting these between HSQL and internal formats
--
-----------------------------------------------------------
module Database.HaskellDB.FieldType 
    (FieldDef, FieldType(..), mkCalendarTime) where

import Data.Dynamic
import System.Time

import Database.HaskellDB.BoundedString

-- | The type and @nullable@ flag of a database column
type FieldDef = (FieldType, Bool)

-- | A database column type
data FieldType = 
    StringT
    | IntT 
    | IntegerT
    | DoubleT
    | BoolT
    | CalendarTimeT
    | BStrT Int
    deriving (Eq)

instance Show FieldType where
    show StringT = "String"
    show IntT = "Int"
    show IntegerT = "Integer"
    show DoubleT = "Double"
    show BoolT = "Bool"
    show CalendarTimeT = "CalendarTime"
    show (BStrT a) = "BStr" ++ show a

-- | Creates a CalendarTime from a ClockTime
--   This loses the time zone and assumes UTC. :(
--   A probable fix could be to make DbDirect aware of which time zone the
--   server is in and handle it here
--   This is just a function synonym for now
mkCalendarTime :: ClockTime -> CalendarTime
mkCalendarTime = toUTCTime

instance Typeable CalendarTime where -- not available in standard libraries
    typeOf _ = mkAppTy (mkTyCon "System.Time.CalendarTime") []

instance Typeable (BoundedString n) where
    typeOf _ = mkAppTy (mkTyCon "Database.HaskellDB.BoundedString") []