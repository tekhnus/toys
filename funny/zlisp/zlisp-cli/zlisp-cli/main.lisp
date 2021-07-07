(def readme "A basic REPL for zlisp.")

(defn eval-stream (fd nsp)
  (switch (read fd)
	  ((:eof)
	   nsp)
	  ((:ok datum)
	   (switch (eval datum nsp)
		   ((:context ctxt)
		    (eval-stream fd ctxt))))))

(defn eval-script (filename nsp)
  (def fd (fopen filename "r"))
  (eval-stream fd nsp))

(defn repl
  (nsp)
  (def tmp (fprintf stdout "> "))
  (switch (read stdin)
	  ((:eof)
	   (fprintf stdout "\n"))
	  ((:ok datum)
	   (switch (eval datum nsp)
		   ((:ok val)
		    (ignore (fprintf-bytestring stdout "%s\n" (repr val)))
		    (repl nsp))
		   ((:err msg)
		    (ignore (fprintf-bytestring stderr "eval error: %s\n" msg))
		    (repl nsp))
		   ((:context ctxt)
		    (repl ctxt))))
	  ((:err msg)
	   (ignore (fprintf-bytestring stderr "read error: %s\n" msg))
	   (repl nsp))))

(def-or-panic prelude_ (prelude))
(ignore (repl prelude_))
