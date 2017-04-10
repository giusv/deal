(process create-white 
  (sync-server :name 'create-white 
               :input white-format
               :command  (with-extraction-and-validation white-format 
                             ((value (required) (minlen 2))
                              (type (required)))
                           (white (create-instance2 white-entity
                                                       (list (prop 'value) value
                                                             (prop 'type) type)))
                           ((http-response 201)))))
(process remove-white
  (let ((white-id (path-parameter 'white-id)))
    (sync-server :name 'remove-white 
                 :parameters (list white-id) 
                 :command (concat*
                           (white-valid
                            (validate2 white-id (list (regex "[0..9]+"))))
                           ((fork white-valid
                                  (concat* ((erase2 white-entity white-id))
                                           ((http-response 204)))
                                  (http-response 400)))))))

(process update-white
  (let* ((white-id (path-parameter 'white-id)))
    (sync-server 
     :name 'update-white
     :parameters (list white-id) 
     :input white-format
     :command (concat* (white-valid (validate2 white-id (list (regex "[0..9]+"))))
                       ((fork white-valid
                              (with-extraction-and-validation white-format 
                                  ((value (required) (minlen 2))
                                   (type (required)))
                                (old-white (fetch2 white-entity :id white-id))
                                ((fork (+null+ old-white)
                                       (http-response 404)
                                       (concat* 
                                        (new-white (update-instance2 white-entity old-white
                                                                       (list (prop 'value) value
                                                                             (prop 'type) type))) 
                                        ((http-response 200)))))) 
                              (http-response 403)))))))

(process read-white
  (let* ((white (path-parameter 'white)))
    (sync-server 
     :name 'read-white
     :parameters (list white) 
     :command (concat* (white (fetch2 white-entity :id white)) 
                       (json (rel-to-json2 white (list 'type 'value)))
                       ((http-response 200 :payload json))))))
(process list-whites
  (sync-server 
   :name 'list-whites
   :command (concat* (whites (fetch2 white-entity))
                     (json (rel-to-json2 whites 
                                           (list 'name 'address)))
                     ((http-response 200 :payload json)))))
(service white-service 
  (rest-service 'white-service 
                (url `(aia))
                (rest-post (url `(whitelist)) create-white)
                (rest-delete (url `(whitelist / id)) remove-white)
                (rest-put (url `(whitelist / id)) update-white)
                (rest-get (url `(whitelist)) list-whites)
                (rest-get (url `(whitelist / id)) read-white)))


