(defprod primitive (interf ((name symbol) &rest (formats (list entity))))
  (to-list () `(interf (:name ,name  :formats ,(synth-all to-list formats))))
  (to-html () (apply #'section nil 
                        (h4 nil (text "~a" (upper-camel name)))
                        (synth-all to-html formats))))

(defmacro database (name &body interf)
  `(defparameter ,name ,@interf))

