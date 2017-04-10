(process create-black 
  (with-description* "Endpoint REST utilizzato per la creazione di un nuovo elemento della black-list"
    (sync-server :name 'create-black 
                :input black-format
                :command  (with-extraction-and-validation black-format 
                              ((value (required) (minlen 2))
                               (type (required)))
                            (black (create-instance2 black-entity
                                                     (list (prop 'value) value
                                                           (prop 'type) type)))
                            ((http-response 201))))))
(process remove-black
  (let ((black-id (path-parameter 'black-id)))
    (with-description* "Endpoint REST utilizzato per la cancellazione di un elemento della black-list"
      (sync-server :name 'remove-black 
                  :parameters (list black-id) 
                  :command (concat*
                            (black-valid
                             (validate2 black-id (list (regex "[0..9]+"))))
                            ((fork black-valid
                                   (concat* ((erase2 black-entity black-id))
                                            ((http-response 204)))
                                   (http-response 400))))))))

(process update-black
  (let* ((black-id (path-parameter 'black-id)))
    (with-description* "Endpoint REST utilizzato per la modifica di un elemento della black-list"
      (sync-server 
      :name 'update-black
      :parameters (list black-id) 
      :input black-format
      :command (concat* (black-valid (validate2 black-id (list (regex "[0..9]+"))))
                        ((fork black-valid
                               (with-extraction-and-validation black-format 
                                   ((value (required) (minlen 2))
                                    (type (required)))
                                 (old-black (fetch2 black-entity :id black-id))
                                 ((fork (+null+ old-black)
                                        (http-response 404)
                                        (concat* 
                                         (new-black (update-instance2 black-entity old-black
                                                                      (list (prop 'value) value
                                                                            (prop 'type) type))) 
                                         ((http-response 200)))))) 
                               (http-response 403))))))))

(process read-black
  (let* ((black (path-parameter 'black)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento dei dati di uno specifico elemento della black-list"
      (sync-server 
      :name 'read-black
      :parameters (list black) 
      :command (concat* (black (fetch2 black-entity :id black)) 
                        (json (rel-to-json2 black (list 'type 'value)))
                        ((http-response 200 :payload json)))))))
(process list-blacks
  (with-description* "Endpoint REST utilizzato per l'ottenimento della black-list."
    (sync-server 
    :name 'list-blacks
    :command (concat* (blacks (fetch2 black-entity))
                      (json (rel-to-json2 blacks 
                                          (list 'name 'address)))
                      ((http-response 200 :payload json))))))
(service black-service 
  (rest-service 'black-service 
                (url `(aia))
                (rest-post (url `(blacklist)) create-black)
                (rest-delete (url `(blacklist / id)) remove-black)
                (rest-put (url `(blacklist / id)) update-black)
                (rest-get (url `(blacklist)) list-blacks)
                (rest-get (url `(blacklist / id)) read-black)))


