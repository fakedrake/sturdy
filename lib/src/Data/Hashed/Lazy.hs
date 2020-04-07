module Data.Hashed.Lazy where

import Data.Hashable(Hashable(..))
import Data.Order
import Data.Empty

import Control.DeepSeq

-- | Lazy version of Data.Hashable.Hashed. This datatype caches the hash of the
-- wrapped type.
data Hashed a = Hashed a Int

unhashed :: Hashed a -> a
unhashed (Hashed a _) = a

hashed :: Hashable a => a -> Hashed a
hashed a = Hashed a (hash a)

mapHashed :: Hashable b => (a -> b) -> Hashed a -> Hashed b
mapHashed f (Hashed a _) = hashed (f a)

instance Eq a => Eq (Hashed a) where
  Hashed a ha == Hashed b hb = ha == hb && a == b

instance Show a => Show (Hashed a) where
  show (Hashed a _) = show a

instance Hashable (Hashed a) where
  hashWithSalt salt (Hashed _ h) = hashWithSalt salt h
  hash (Hashed _ h) = h

instance (Hashable a, IsEmpty a) => IsEmpty (Hashed a) where
  empty = hashed empty

instance PreOrd a => PreOrd (Hashed a) where
  a ⊑ b = unhashed a ⊑ unhashed b
  a ≈ b = unhashed a ≈ unhashed b

instance (Hashable a, Complete a) => Complete (Hashed a) where
  xs ⊔ ys = hashed (unhashed xs ⊔ unhashed ys)

instance NFData a => NFData (Hashed a) where
  rnf (Hashed a _) = rnf a

