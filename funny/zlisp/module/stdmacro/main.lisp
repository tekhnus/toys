
!(#defun def2 (left right val)
   (return `(progn
	      (def tmp ~val)
	      (def ~left (head tmp))
	      (def ~right (second tmp)))))


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
