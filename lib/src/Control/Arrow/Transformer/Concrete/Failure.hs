{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE Arrows #-}
{-# LANGUAGE TypeFamilies #-}
module Control.Arrow.Transformer.Concrete.Failure(FailureT(..)) where

import Prelude hiding (id,(.),lookup,read,fail)

import Control.Arrow
import Control.Arrow.Const
import Control.Arrow.Deduplicate
import Control.Arrow.Environment as Env
import Control.Arrow.Fail
import Control.Arrow.Fix
import Control.Arrow.Trans
import Control.Arrow.Reader
import Control.Arrow.Store as Store
import Control.Arrow.State
import Control.Arrow.Except as Exc
import Control.Arrow.Utils
import Control.Category

import Data.Profunctor
import Data.Concrete.Error
import Data.Monoidal
import Data.Identifiable

-- | Arrow transformer that adds failure to the result of a computation
newtype FailureT e c x y = FailureT { runFailureT :: c x (Error e y) }

instance (ArrowChoice c, Profunctor c) => ArrowFail e (FailureT e c) where
  fail = lift $ arr Fail

instance (Profunctor c, Arrow c) => Profunctor (FailureT e c) where
  dimap f g h = lift $ dimap f (fmap g) (unlift h)
  lmap f h = lift $ lmap f (unlift h)
  rmap g h = lift $ rmap (fmap g) (unlift h)

instance ArrowTrans (FailureT e) where
  type Dom (FailureT e) x y = x
  type Cod (FailureT e) x y = Error e y
  lift = FailureT
  unlift = runFailureT

instance ArrowLift (FailureT e) where
  lift' f = lift (f >>> arr Success)

instance (ArrowChoice c, Profunctor c) => Category (FailureT r c) where
  id = lift' id
  f . g = lift $ unlift g >>> toEither ^>> arr Fail ||| unlift f

instance (ArrowChoice c, Profunctor c) => Arrow (FailureT r c) where
  arr f = lift' (arr f)
  first f = lift $ rmap strength1 (first (unlift f))
  second f = lift $ rmap strength2 (second (unlift f))
  f *** g = first f >>> second g
  f &&& g = lmap duplicate (f *** g)

instance (ArrowChoice c, Profunctor c) => ArrowChoice (FailureT r c) where
  left f = lift $ left (unlift f) >>^ strength1
  right f = lift $ right (unlift f) >>^ strength2
  f ||| g = lift (unlift f ||| unlift g)
  f +++ g = lift $ unlift f +++ unlift g >>^ distribute2

instance (ArrowChoice c, ArrowApply c, Profunctor c) => ArrowApply (FailureT e c) where
  app = FailureT $ lmap (first runFailureT) app

instance (ArrowChoice c, ArrowState s c) => ArrowState s (FailureT e c) where
  get = lift' get
  put = lift' put

instance (ArrowChoice c, ArrowReader r c) => ArrowReader r (FailureT e c) where
  ask = lift' ask
  local f = lift (local (unlift f))

instance (ArrowChoice c, ArrowEnv x y env c) => ArrowEnv x y env (FailureT e c) where
  type Join (FailureT e c) x y = Env.Join c (Dom (FailureT e) x y) (Cod (FailureT e) x y)
  lookup f g = lift $ lookup (unlift f) (unlift g)
  getEnv = lift' getEnv
  extendEnv = lift' extendEnv
  localEnv f = lift (localEnv (unlift f))

instance (ArrowChoice c, ArrowStore var val c) => ArrowStore var val (FailureT e c) where
  type Join (FailureT e c) x y = Store.Join c (Dom (FailureT e) x y) (Cod (FailureT e) x y)
  read f g = lift $ read (unlift f) (unlift g)
  write = lift' $ write

type instance Fix x y (FailureT e c) = FailureT e (Fix (Dom (FailureT e) x y) (Cod (FailureT e) x y) c)
instance (ArrowChoice c, ArrowFix (Dom (FailureT e) x y) (Cod (FailureT e) x y) c) => ArrowFix x y (FailureT e c) where
  fix = liftFix

instance (ArrowChoice c, ArrowExcept e c) => ArrowExcept e (FailureT e' c) where
  type Join (FailureT e' c) x y = Exc.Join c (Dom (FailureT e') x y) (Cod (FailureT e') x y)
  throw = lift' throw
  catch f g = lift $ catch (unlift f) (unlift g)
  finally f g = lift $ finally (unlift f) (unlift g)

instance (Identifiable e, ArrowChoice c, ArrowDeduplicate (Dom (FailureT e) x y) (Cod (FailureT e) x y) c) => ArrowDeduplicate x y (FailureT e c) where
  dedup f = lift (dedup (unlift f))

instance (ArrowChoice c, ArrowConst r c) => ArrowConst r (FailureT e c) where
  askConst = lift' askConst
