(defprod element (with-doc ((introduction string)
                            (element element)
                            &optional (conclusion string)))
  (to-list () `(with-doc (:introduction (synth to-list introduction) :element (synth to-list element)) :conclusion (synth to-list conclustion)))
  (to-html (path) (multitags 
                   (strong nil (text "~a" introduction))
                   (p nil (synth to-html element path))
                   (if conclusion 
                       (strong nil (text "~a" conclusion))
                       (empty))))
  (to-brief (path) (synth to-brief element path))
  (toplevel () (list (synth toplevel element)))
  (req (path) (synth req element path)))

(defprod process (with-doc* ((introduction string)
                             (process process)
                             &optional (conclusion string)))
  (to-list () `(with-doc* (:introduction (synth to-list introduction) :process (synth to-list process)) :conclusion (synth to-list conclustion)))
  (to-html () (multitags
               (strong nil (text "~a" introduction))
               (p nil (synth to-html process))
               (if conclusion 
                   (strong nil (text "~a" conclusion))
                   (empty)))) 
  (toplevel () (list (synth toplevel process))))
