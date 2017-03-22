(defprod application (rest-application ((name symbol) &rest (services (list service))))
  (to-list () `(application (:name ,name  :services ,(synth-all to-list services))))
  (to-html () (apply #'multitags 
               (synth-all to-html services))))

(defmacro application (name &body app)
  `(defparameter ,name ,@app))
