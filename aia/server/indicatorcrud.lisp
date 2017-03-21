(process create-indicator
  (sync-server 
   :name 'create-indicator
   :input indicator-format
   :command (concat* (indicator-code (extract2 (prop 'codice) indicator-format)) 
                     (indicator-start-date (extract2 (prop 'data-inizio) indicator-format)) 
                     (result (translate2 indicator-code :pre (+false+) :post (+true+)))
                     ((fork (+equal+ result (const "Success"))
                            (concat* (indic (create-instance2 indicator-entity 
                                                              (list (prop 'id) (autokey)
                                                                    (prop 'code) result
                                                                    (prop 'start-date) indicator-start-date)))
                                     ((persist indic))
                                     ((http-response 201 :payload result)))
                            (http-response 403))))))

(process remove-indicator
  (remove* indicator indicator-entity ((regex "[0..9]+"))))

(process modify-indicator
         (let* ((comp (path-parameter 'indicator)))
           (sync-server 
            :name 'modify-indicator
            :parameters (list comp) 
            :input indicator-format
            :command (concat* (comp-valid (validate2 comp (list (regex "[0..9]+"))))
                              (comp-name (extract2 (prop 'name) indicator-format))
                              (comp-add (extract2 (prop 'address) indicator-format))
                              (comp-name-valid (validate2 comp-name (list (required) (minlen 2) (maxlen 5))))
                              (comp-add-valid (validate2 comp-add (list (regex "[0..9]+"))))
                              ((fork (+and+ comp-valid comp-name-valid comp-add-valid) 
                                     (concat* 
                                      (indicator (create-instance2 indicator-entity 
                                                                 (list (prop 'id) (autokey) 
                                                                       (prop 'name) comp-name
                                                                       (prop 'address) comp-add))) 
                                      ((persist indicator)) 
                                      ((http-response 201 :payload indicator)))
                                     (http-response 403)))))))

(service indicator-service 
         (rest-service 'indicator-service 
                       (url `(aia))
                       (rest-post (url `(compagnie)) create-indicator)
                       (rest-delete (url `(compagnie / id)) remove-indicator)
                       (rest-put (url `(compagnie / id)) modify-indicator)))


