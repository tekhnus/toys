(require "std")

(require "std")
!(require "testing")
!(require "stdmacro")

(def panics '())

!(#fntest
  (return (head '(42 5 3)))
  42)

!(#fntest
  (return (tail '(42 5 3)))
  '(5 3))

!(#fntest
  (return (head (tail '(42 5 3))))
  5)

!(#fntest
  (return (second '(42 5 3)))
  5)

!(#fntest
 (return "hello, world!")
 "hello, world!")

!(#fntest
  (return (+ 4 3))
  7)

!(#fntest
  (return (second '(1 2)))
  2)

!(#fntest
  (return (eq :foo :bar))
  '())

!(#fntest
  (progn
    (def bar :foo)
    (return (eq :foo bar)))
  '(()))

!(#fntest
  (progn
    (return (append 5 '(1 2 3 4))))
  '(1 2 3 4 5))

!(#fntest
  (return (list 1 2 (+ 1 2)))
  '(1 2 3))

!(#fntest
  (progn
    !(#defun twice (arg) (return (+ arg arg)))
    (return (twice 35)))
  70)

!(#fntest
  (progn
    !(#defun adder (n) (return !(#fn (m) (return (+ n m)))))
    (return ((adder 3) 4)))
  7)

!(#fntest
  (progn
    !(#defun fib ()
       (yield 3)
       (yield 5)
       (yield 8)
       (yield 13))
    !(#def2 x fib (fib))
    !(#def2 y fib (fib))
    !(#def2 z fib (fib))
    !(#def2 t fib (fib))
    (return (list x y z t)))
  '(3 5 8 13))

!(#fntest
  (progn
    (require "std")
    (return 42))
  42)

!(#defun print-all (xs)
   (return
   (if xs
       (progn
         (print (head xs))
         (print-all (tail xs)))
     '())))

(if panics
    (progn
      (print-all panics)
      (panic "FAILED"))
  (progn))

