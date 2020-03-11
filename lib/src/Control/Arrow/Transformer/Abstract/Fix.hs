{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE ImplicitParams #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE RankNTypes #-}
{-# OPTIONS_GHC -fno-warn-unused-top-binds #-}
module Control.Arrow.Transformer.Abstract.Fix(FixT,runFixT) where

import           Prelude hiding (id,(.),const,head,iterate,lookup)

import           Control.Category
import           Control.Arrow hiding (loop)
import           Control.Arrow.Fix
import           Control.Arrow.Fix.Cache
import           Control.Arrow.Fix.Chaotic
import           Control.Arrow.Fix.Stack
import           Control.Arrow.Fix.Context
import           Control.Arrow.Fix.Metrics
import           Control.Arrow.Order(ArrowEffectCommutative,ArrowComplete,ArrowJoin)
import           Control.Arrow.Trans

import           Data.Profunctor
import           Data.Profunctor.Unsafe((.#))
import           Data.Coerce

newtype FixT c x y = FixT (c x y)
  deriving (Profunctor,Category,Arrow,ArrowChoice,
            ArrowComplete z,ArrowJoin,
            ArrowContext ctx, ArrowJoinContext a,
            ArrowCache a b, ArrowParallelCache a b, ArrowIterateCache,
            ArrowStack a,ArrowStackElements a,ArrowStackDepth,
            ArrowComponent a, ArrowInComponent a,
            ArrowFiltered a)

runFixT :: FixT c x y -> c x y
runFixT (FixT f) = f
{-# INLINE runFixT #-}

instance ArrowRun c => ArrowRun (FixT c) where
  type Run (FixT c) x y = Run c x y

instance ArrowTrans (FixT c) where
  type Underlying (FixT c) x y = c x y

instance ArrowFix (FixT c a b) where
  type Fix (FixT c a b) = FixT c a b
  fix = {-# SCC "Fix.fix" #-} ?fixpointAlgorithm
  {-# INLINABLE fix #-}

instance (Profunctor c,ArrowApply c) => ArrowApply (FixT c) where
  app = FixT (app .# first coerce)
  {-# INLINE app #-}

instance ArrowLift FixT where
  lift' = FixT
  {-# INLINE lift' #-}

instance ArrowEffectCommutative c => ArrowEffectCommutative (FixT c)
