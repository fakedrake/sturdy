{-# LANGUAGE Arrows #-}
{-# LANGUAGE FlexibleContexts #-}
module Control.Arrow.Utils where

import Control.Arrow
import Control.Arrow.Fail

mapA :: ArrowChoice c => c x y -> c [x] [y]
mapA f = proc l -> case l of
  [] -> returnA -< []
  (a:as) -> do
    b <- f -< a
    bs <- mapA f -< as
    returnA -< (b:bs)

voidA :: Arrow c => c x y -> c x ()
voidA f = proc x -> do
  _ <- f -< x
  returnA -< ()

infixr 1 &&>
(&&>) :: Arrow c => c a () -> c a b -> c a b
f &&> g = f &&& g >>> arr snd

pi1 :: Arrow c => c (x,y) x
pi1 = arr fst

pi2 :: Arrow c => c (x,y) y
pi2 = arr snd

zipWithA :: ArrowChoice c => c (x,y) z -> c ([x],[y]) [z]
zipWithA f = proc (l1,l2) -> case (l1,l2) of
  ([],_) -> returnA -< []
  (_,[]) -> returnA -< []
  (a:as,b:bs) -> do
    c <- f -< (a,b)
    cs <- zipWithA f -< (as,bs)
    returnA -< c:cs

injectLeft :: (r,Either a b) -> Either (r,a) b
injectLeft (r,e) = case e of
  Left a -> Left (r,a)
  Right b -> Right b

injectRight :: (r,Either a b) -> Either a (r,b)
injectRight (r,e) = case e of
  Left a -> Left a
  Right b -> Right (r,b)

injectBoth :: (r,Either a b) -> Either (r,a) (r,b)
injectBoth (r,e) = case e of
  Left a -> Left (r,a)
  Right b -> Right (r,b)

eject :: Either (r,a) (r,b) -> (r,Either a b)
eject e = case e of
  Left (r,a) -> (r,Left a)
  Right (r,b) -> (r,Right b)

failA' :: ArrowFail () c => c a b
failA' = arr (const ()) >>> failA
