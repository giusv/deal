(process create-company
  (create* company company-format (prop 'id)
           ((name (prop 'name) (prop 'name) ((required) (minlen 2)))
            (address (prop 'address) (prop 'address) ((required) (minlen 2))))
           nil))

(process remove-company
  (remove* company company-entity ((regex "[0..9]+"))))

(process modify-company
         (let* ((comp (path-parameter 'company)))
           (sync-server 
            :name 'modify-company
            :parameters (list comp) 
            :input company-format
            :command (concat* (comp-valid (validate2 comp (list (regex "[0..9]+"))))
                              (comp-name (extract2 (prop 'name) company-format))
                              (comp-add (extract2 (prop 'address) company-format))
                              (comp-name-valid (validate2 comp-name (list (required) (minlen 2) (maxlen 5))))
                              (comp-add-valid (validate2 comp-add (list (regex "[0..9]+"))))
                              ((fork (+and+ comp-valid comp-name-valid comp-add-valid) 
                                     (concat* 
                                      (company (create-instance2 company-entity 
                                                                 (list (prop 'id) (autokey) 
                                                                       (prop 'name) comp-name
                                                                       (prop 'address) comp-add))) 
                                      ((persist company)) 
                                      ((http-response 201 :payload company)))
                                     (http-response 403)))))))

(service company-service 
         (rest-service 'company-service 
                       (url `(aia))
                       (rest-post (url `(compagnie)) create-company)
                       (rest-delete (url `(compagnie / id)) remove-company)
                       (rest-put (url `(compagnie / id)) modify-company)))


