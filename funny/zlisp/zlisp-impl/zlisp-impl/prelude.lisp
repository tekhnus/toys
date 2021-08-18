(def readme "The most basic fuctions. This module is always loaded implicitly at the start.")


(builtin.defn last
	      
	 (if (tail (head args))
	     (return (last (tail (head args))))
	   (return (head (head args)))))

(def second
     (builtin.fn
      (return (head (tail (head args))))))

(def type (builtin.fn (return (head (annotate (head args))))))

(builtin.defn concat
	     
    (if (head args)
	(return (cons (head (head args)) (concat (tail (head args)) (second args))))
      (return (second args))))

(builtin.defn decons-pat
	      (progn
		(def pat (head args))
		(def val (second args))
		(if (is-constant pat)
		    (if (eq pat val)
			(return '(:ok ()))
		      (return '(:err)))
		  (if (eq (type pat) :symbol)
		      (return (list :ok (list val)))
		    (if (eq (type pat) :list)
			(if pat
			    (if val
				(progn
				  (def first-decons (decons-pat (head pat) (head val)))
				  (def rest-decons (decons-pat (tail pat) (tail val)))
				  (if (eq :err (head rest-decons))
				      (return '(:err))
				    (if (eq :err (head first-decons))
					(return '(:err))
				      (return (list :ok (concat (second first-decons) (second rest-decons)))))))
			      (return '(:err)))
			  (if val
			      (return '(:err))
			    (return '(:ok ()))))
		      (panic "decons-pat met an unsupported type"))))))

(builtin.defn decons-vars
     (if (is-constant (head args))
	(return '())
      (if (eq (type (head args)) :symbol)
	  (return (list (head args)))
	(if (eq (type (head args)) :list)
	    (if (head args)
		(return (concat (decons-vars (head (head args))) (decons-vars (tail (head args)))))
	      (return `()))
	  (panic "decons-var met an unsupported type")))))

(builtin.defn zip
	      
    (if (head args)
	(return (cons (list (head (head args)) (head (second args))) (zip (tail (head args)) (tail (second args)))))
      (return '())))

(builtin.defn map
	    
  (if (head (tail args))
      (return (cons
       ((head args)
	(head (head (tail args))))
       (map
	(head args)
	(tail (head (tail args))))))
    (return '())))

(def switch-defines '((head args) (second args) (third args)))

(builtin.defn switch-clause
    (progn
      (def sig (head (head args)))
      (def cmds (tail (head args)))
      (def checker (list 'decons-pat (list 'quote sig) 'args))
      (def vars (decons-vars sig))
      (def body (cons 'progn (concat (map (builtin.fn (return (cons 'def (head args)))) (zip vars switch-defines)) cmds)))
      (return (list checker body))))




(builtin.defn swtchone
	      (if (head args)
		  (progn
		    (def firstarg (head (head args)))
		    (def cond (head firstarg))
		    (def body (second firstarg))
		    (def rest (swtchone (tail (head args))))
		    (return `(progn
			       (def prearg ~cond)
			       (if (eq (head prearg) :ok)
				   (progn
				     (def args (second prearg))
				     ~body)
				 ~rest))))
		(return '(panic "nothing matched"))))


(builtin.defn switch-fun
    (return (swtchone (map switch-clause (head args)))))

(def list (builtin.fn (return args)))

(def ignore-fn (builtin.fn (return `(def throwaway ~(head args)))))

(def ignore (builtin.fn (return (ignore-fn (head args)))))

(def panic-block '(argz (panic "wrong fn call")))

(def progn- (builtin.fn (return (cons 'progn (head args)))))

(def defun (builtin.fn (return `(builtin.defn ~(head args) ~(switch-fun `(~(tail args)))))))

!(#defun switchx argz (return `(progn (def args ~(head argz)) ~(switch-fun (tail argz)))))

!(#defun third args (return (head (tail (tail (head args))))))

!(#defun append (x xs)
  (if xs
      (return (cons
       (head xs)
       (append
	x
	(tail xs))))
    (return (list x))))


!(#defun def-or-panic-tmp-fn (arg)
  (if arg
      (return `(progn
	 (def tmp ~(head arg))
	 (if (eq :err (head tmp))
	     ~(def-or-panic-tmp-fn (tail arg))
	     (progn))))
    (return `(panic (second tmp)))))

(def def-or-panica
     (builtin.fn
      (return
      `(progn
	 ~(def-or-panic-tmp-fn (tail args))
	 (def ~(head args) (second tmp))))))

!(#def-or-panica libc
  (shared-library "libc.so.6")
  (shared-library "libSystem.B.dylib"))

!(#def-or-panica malloc
     (extern-pointer libc "malloc"
		     '((sizet) pointer)))

!(#def-or-panica fopen
     (extern-pointer libc "fopen"
		     '((string string) pointer)))

!(#def-or-panica fread
     (extern-pointer libc "fread"
		     '((pointer sizet sizet pointer) sizet)))

!(#def-or-panica feof
     (extern-pointer libc "feof"
		     '((pointer) int)))

!(#def-or-panica fprintf
     (extern-pointer libc "fprintf"
		     '((pointer string) sizet)))

!(#def-or-panica fprintf-bytestring
     (extern-pointer libc "fprintf"
		     '((pointer string string) sizet)))

!(#def-or-panica stdin
  (extern-pointer libc "stdin" 'pointer)
  (extern-pointer libc "__stdinp" 'pointer))

!(#def-or-panica stdout
  (extern-pointer libc "stdout" 'pointer)
  (extern-pointer libc "__stdoutp" 'pointer))

!(#def-or-panica stderr
  (extern-pointer libc "stderr" 'pointer)
  (extern-pointer libc "__stderrp" 'pointer))

!(#defun print (val)
  (return (ignore `(fprintf-bytestring stdout "%s\n" ~(repr val)))))
