!(require "stdmacro")
(require "std")
(require "libc")
(require "zlisp")

(def readme "A basic REPL for zlisp.")

!(#defun repl
  (nsp)
  (def tmp (fprintf stdout "> "))
  !(#switchx (read stdin)
	  ((:eof)
	   (return (fprintf stdout "\n")))
	  ((:ok datum)
	   !(#switchx (eval nsp (compile-prog `(~datum)))
		   ((:ok val ctxt)
		    !(#ignore (fprintf-bytestring stdout "%s\n" (repr val)))
		    (return (repl ctxt)))
		   ((:err msg)
		    !(#ignore (fprintf-bytestring stderr "eval error: %s\n" msg))
		    (return (repl nsp)))))
	  ((:err msg)
	   !(#ignore (fprintf-bytestring stderr "read error: %s\n" msg))
	   (return (repl nsp)))))

(def builtins_ (builtins))
!(#ignore (repl builtins_))
