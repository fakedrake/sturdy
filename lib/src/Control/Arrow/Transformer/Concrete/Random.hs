{-# LANGUAGE Arrows #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE TypeFamilies #-}
module Control.Arrow.Transformer.Concrete.Random where

import           Control.Category
import           Control.Arrow
import           Control.Arrow.Alloc
import           Control.Arrow.Environment
import           Control.Arrow.Except
import           Control.Arrow.Trans
import           Control.Arrow.Fail
import           Control.Arrow.Fix
import           Control.Arrow.Reader
import           Control.Arrow.Random
import           Control.Arrow.State
import           Control.Arrow.Store

import           Control.Arrow.Transformer.State

import           Data.Profunctor

import           System.Random(StdGen,Random)
import qualified System.Random as R

newtype RandomT c x y = RandomT (StateT StdGen c x y)
  deriving (Profunctor,Category,Arrow,ArrowChoice,ArrowTrans,ArrowLift,
            ArrowReader r, ArrowFail e, ArrowExcept e,
            ArrowEnv var val env, ArrowStore var val)

runRandomT :: RandomT c x y -> c (StdGen,x) (StdGen,y)
runRandomT (RandomT (StateT f)) = f

instance (Random v, Arrow c, Profunctor c) => ArrowRand v (RandomT c) where
  random = RandomT $ proc () -> do
    gen <- get -< ()
    let (v,gen') = R.random gen
    put -< gen'
    returnA -< v

type instance Fix x y (RandomT c) = RandomT (Fix (Dom RandomT x y) (Cod RandomT x y) c)
deriving instance (Arrow c, ArrowFix (Dom RandomT x y) (Cod RandomT x y) c) => ArrowFix x y (RandomT c)

deriving instance ArrowAlloc x y c => ArrowAlloc x y (RandomT c)

instance ArrowState s c => ArrowState s (RandomT c) where
  get = lift' get
  put = lift' put
