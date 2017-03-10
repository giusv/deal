(defprod element (with-doc ((introduction string)
                            (element element)
                            &optional (conclusion string)))
  (to-list () `(with-doc (:introduction (synth to-list introduction) :element (synth to-list element)) :conclusion (synth to-list conclustion)))
  (to-html (path) (div nil 
                       (div nil (strong nil (text "~a" introduction)))
                       (synth to-html element path)
                       (if conclusion 
                           (span nil (strong nil (text "~a" conclusion)))
                           (empty))))
  (to-brief (path) (synth to-brief element path))
  (toplevel () (list (synth toplevel element)))
  (req (path) (synth req element path)))

(defprod process (with-doc* ((introduction string)
                             (process process)
                             &optional (conclusion string)))
  (to-list () `(with-doc* (:introduction (synth to-list introduction) :process (synth to-list process)) :conclusion (synth to-list conclustion)))
  (to-html () (div nil 
                       (div nil (strong nil (text "~a" introduction)))
                       (synth to-html process)
                       (if conclusion 
                           (span nil (strong nil (text "~a" conclusion)))
                           (empty)))) 
  (toplevel () (list (synth toplevel process))))
