(defmacro defservice (name serv)
  `(defparameter ,name ,serv))


(defprod service (rest ((name symbol) &rest (processes (list process))))
  (to-list () `(service :name ,name :processes (synth-all to-list processes)))
  (to-html () (div nil (text "Servizio costituito dai seguenti processi:")
                   (synth-all to-html processes))))
