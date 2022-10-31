(req
 (wrap-pointer-into-pointer "prelude" wrap-pointer-into-pointer)
 (derefw "prelude" derefw)
 (decons-pat "std" decons-pat)
 (eq "std" eq)
 (head "std" head)
 (repr "std" repr)
 (second "std" second)
 (third "std" third)
 (fourth "std" fourth)
 (fifth "std" fifth)
 (sixth "std" sixth)
 (panic "std" panic)
 (fprintf "libc" fprintf)
 (fprintf-bytestring "libc" fprintf-bytestring)
 (stdout "libc" stdout)
 (stderr "libc" stderr)
 (stdin "libc" stdin)
 (comp-prg-new "zlisp" compile-prog-new)
 (iprog "zlisp" init-prog)
 (eval-new "zlisp" eval-new)
 (rd "zlisp" read)
 (mres "zlisp" make-routine-with-empty-state)
 (psm "zlisp" prog-slice-make)
 (psan "zlisp" prog-slice-append-new)
 (cdm "zlisp" compdata-make))

!(req
  (ignore "std" ignore))

!(req
  (defun "stdmacro" defun)
  (fn "stdmacro" fn)
  (def2 "stdmacro" def2)
  (switchx "stdmacro" switchx))

(def readme "A basic REPL for zlisp.")

!(#defun repl
  (sl nsp pptr bpptr compdata bdrcompdata)
  (progn
  (def tmp (fprintf stdout "> "))
  !(#switchx (rd stdin)
	  ((:eof)
	   (return (fprintf stdout "\n")))
	  ((:ok datum)
           (def maybe-prog (comp-prg-new sl pptr bpptr datum compdata bdrcompdata))
           !(#switchx maybe-prog
                      ((:ok progxxx)
                       !(#switchx (eval-new sl nsp)
		                  ((:ok val ctxt)
		                   !(#ignore (fprintf-bytestring stdout "%s\n" (repr val)))
		                   (return (repl sl ctxt pptr bpptr compdata bdrcompdata)))
		                  ((:err msg)
		                   !(#ignore (fprintf-bytestring stderr "eval error: %s\n" msg))
		                   (return (repl sl nsp pptr bpptr compdata bdrcompdata)))))
                      ((:err msg)
                       !(#ignore (fprintf-bytestring stderr "compilation error at repl: %s\n" msg))
                       (return (repl sl nsp pptr bpptr compdata bdrcompdata)))))
	  ((:err msg)
	   !(#ignore (fprintf-bytestring stderr "read error: %s\n" msg))
	   (return (repl sl nsp pptr bpptr compdata bdrcompdata))))))

(def sl (psm 20000))
(def pptr (wrap-pointer-into-pointer (psan sl)))
(def bpptr (wrap-pointer-into-pointer (psan sl)))
(def rt (mres (derefw `(~bpptr int64))))
(def compdata (cdm))
(def bdrcompdata (cdm))
(def xxx (iprog sl pptr bpptr compdata bdrcompdata))
!(#ignore (repl sl rt pptr bpptr compdata bdrcompdata))

(export)
