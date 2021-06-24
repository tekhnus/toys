(def last
     (builtin.fn
	 (if (tail (head args))
	     (last (tail (head args)))
	   (head (head args)))))
(def progn (builtin.fn (last args)))
(def quote (builtin.operator  (head args)))

(def second
     (builtin.fn
      (head (tail (head args)))))

(def type (builtin.fn (head (annotate (head args)))))
(def decons-fn
     (builtin.fn
      (if (is-constant (head args))
	  `(if (eq ~(head args) ~(second args)) :ok :err)
	(if (eq (type (head args)) :symbol)
	    `(progn
	       (def ~(head args) ~(second args))
	       :ok)
	  (if (eq (type (head args)) :list)
	      (if (head args)
		  `(if (eq ~(decons-fn (head (head args)) `(head ~(second args))) :err) :err ~(decons-fn (tail (head args)) `(tail ~(second args))))
		`(if ~(second args) :err :ok))
	    (panic "decons met an unsupported type"))))))

'(print (decons-fn 42 'bar))
'(print (decons-fn :foo 'bar))
'(print (decons-fn 'foo 'bar))
'(print (decons-fn '() 'bar))
'(print (decons-fn '(foo1 foo2) 'bar))

(def decons
     (builtin.macro
      (decons-fn (head args) (second args))))

(def progn- (builtin.fn (cons 'progn (head args))))

(def myprog '((print 42) (print 33)))
(progn- myprog)

(def fn (builtin.macro `(builtin.fn (if (eq :ok (decons ~(head args) args)) ~(progn- (tail args)) (panic "wrong fn call")))))

(def macro (builtin.macro `(builtin.macro (if (eq :ok (decons ~(head args) args)) ~(progn- (tail args)) (panic "wrong macro call")))))

(def list (builtin.fn args))

(def defn (builtin.macro `(def ~(head args) ~(cons 'fn (tail args)))))

(def defmacro (builtin.macro `(def ~(head args) ~(cons 'macro (tail args)))))

(defn third args (head (tail (tail (head args)))))

(defn map (f s)
  (if s
      (cons
       (f
	(head s))
       (map
	f
	(tail s)))
    '()))

(defn append (x xs)
  (if xs
      (cons
       (head xs)
       (append
	x
	(tail xs)))
    (list x)))

(defmacro cond- (cases)
  (if cases
      `(if ~(head (head cases))
	 ~(second (head cases))
	 (cond- ~(tail cases)))
    (panic "cond didn't match")))
(def cond (builtin.macro `(cond- ~args)))

(defn is-nil (val) (if val '() '(())))
(defn switch-fn (exp cases)
  (if (is-nil cases)
      (panic "switch didn't match")
    `(cond- ~(map (fn (pat-val) `((eq :ok (decons ~(head pat-val) ~exp)) ~(progn- (tail pat-val)))) cases))))
(defmacro switch args (switch-fn (head args) (tail args)))

(defmacro handle-error (name) `(switch ~name ((:ok tmp) (def ~name tmp)) ((:err msg) (panic msg))))

(def libc (load-shared-library "libc.so.6"))
(handle-error libc)
	   
(def fopen
     (extern-pointer libc "fopen"
		     ((string string) pointer)))

(handle-error fopen)

(def malloc
     (extern-pointer libc "malloc"
		     ((sizet) pointer)))
(handle-error malloc)

(def fread
     (extern-pointer libc "fread"
		     ((pointer sizet sizet pointer) sizet)))
(handle-error fread)

(def feof
     (extern-pointer libc "feof"
		     ((pointer) int)))
(handle-error feof)

(def printfptr
     (extern-pointer libc "printf"
		     ((string pointer) sizet)))
(handle-error printfptr)

(def fprintfstring
     (extern-pointer libc "fprintf"
		     ((pointer string string) sizet)))
(handle-error fprintfstring)

(def stdin
     (extern-pointer libc "stdin" pointer))
(handle-error stdin)

(def stdout
     (extern-pointer libc "stdout" pointer))
(handle-error stdout)

(def stderr
     (extern-pointer libc "stderr" pointer))
(handle-error stderr)

(defn repl
  (nsp)
  (fprintfstring stdout "%s" "> ")
  (def readres (read stdin))
  (switch readres
	  ((:eof)
	   (fprintfstring stdout "%s\n" ""))
	  ((:ok datum)
	   (def v (eval-in nsp datum))
	   (switch v
		   ((:ok val)
		    (print val))
		   ((:err msg)
		    (fprintfstring stdout "eval error: %s\n" msg)))
	   (repl nsp))
	  ((:err msg)
	   (fprintfstring stdout "read error: %s\n" msg)
	   (repl nsp))))

(def ns (make-namespace))
(repl ns)
