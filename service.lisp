(defmacro service (name &body serv)
  `(defparameter ,name ,@serv))



(defprod service (rest-service ((name symbol) (url url)
                                &rest (endpoints (list endpoint))))
  (to-list () `(rest-service (:name ,name :url ,(synth to-list url) :endpoints ,(synth-all to-list endpoints))))
  (to-html () (multitags
               (text "Servizio basato all'URL ")
               (synth to-url url)
               (text " e costituito dai seguenti endpoint:")
               (apply #'p nil (synth-all to-html endpoints)))))


(defmacro def-rest-endpoint (name)
  (let ((full-name (symb "REST-" name)))
    `(defprod endpoint (,full-name ((url expression) 
                                    (process process)))
       (to-list () (list ',full-name (list :url (synth to-list url) 
                                           :process (synth to-list process))))
       (to-html () (multitags 
                    (section nil 
                             (h3 nil (text "Endpoint REST con metodo ~a all'URL" ',name)
                                 (code nil (synth to-url url) ))
                             (p nil (synth to-html process))))))))

(def-rest-endpoint get)
(def-rest-endpoint post)
(def-rest-endpoint put)
(def-rest-endpoint delete)


