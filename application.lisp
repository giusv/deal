(defprod application (rest-application ((name symbol) &rest (services (list service))))
  (to-list () `(application (:name ,name  :services ,(synth-all to-list services))))
  (to-html () (apply #'multitags 
                     (synth-all to-html services))))

;; (defprod application (backend-application ((name symbol) 
;;                                            (services (list service))
;;                                            (batches (list batch))))
;;   (to-list () `(application (:name ,name :services ,(synth-all to-list services)
;;                                    :batches ,(synth-all to-list batches))))
;;   (to-html () (apply #'multitags 
;;                      (append (synth-all to-html services)
;;                              (synth-all to-html batches)))))

(defmacro application (name &body app)
  `(defparameter ,name ,@app))
