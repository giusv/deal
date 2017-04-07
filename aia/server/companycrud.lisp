;; (process create-company
;;   (create* company company-format (prop 'id)
;;            ((name (prop 'name) (prop 'name) ((required) (minlen 2)))
;;             (address (prop 'address) (prop 'address) ((required) (minlen 2))))
;;            nil))
(process create-company 
  (sync-server :name 'create-company 
               :input company-format
               :command  (with-extraction-and-validation company-format 
                             ((name (required) (minlen 2))
                              (address (required)))
                           (company (create-instance2 company-entity
                                                       (list (prop 'name) name
                                                             (prop 'address) address)))
                           ((http-response 201)))))

;; (process remove-company
;;   (remove* company company-entity ((regex "[0..9]+"))))
(process remove-company
  (let ((company-id (path-parameter 'company-id)))
    (sync-server :name 'remove-company 
                 :parameters (list company-id) 
                 :command (concat*
                           (company-valid
                            (validate2 company-id (list (regex "[0..9]+"))))
                           ((fork company-valid
                                  (concat* ((erase2 company-entity company-id))
                                           ((http-response 204)))
                                  (http-response 400)))))))

(process update-company
  (let* ((company-id (path-parameter 'company-id)))
    (sync-server 
     :name 'update-company
     :parameters (list company-id) 
     :input company-format
     :command (concat* (company-valid (validate2 company-id (list (regex "[0..9]+"))))
                       ((fork company-valid
                              (with-extraction-and-validation company-format 
                                  ((name (required) (minlen 2))
                                   (address (required)))
                                (old-company (fetch2 company-entity :id company-id))
                                ((fork (+null+ old-company)
                                       (http-response 404)
                                       (concat* 
                                        (new-company (update-instance2 company-entity old-company
                                                                       (list (prop 'name) name
                                                                             (prop 'address) address))) 
                                        ((http-response 200)))))) 
                              (http-response 403)))))))

(process read-company
  (let* ((comp (path-parameter 'company)))
    (sync-server 
     :name 'read-company
     :parameters (list comp) 
     :command (concat* (company (fetch2 company-entity :id comp)) 
                       (json (rel-to-json2 company (list 'name 'address)))
                       ((http-response 200 :payload json))))))
(process list-companies
  (sync-server 
   :name 'list-companies
   :command (concat* (companies (fetch2 company-entity))
                     (json (rel-to-json2 companies 
                                           (list 'name 'address)))
                     ((http-response 200 :payload json)))))
(service company-service 
  (rest-service 'company-service 
                (url `(aia))
                (rest-post (url `(compagnie)) create-company)
                (rest-delete (url `(compagnie / id)) remove-company)
                (rest-put (url `(compagnie / id)) update-company)
                (rest-get (url `(compagnie)) list-companies)
                (rest-get (url `(compagnie / id)) read-company)))


