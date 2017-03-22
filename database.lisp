(defprod primitive (db ((name symbol) &rest (entities (list entity))))
  (to-list () `(db (:name ,name  :entities ,(synth-all to-list entities))))
  (to-html () (apply #'multitags 
               (synth-all to-html entities))))

(defmacro database (name &body db)
  `(defparameter ,name ,@db))
