{-# LANGUAGE UndecidableInstances #-}
module Data.Order where

import           Data.Functor.Identity
import           Data.Map (Map)
import qualified Data.Map as M
import           Data.Set (Set)
import qualified Data.Set as S
import           Data.Error

import           Numeric.Limits

import           Control.Arrow
import           Control.Monad.State
import           Control.Monad.Except

-- | Reflexive, transitive order
class PreOrd x where
  (⊑) :: x -> x -> Bool

  (≈) :: x -> x -> Bool
  x ≈ y = x ⊑ y && y ⊑ x

-- | Order with all least upper bounds
class PreOrd x => Complete x where
  (⊔) :: x -> x -> x

-- | Order with a least element
class PreOrd x => LowerBounded x where
  bottom :: x

lub :: (Foldable f, Complete x, LowerBounded x) => f x -> x
lub = foldr (⊔) bottom

-- | Order with all greatest lower bounds
class PreOrd x => CoComplete x where
  (⊓) :: x -> x -> x

-- | Order with a greatest element
class PreOrd x => UpperBounded x where
  top :: x

glb :: (Foldable f, Complete x, UpperBounded x) => f x -> x
glb = foldr (⊔) top

instance PreOrd a => PreOrd [a] where
  []     ⊑ []     = True
  (a:as) ⊑ (b:bs) = a ⊑ b && as ⊑ bs
  _      ⊑ _      = False

instance PreOrd a => PreOrd (Set a) where
  s1 ⊑ s2 = all (\x -> any (\y -> x ⊑ y) s2) s1

instance PreOrd () where
  () ⊑ () = True

instance Complete () where
  () ⊔ () = ()

instance (PreOrd a,PreOrd b) => PreOrd (a,b) where
  (a1,b1) ⊑ (a2,b2) = a1 ⊑ a2 && b1 ⊑ b2 

instance (Complete a, Complete b) => Complete (a,b) where
  (a1,b1) ⊔ (a2,b2) = (a1 ⊔ a2, b1 ⊔ b2)

instance (CoComplete a, CoComplete b) => CoComplete (a,b) where
  (a1,b1) ⊓ (a2,b2) = (a1 ⊓ a2, b1 ⊓ b2)

instance (Ord k,PreOrd v) => PreOrd (Map k v) where
  c1 ⊑ c2 = M.keysSet c1 `S.isSubsetOf` M.keysSet c2 && all (\k -> (c1 M.! k) ⊑ (c2 M.! k)) (M.keys c1)

instance (Ord k, Complete v) => Complete (Map k v) where
  (⊔) = M.unionWith (⊔)

-- Base types are discretly ordered
instance PreOrd Char where
  (⊑) = (==)
  (≈) = (==)

instance PreOrd Int where
  (⊑) = (==)
  (≈) = (==)

instance PreOrd Double where
  (⊑) = (==)
  (≈) = (==)

instance LowerBounded Double where
  bottom = minValue

instance UpperBounded Double where
  top = maxValue

instance Complete Double where
  (⊔) = max

instance CoComplete Double where
  (⊓) = min

instance (PreOrd (m (a,s))) => PreOrd (StateT s m a) where
  _ ⊑ _ = error "StateT f ⊑ StateT g  iff  forall x. f x ⊑ g x"

instance Complete (m (a,s)) => Complete (StateT s m a) where
  StateT f ⊔ StateT g = StateT $ \s -> f s ⊔ g s

instance PreOrd a => PreOrd (Error e a) where
  Error _ ⊑ Success _ = True
  Error _ ⊑ Error _ = True
  Success x ⊑ Success y = x ⊑ y
  _ ⊑ _ = False

  Error _ ≈ Error _ = True
  Success x ≈ Success y = x ≈ y
  _ ≈ _ = False

instance Complete a => Complete (Error e a) where
  Error _ ⊔ b = b
  a ⊔ Error _ = a
  Success x ⊔ Success y = Success (x ⊔ y)

-- | The type Error has the correct ordering for our use case compared to the either type
instance (PreOrd (m (Error e a)), Functor m) => PreOrd (ExceptT e m a) where
  ExceptT f ⊑ ExceptT g = fmap fromEither f ⊑ fmap fromEither g

instance (Complete (m (Error e a)), Functor m) => Complete (ExceptT e m a) where
  ExceptT f ⊔ ExceptT g = ExceptT $ fmap toEither (fmap fromEither f ⊔ fmap fromEither g)

instance PreOrd (m b) => PreOrd (Kleisli m a b) where
  _ ⊑ _ = error "Kleisli f ⊑ Kleisli g  iff  forall x. f x ⊑ g x"

instance Complete (m b) => Complete (Kleisli m a b) where
  Kleisli f ⊔ Kleisli g = Kleisli $ \x -> f x ⊔ g x

instance PreOrd a => PreOrd (Identity a) where
  (Identity x) ⊑ (Identity y) = x ⊑ y

instance Complete a => Complete (Identity a) where
  Identity x ⊔ Identity y = Identity $ x ⊔ y