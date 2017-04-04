(defprod primitive (role ((name symbol) &rest (children (list role))))
  (to-list () `(text (:role ,role :children ,(synth-all to-list children))))
  (to-html () (multitags 
               (text "Ruolo di nome ~a, con potere di creazione/modifica/cancellazione sui ruoli ~{~a~^, ~}" (upper-camel name) (mapcar #'upper-camel (synth-all name children))))))



(defmacro defrole (name &body role)
  `(defparameter ,name ,@role))


;; (defrole user (role 'user))

;; (role 'user)
