{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE Arrows #-}
module Control.Arrow.Class.Store where

import Prelude hiding (lookup,id)

import Control.Arrow

class Arrow c => ArrowStore var val c | c -> var, c -> val where
  lookup :: c var val
  store :: c (var,val) ()
