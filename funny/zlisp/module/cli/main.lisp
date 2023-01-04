(req
 (wrap-pointer-into-pointer "prelude" wrap-pointer-into-pointer)
 (derefw2 "prelude" derefw2)
 (decons-pat "std" decons-pat)
 (eq "std" eq)
 (head "std" head)
 (repr "std" repr)
 (list-at "std" list-at)
 (panic "std" panic)
 (fprintf "libc" fprintf)
 (fprintf-bytestring "libc" fprintf-bytestring)
 (stdout "libc" stdout)
 (stderr "libc" stderr)
 (stdin "libc" stdin)
 (zlisp "zlisp")
 (comp-prg-new "zlisp" compile-prog-new)
 (iprog "zlisp" init-prog)
 (eval-new "zlisp" eval-new)
 (rd "zlisp" read)
 (repr-pointer "zlisp" repr-pointer)
 (mres "zlisp" make-routine-with-empty-state)
 (psm "zlisp" prog-slice-make)
 (psan "zlisp" prog-slice-append-new)
 (cdm "zlisp" compdata-make))

!(req
  (ignore "std" ignore))

!(req
  (switchx2 "stdmacro" switchx2))

(def readme "A basic REPL for zlisp.")

(builtin.defn repl
  (sl nsp pptr bpptr compdata bdrcompdata)
  (progn
  (def tmp (fprintf stdout "> "))
  !(#switchx2 (zlisp @slash rd stdin) (
	  ((:eof)
	   (return (fprintf stdout "\n")))
	  ((:ok datum)
           (def maybe-prog (zlisp @slash comp-prg-new sl pptr bpptr datum compdata bdrcompdata))
           !(#switchx2 maybe-prog (
                      ((:ok progxxx)
                       !(#switchx2 (zlisp @slash eval-new sl nsp) (
		                  ((:ok val ctxt)
		                   !(#ignore (fprintf-bytestring stdout "%s\n" (zlisp @slash repr-pointer val)))
		                   (return (repl sl ctxt pptr bpptr compdata bdrcompdata)))
		                  ((:err msg)
		                   !(#ignore (fprintf-bytestring stderr "eval error: %s\n" msg))
		                   (return (repl sl nsp pptr bpptr compdata bdrcompdata))))))
                      ((:err msg)
                       !(#ignore (fprintf-bytestring stderr "compilation error at repl: %s\n" msg))
                       (return (repl sl nsp pptr bpptr compdata bdrcompdata))))))
	  ((:err msg)
	   !(#ignore (fprintf-bytestring stderr "read error: %s\n" msg))
	   (return (repl sl nsp pptr bpptr compdata bdrcompdata)))))))

(def sl (zlisp @slash psm 20000))
(def pptr (wrap-pointer-into-pointer (zlisp @slash psan sl)))
(def bpptr (wrap-pointer-into-pointer (zlisp @slash psan sl)))
(def rt (zlisp @slash mres (derefw2 bpptr 'int64)))
(def compdata (zlisp @slash cdm))
(def bdrcompdata (zlisp @slash cdm))
(def xxx (zlisp @slash iprog sl pptr bpptr compdata bdrcompdata))
!(#ignore (repl sl rt pptr bpptr compdata bdrcompdata))
