{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Text.Read
import Control.Applicative
import System.Environment
import Data.Maybe
import Data.List
import Data.Function
import Data.Char (isSpace)
import qualified Data.ByteString.Lazy as BL
import Data.Csv
import qualified Data.Vector as V

data Expense = Expense
  { card :: !String
  , amount :: !Double
  } deriving (Show, Eq)

instance Ord Expense where
  (Expense c1 _) `compare` (Expense c2 _) = c1 `compare` c2

instance Semigroup Expense where
  (Expense c a1) <> (Expense _ a2) = (Expense c (a1 + a2))

instance Monoid Expense where
  mempty = Expense "" 0.0

type Row = V.Vector String

trim :: String -> String
trim = dropWhileEnd isSpace . dropWhile isSpace

readDoubleWithComma :: String -> Maybe Double
readDoubleWithComma = readMaybe . sanitize
  where
    sanitize = map (\c -> if c == ',' then '.' else c)

cardFromVector :: Row -> String
cardFromVector v = case (V.!?) v 5 of
  Just "" -> "Unknown" -- Expense not from card payment is marked as empty string
  Just a -> trim a
  _ -> "Unknown"

amountFromVector :: Row -> Maybe Double
amountFromVector v = (V.!?) v 2 >>= readDoubleWithComma

getExpense :: Row -> Maybe Expense
getExpense v = Expense
  <$> Just (cardFromVector v)
  <*> amountFromVector v

groupAndSumCardExpenses :: [Row] -> [Expense]
groupAndSumCardExpenses =
  map mconcat
    . groupBy ((==) `on` card)
    . sort
    . mapMaybe getExpense

main :: IO ()
main = do
  args <- getArgs
  csvData <- BL.readFile $ head args
  case decode NoHeader csvData of
    Left err -> putStrLn $ "Error: " ++ err
    Right (rows :: V.Vector Row) -> putStrLn $ show $ groupAndSumCardExpenses (V.toList rows)
  return ()
