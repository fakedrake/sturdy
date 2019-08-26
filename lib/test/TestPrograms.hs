{-# LANGUAGE Arrows #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE DeriveGeneric #-}
module TestPrograms where

import           Prelude hiding (lookup,Bounded,Bool(..),fail)

import           Control.Arrow
import           Control.Arrow.Fix as F
import           Control.Arrow.Order hiding (bottom)

import           Data.Boolean(Logic(..))
import           Data.Abstract.Boolean(Bool)
import           Data.Abstract.InfiniteNumbers
import           Data.Abstract.Interval (Interval)
import qualified Data.Abstract.Interval as I

import           Data.Order
import           Data.Hashable
import           Data.Profunctor

import           GHC.Generics

fib :: Arr IV IV
fib = fix $ \f ->
  ifLowerThan 0
    (proc _ -> returnA -< I.Interval 0 0)
    (ifLowerThan 1 (proc _ -> returnA -< I.Interval 1 1)
                   (proc n -> do
                      x <- f -< n - I.Interval 1 1
                      y <- f -< n - I.Interval 2 2
                      returnA -< x + y))

fact :: Arr IV IV
fact = fix $ \f ->
  ifLowerThan 1 (proc _ -> returnA -< iv 1 1)
                (proc n -> do x <- f -< (n - iv 1 1)
                              returnA -< n * x)

ackermann :: Arr (IV,IV) IV
ackermann = fix $ \f -> proc (m,n) ->
  ifLowerThan 0
    (proc _ -> returnA -< n + iv 1 1)
    (proc m' -> ifLowerThan 0
                  (proc _ -> f -< (m'- iv 1 1, iv 1 1))
                  (proc n' -> do x <- f -< (m,n'-iv 1 1)
                                 f -< (m'- iv 1 1, x)) -<< n)
    -<< m

evenOdd :: Arr (EvenOdd,IV) Bool
evenOdd = fix $ \f -> proc (e,x) -> case e of
  Even -> ifLowerThan 0 (proc _ -> returnA -< true)
                        (ifLowerThan 1 (proc _ -> returnA -< false)
                                       (proc x -> f -< (Odd,x-I.Interval 1 1))) -< x
  Odd -> ifLowerThan 0 (proc _ -> returnA -< false)
                        (ifLowerThan 1 (proc _ -> returnA -< true)
                                       (proc x -> f -< (Even,x-I.Interval 1 1))) -< x


diverge :: Arr Int IV
diverge = fix $ \f -> proc n -> case n of
  0 -> f -< 0
  _ -> f -< (n-1)

type Arr x y = forall c. (ArrowChoice c, Profunctor c, ArrowApply c, ArrowComplete y c, ArrowFix (c x y)) => c x y
type IV = Interval (InfiniteNumber Int)

iv :: InfiniteNumber Int -> InfiniteNumber Int -> IV
iv n m = I.Interval n m

ifLowerThan :: (Num n, Ord n, ArrowChoice c, Profunctor c, ArrowComplete x c) => n -> c (Interval n) x -> c (Interval n) x -> c (Interval n) x
ifLowerThan l f g = proc x -> case x of
  I.Interval m n
    | n <= l -> f -< x
    | l < m -> g -< x
    | m <= l && l+1 <= n -> (f -< I.Interval m l) <⊔> (g -< I.Interval (l+1) n)
    | otherwise -> f -< I.Interval m l

data EvenOdd = Even | Odd deriving (Eq,Generic,Show)
instance Hashable EvenOdd
instance PreOrd EvenOdd where
  e1 ⊑ e2 = e1 == e2
