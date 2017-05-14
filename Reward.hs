{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}

-- | This module is for testing purposes only.

module Reward where

import           Data.List       (intersect, nub)
import qualified Data.Map.Strict as M
import qualified Data.Set        as S
import           Universum

----------------------------------------------------------------------------
-- Lib
----------------------------------------------------------------------------

type Time = Integer

type User = Integer
type Users = Set User

data RespResult = RespResult
    { rTauN   :: Time
    , rClocks :: Map User Time
    } deriving Show

-- First argument: total users set. Second argument: subset of the
-- first one. Returns characteristic value.
type ShapleyChar = (Users, Users -> Double)

shapleyCalculate :: ShapleyChar -> User -> Double
shapleyCalculate (allUsers, v) u
    | u `S.notMember` allUsers = error $ "shapleyCalculate user is not in the list: " <> show u
    | otherwise = sum $ map iterFoo iterSets
  where
    n :: (Integral a) => a
    n = fromIntegral $ S.size allUsers
    cast = fromIntegral
    iterFoo :: Users -> Double
    iterFoo ss =
        let m = S.size ss
        in fact m * fact (n - m - 1) / fact n * (v (S.insert u ss) - v ss)
    iterSets = subsets $ S.delete u allUsers

fact :: (Integral a, Num b) => a -> b
fact a | a <= 0 = 1
fact a = fromIntegral a * fromIntegral (fact (a - 1))

subsets :: (Ord a) => Set a -> [Set a]
subsets s = nub $ map S.fromList $ concatMap tails $ inits $ S.toList s


----------------------------------------------------------------------------
-- Test
----------------------------------------------------------------------------

gloveGame :: ShapleyChar
gloveGame = (u, v)
  where
    u = S.fromList [1,2,3]
    v s | s `elem` (map S.fromList $ [[1,3],[2,3]]) = 1
        | s == S.fromList [1,2,3] = 2
        | otherwise = 0

testGlove :: IO ()
testGlove = do
    let sh@(users,v) = gloveGame
    forM_ users $ \u -> putText $ show u <> ": " <> show (shapleyCalculate sh u)

{-
λ> testGlove
1: 0.16666666666666666
2: 0.16666666666666666
3: 0.6666666666666666
-}

----------------------------------------------------------------------------
-- Real tx evaluation
----------------------------------------------------------------------------

shapleyComs :: RespResult -> ShapleyChar
shapleyComs RespResult{..} = (S.fromList $ M.keys rClocks, \u -> sum $ S.map vs u)
  where
    coms x = fromIntegral $ fromMaybe 0 $ M.lookup x rClocks
    vs :: User -> Double
    vs x = let r = coms x / fromIntegral rTauN in min r 1

respResTest = RespResult { rTauN = 10, rClocks = M.fromList [(1,5), (2,3), (3,1)] }

testComs :: IO ()
testComs = do
    let sh@(users,v) = shapleyComs respResTest
    let vals = normalize $ map (shapleyCalculate sh) $ S.toList users
    forM_ ([1..] `zip` vals) print
  where
    normalize l = let m = maximum l in map (/ m) l


data FilterTerm = FilterTerm [Users]

shapleyFilter :: FilterTerm -> ShapleyChar
shapleyFilter (FilterTerm fusers) =
    (mconcat fusers, \u -> fromIntegral $ length $ fusers `intersect` subsets u)

testFilter :: IO ()
testFilter = do
    let filterTerm = FilterTerm $ nub $ map S.fromList [[1], [2], [2,3]]
        sh@(users,v) = shapleyFilter filterTerm
    let vals = normalize $ map (shapleyCalculate sh) $ S.toList users
    forM_ ([1..] `zip` vals) print
  where
    normalize l = let m = sum l in map (/ m) l
