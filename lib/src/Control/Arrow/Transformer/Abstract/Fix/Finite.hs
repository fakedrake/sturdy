{-# LANGUAGE Arrows #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE UndecidableInstances #-}
module Control.Arrow.Transformer.Abstract.Fix.Finite where

import           Prelude hiding ((.))

import           Data.Coerce
import           Data.Empty
import           Data.HashMap.Lazy (HashMap)
import qualified Data.HashMap.Lazy as M
import           Data.Identifiable
import           Data.Order
import           Data.Profunctor
import           Data.Profunctor.Unsafe

import           Control.Category
import           Control.Arrow
import           Control.Arrow.Order
import           Control.Arrow.Fix
import           Control.Arrow.Trans
import           Control.Arrow.State
import           Control.Arrow.Transformer.State

newtype FiniteT a b c x y = FiniteT (StateT (HashMap a b) c x y)
  deriving (Category,Arrow,ArrowChoice,ArrowTrans,Profunctor)

runFiniteT :: Profunctor c => FiniteT a b c x y -> c x (HashMap a b,y)
runFiniteT (FiniteT f) = lmap (\x -> (empty,x)) (runStateT f)

finite :: (Identifiable a, Arrow c,Profunctor c) => IterationStrategy (FiniteT a b c) a b
finite (FiniteT f) = FiniteT $ proc a -> do
  b <- f -< a
  modify' (\((a,b),m) -> (b,M.insert a b m)) -< (a,b)

instance ArrowRun c => ArrowRun (FiniteT a b c) where
  type Rep (FiniteT a b c) x y = Rep c x (HashMap a b,y)
  run = run . runFiniteT

instance (Profunctor c, Arrow c, Complete y) => ArrowComplete y (FiniteT a b c) where
  FiniteT f <⊔> FiniteT g = FiniteT $ dimap (\x -> (x,x)) (\(y1,y2) -> y1 ⊔ y2) (f *** g)

instance (Profunctor c, ArrowApply c) => ArrowApply (FiniteT a b c) where
  app = FiniteT (app .# first coerce)
