{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE Arrows #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UndecidableInstances #-}
module Control.Arrow.Transformer.Abstract.Completion(CompletionT,runCompletionT) where

import Prelude hiding ((.),id,lookup,fail)

import Control.Arrow
import Control.Arrow.Environment
import Control.Arrow.Except
import Control.Arrow.Fail
import Control.Arrow.Fix
import Control.Arrow.Reader
import Control.Arrow.State
import Control.Arrow.Store
import Control.Arrow.Trans
import Control.Arrow.Const
import Control.Arrow.Order
import Control.Arrow.Transformer.Kleisli
import Control.Category

import Data.Abstract.FreeCompletion

import Data.Profunctor
import Data.Profunctor.Unsafe((.#))
import Data.Coerce

-- | Allows to describe computations over non-completely ordered types.
-- E.g. allows to join a computation of type 'c x [y]'.
newtype CompletionT c x y = CompletionT (KleisliT FreeCompletion c x y) 
  deriving (Profunctor, Category, Arrow, ArrowChoice, ArrowTrans, ArrowLift, ArrowRun, 
            ArrowConst r, ArrowState s, ArrowReader r,
            ArrowEnv var val, ArrowClosure var val env, ArrowStore a b,
            ArrowFail e, ArrowExcept e)

runCompletionT :: CompletionT c x y -> c x (FreeCompletion y)
runCompletionT = coerce
{-# INLINE runCompletionT #-}

instance (ArrowChoice c, ArrowApply c, Profunctor c) => ArrowApply (CompletionT c) where
  app = lift (app .# first coerce)
type instance Fix x y (CompletionT c) = CompletionT (Fix (Dom (CompletionT) x y) (Cod (CompletionT) x y) c)
deriving instance (ArrowChoice c, ArrowFix (Dom (CompletionT) x y) (Cod (CompletionT) x y) c) => ArrowFix x y (CompletionT c)

instance (ArrowChoice c, ArrowLowerBounded c) => ArrowLowerBounded (CompletionT c) where
  bottom = lift $ bottom

instance (ArrowChoice c, ArrowComplete c) => ArrowComplete (CompletionT c) where
  join lub f g = lift $ join joinVal (unlift f) (unlift g)
    where joinVal (Lower x) (Lower y) = Lower (lub x y)
          joinVal Top _ = Top
          joinVal _ Top = Top
