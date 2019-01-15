{-# LANGUAGE Arrows #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# OPTIONS_GHC -fno-warn-orphans -fno-warn-partial-type-signatures #-}
module ValueSemantics.Unit where

import           Prelude hiding (Bool(..),Bounded(..))

import           Syntax
import           GenericInterpreter
import qualified GenericInterpreter as Generic

import           Data.Abstract.Failure (Error(..))
import           Data.Abstract.Map (Map)
import qualified Data.Abstract.Map as M
import           Data.Abstract.Terminating
import           Data.Abstract.FreeCompletion(FreeCompletion)

import           Data.Order
import           Data.Label
import           Data.Text (Text)

import           Control.Category
import           Control.Arrow
import           Control.Arrow.Alloc
import           Control.Arrow.Fix
import           Control.Arrow.Fail
import           Control.Arrow.Environment
import           Control.Arrow.Store
import           Control.Arrow.Conditional as Cond
import           Control.Arrow.Random

import           Control.Arrow.Transformer.Abstract.Fixpoint
import           Control.Arrow.Transformer.Abstract.Environment
import           Control.Arrow.Transformer.Abstract.Store
import           Control.Arrow.Transformer.Abstract.Failure

-- Value semantics for the while language that does not approximate values at all.
type Addr = FreeCompletion Label
type Val = ()

run :: [(Text,Addr)] -> [LStatement] -> Terminating (Error String (Map Addr Val))
run env ss =
  fmap fst <$>
    runFixT
      (runFailureT
         (runStoreT
           (runEnvT
             (runUnitT
               (Generic.run ::
                 Fix [Statement] ()
                   (UnitT
                     (EnvT Text Addr
                       (StoreT Addr Val
                         (FailureT String
                          (FixT _ () () (->)))))) [Statement] ())))))
      (M.empty,(M.fromList env,generate <$> ss))

newtype UnitT c x y = UnitT { runUnitT :: c x y }
  deriving (Category,Arrow,ArrowChoice,ArrowFail e,ArrowEnv var val env,ArrowStore var val,PreOrd,Complete)
type instance Fix x y (UnitT c) = UnitT (Fix x y c)
deriving instance ArrowFix x y c => ArrowFix x y (UnitT c)

instance ArrowChoice c => ArrowAlloc (Text,Val,Label) Addr (UnitT c) where
  alloc = arr $ \(_,_,l) -> return l

instance ArrowChoice c => IsVal Val (UnitT c) where
  boolLit = arr (const ())
  and = arr (const ())
  or = arr (const ())
  not = arr (const ())
  numLit = arr (const ())
  add = arr (const ())
  sub = arr (const ())
  mul = arr (const ())
  div = arr (const ())
  eq = arr (const ())
  lt = arr (const ())

instance ArrowChoice c => ArrowRand Val (UnitT c) where
  random = arr (const ())

instance ArrowChoice c => ArrowCond Val (UnitT c) where
  type Join (UnitT c) x y = Complete (c x y)
  if_ f1 f2 = proc (_,(x,y)) -> joined f1 f2 -< (x,y)
