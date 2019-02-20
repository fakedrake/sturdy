module Data.Utils where

import Data.Maybe
import Data.Map (Map)
import qualified Data.Map as Map

lookupM :: (Ord k, Monoid v) => k -> Map k v -> v
lookupM x m = fromMaybe mempty $ Map.lookup x m

maybeHead :: [a] -> Maybe a
maybeHead (a:_) = Just a
maybeHead []    = Nothing
