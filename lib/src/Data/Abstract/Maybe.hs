module Data.Abstract.Maybe where

import Prelude hiding (Maybe(..))

import Control.Monad(ap)
import Control.Arrow(second)

import Data.Order
import Data.Hashable
import Data.Traversable
import Data.Abstract.Widening

-- | Abstract 'Maybe' type with an upper bound for 'Just' and 'Nothing'
data Maybe a = Just a | Nothing | JustNothing a
  deriving (Eq,Ord,Show)

instance (Hashable a) => Hashable (Maybe a) where
  hashWithSalt s (Just a) = s `hashWithSalt` (1::Int) `hashWithSalt` a
  hashWithSalt s (Nothing) = s `hashWithSalt` (2::Int)
  hashWithSalt s (JustNothing a) = s `hashWithSalt` (3 ::Int) `hashWithSalt` a

instance PreOrd a => PreOrd (Maybe a) where
  Just a ⊑ Just b = a ⊑ b
  Nothing ⊑ Nothing = True
  JustNothing a ⊑ JustNothing b = a ⊑ b
  Just a ⊑ JustNothing b = a ⊑ b
  Nothing ⊑ JustNothing _ = True
  _ ⊑ _ = False

instance Complete a => Complete (Maybe a) where
  Just x ⊔ Just y = Just (x ⊔ y)
  Nothing ⊔ Nothing = Nothing
  Just x ⊔ Nothing = JustNothing x
  Nothing ⊔ Just y = JustNothing y
  Just x ⊔ JustNothing y = JustNothing (x ⊔ y)
  Nothing ⊔ JustNothing y = JustNothing y
  JustNothing x ⊔ Just y = JustNothing (x ⊔ y)
  JustNothing x ⊔ Nothing = JustNothing x
  JustNothing x ⊔ JustNothing y = JustNothing (x ⊔ y)

widening :: Widening a -> Widening (Maybe a)
widening w (Just x) (Just y) = second Just (w x y)
widening _ Nothing Nothing = (Stable,Nothing)
widening _ (Just x) Nothing = (Instable,JustNothing x)
widening _ Nothing (Just y) = (Instable,JustNothing y)
widening w (Just x) (JustNothing y) = let (_,z) = w x y in (Instable,JustNothing z)
widening _ Nothing (JustNothing y) = (Instable,JustNothing y)
widening w (JustNothing x) (Just y) = let (_,z) = w x y in (Instable,JustNothing z)
widening _ (JustNothing y) Nothing = (Instable,JustNothing y)
widening w (JustNothing x) (JustNothing y) = second JustNothing (w x y)

instance UpperBounded a => UpperBounded (Maybe a) where
  top = JustNothing top

instance Functor Maybe where
  fmap f m = case m of
    Just a -> Just (f a)
    Nothing -> Nothing
    JustNothing a -> Just (f a)

instance Applicative Maybe where
  pure = return
  (<*>) = ap

instance Monad Maybe where
  return = Just
  x >>= k = case x of
    Nothing -> Nothing
    Just a -> k a
    JustNothing a -> case k a of
      Nothing -> Nothing
      Just a' -> JustNothing a'
      JustNothing a' -> JustNothing a'

instance Foldable Maybe where
  foldMap = foldMapDefault

instance Traversable Maybe where
  traverse _ Nothing = pure Nothing
  traverse f (Just a) = Just <$> f a
  traverse f (JustNothing a) = JustNothing <$> f a
