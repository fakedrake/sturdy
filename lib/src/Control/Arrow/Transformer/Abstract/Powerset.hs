{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE Arrows #-}
module Control.Arrow.Transformer.Abstract.Powerset(PowT,runPowT) where

import           Prelude hiding (id,(.),lookup,fail)

import           Control.Arrow
import           Control.Arrow.Order
import           Control.Arrow.Environment as Env
import           Control.Arrow.Fail
import           Control.Arrow.Trans
import           Control.Arrow.Reader
import           Control.Arrow.State
import           Control.Arrow.Fix
import           Control.Arrow.Const
import           Control.Arrow.Store
import           Control.Arrow.Except
import           Control.Arrow.Transformer.Kleisli
import           Control.Category

import qualified Data.Abstract.Powerset as A
import           Data.Identifiable
import           Data.Profunctor
import           Data.Profunctor.Unsafe((.#))
import           Data.Coerce

-- | Computation that produces a set of results.
newtype PowT c x y = PowT (KleisliT A.Pow c x y)
  deriving (Profunctor, Category, Arrow, ArrowChoice, ArrowTrans, ArrowLift, ArrowRun, 
            ArrowConst r, ArrowState s, ArrowReader r,
            ArrowEnv var val, ArrowClosure var val env, ArrowStore a b,
            ArrowFail e', ArrowExcept e')

runPowT :: PowT c x y -> c x (A.Pow y)
runPowT = coerce
{-# INLINE runPowT #-}

instance (ArrowChoice c, Profunctor c, ArrowApply c) => ArrowApply (PowT c) where
  app = lift (app .# first coerce)

type instance Fix x y (PowT c) = PowT (Fix (Dom PowT x y) (Cod PowT x y) c)
instance (Identifiable y, ArrowChoice c, ArrowFix x (A.Pow y) c) => ArrowFix x y (PowT c) where
  fix f = lift $ rmap A.dedup (fix (coerce f))

instance (ArrowChoice c, Profunctor c) => ArrowLowerBounded (PowT c) where
  bottom = lift $ arr (\_ -> A.empty)

instance (ArrowChoice c, ArrowComplete c) => ArrowComplete (PowT c) where
  join _ f g = lift $ join A.union (unlift f) (unlift g)
