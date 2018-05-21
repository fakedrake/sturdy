{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeFamilies #-}
module Control.Arrow.Transformer.State(State(..),evalState,execState) where

import Prelude hiding (id,(.),lookup,read)

import Control.Arrow
import Control.Arrow.Deduplicate
import Control.Arrow.Environment
import Control.Arrow.Fail
import Control.Arrow.Fix
import Control.Arrow.Lift
import Control.Arrow.Reader
import Control.Arrow.State
import Control.Arrow.Store
import Control.Arrow.Try
import Control.Arrow.Writer
import Control.Arrow.Utils
import Control.Category

import Data.Hashable
import Data.Order
import Data.Monoidal

-- Due to "Generalising Monads to Arrows", by John Hughes, in Science of Computer Programming 37.
newtype State s c x y = State { runState :: c (s,x) (s,y) }

evalState :: Arrow c => State s c x y -> c (s,x) y
evalState f = runState f >>> pi2

execState :: Arrow c => State s c x y -> c (s,x) s
execState f = runState f >>> pi1

instance Category c => Category (State s c) where
  id = State id
  State f . State g = State (f . g)

instance ArrowLift (State r) where
  lift f = State (second f)

instance Arrow c => Arrow (State s c) where
  arr f = lift (arr f)
  first (State f) = State $ (\(s,(b,c)) -> ((s,b),c)) ^>> first f >>^ (\((s,d),c) -> (s,(d,c)))
  second (State f) = State $ (\(s,(a,b)) -> (a,(s,b))) ^>> second f >>^ (\(a,(s,c)) -> (s,(a,c)))
  State f &&& State g = State $ (\(s,x) -> ((s,x),x)) ^>> first f >>> (\((s,y),x) -> ((s,x),y)) ^>> first g >>^ (\((s,z),y) -> (s,(y,z)))
  State f *** State g = State $ (\(s,(x,y)) -> ((s,x),y)) ^>> first f >>> (\((s,y),x) -> ((s,x),y)) ^>> first g >>^ (\((s,z),y) -> (s,(y,z)))

instance ArrowChoice c => ArrowChoice (State s c) where
  left (State f) = State (to distribute ^>> left f >>^ from distribute)
  right (State f) = State (to distribute ^>> right f >>^ from distribute)
  State f +++ State g = State $ to distribute ^>> f +++ g >>^ from distribute
  State f ||| State g = State $ to distribute ^>> f ||| g

instance ArrowApply c => ArrowApply (State s c) where
  app = State $ (\(s,(State f,b)) -> (f,(s,b))) ^>> app

instance Arrow c => ArrowState s (State s c) where
  getA = State (arr (\(a,()) -> (a,a)))
  putA = State (arr (\(_,s) -> (s,())))

instance ArrowFail e c => ArrowFail e (State s c) where
  failA = lift failA

instance ArrowReader r c => ArrowReader r (State s c) where
  askA = lift askA
  localA (State f) = State $ (\(s,(r,x)) -> (r,(s,x))) ^>> localA f

instance ArrowWriter w c => ArrowWriter w (State s c) where
  tellA = lift tellA

instance ArrowEnv x y env c => ArrowEnv x y env (State s c) where
  lookup = lift lookup
  getEnv = lift getEnv
  extendEnv = lift extendEnv
  localEnv (State f) = State ((\(r,(env,a)) -> (env,(r,a))) ^>> localEnv f)
  getEnvDomain = lift getEnvDomain

instance ArrowStore var val lab c => ArrowStore var val lab (State s c) where
  read = lift read
  write = lift write

type instance Fix x y (State s c) = State s (Fix (s,x) (s,y) c)
instance ArrowFix (s,x) (s,y) c => ArrowFix x y (State s c) where
  fixA f = State (fixA (runState . f . State))

instance ArrowTry (s,x) (s,y) (s,z) c => ArrowTry x y z (State s c) where
  tryA (State f) (State g) (State h) = State $ tryA f g h

instance (Eq s, Hashable s, ArrowDeduplicate c) => ArrowDeduplicate (State s c) where
  dedupA (State f) = State (dedupA f)

instance ArrowLoop c => ArrowLoop (State s c) where
  loop (State f) = State $ loop ((\((s,b),d) -> (s,(b,d))) ^>> f >>^ (\(s,(b,d)) -> ((s,b),d)))

deriving instance PreOrd (c (s,x) (s,y)) => PreOrd (State s c x y)
deriving instance LowerBounded (c (s,x) (s,y)) => LowerBounded (State s c x y)
deriving instance Complete (c (s,x) (s,y)) => Complete (State s c x y)
deriving instance CoComplete (c (s,x) (s,y)) => CoComplete (State s c x y)
deriving instance UpperBounded (c (s,x) (s,y)) => UpperBounded (State s c x y)
