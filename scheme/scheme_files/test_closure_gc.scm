#lang scheme 

(let ((double (lambda (x) (+ x x)))
      (square (lambda (y) (* y y)))
      (apply-fn (lambda (f n) (f n))))
  (apply-fn double 3)
  (apply-fn square 4))