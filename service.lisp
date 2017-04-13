(defmacro service (name &body serv)
  `(defparameter ,name ,@serv))


(defprod service (batch-service ((name symbol)
                                 &rest (batches (list batch))))
  (to-list () `(batch-service (:name ,name :batches ,(synth-all to-list batches))))
  (to-html () (apply #'multitags (synth-all to-html batches))))

(defprod service (rest-service ((name symbol) (url url)
                                &rest (endpoints (list endpoint))))
  (to-list () `(rest-service (:name ,name :url ,(synth to-list url) :endpoints ,(synth-all to-list endpoints))))
  (to-html () ;; (multitags
              ;;  (text "Servizio basato all'URL ")
              ;;  (synth to-url url)
              ;;  (text " e costituito dai seguenti endpoint:")
              ;;  (apply #'p nil (synth-all to-html endpoints)))
           (apply #'multitags (synth-all to-html endpoints))))

(defprod service (batch-endpoint ((name symbol) 
                                  (process process))) 
  (to-list () `(batch-endpoint (:name ,name :process ,(synth to-list process))))
  (to-html () (section nil 
                       (h4 nil (text "Endpoint Batch: ~a " (lower-camel name)))
                       (p nil (synth to-html process)))))

(defmacro def-rest-endpoint (name)
  (let ((full-name (symb "REST-" name)))
    `(defprod endpoint (,full-name ((url expression) 
                                    (process process)))
       (to-list () (list ',full-name (list :url (synth to-list url) 
                                           :process (synth to-list process))))
       (to-html () (section nil 
                            (h4 nil (text "Endpoint REST: ~a " ',name)
                                (code nil (synth to-url url) ))
                            (p nil (synth to-html process)))))))

(def-rest-endpoint get)
(def-rest-endpoint post)
(def-rest-endpoint put)
(def-rest-endpoint delete)


