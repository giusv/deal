(defprod primitive (role ((name symbol) &rest (children (list role))))
  (to-list () `(text (:role ,role :children ,(synth-all to-list children))))
  (to-html () (multitags 
               (text "Ruolo di nome ~a, con potere di creazione/modifica/cancellazione sui ruoli ~{~a~^, ~}" (upper-camel name) (mapcar #'upper-camel (synth-all name children))))))



(defmacro defrole (name &body role)
  `(defparameter ,name ,@role))


(defprod element (with-roles ((roles (list roles))
                              (element element)))
  (to-list () `(with-roles (:roles ,(synth-all to-list roles) :element ,(synth to-list element))))
  (to-html (path) (multitags (text "Tale elemento è accessibile ai seguenti ruoli:")
                             (apply #'ul nil (mapcar #'listify (synth-all to-html roles))) 
                             (synth to-html element path)))
  (to-brief (path) (synth to-brief element path))
  (toplevel () (list (synth toplevel element)))
  (req (path) (synth req element path)))
