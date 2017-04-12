(defprod primitive (db ((name symbol) &rest (entities (list entity))))
  (to-list () `(db (:name ,name  :entities ,(synth-all to-list entities))))
  (to-html () (apply #'section nil 
                        (h4 nil (text "~a" (upper-camel name)))
                        (mapcar #'(lambda (entity)
                                    (section nil
                                             (h5 (list :id (upper-camel (synth name entity))) (text "~a" (upper-camel (synth name entity))))
                                             (synth to-html entity)))
                                entities))))

(defmacro database (name &body db)
  `(defparameter ,name ,@db))
