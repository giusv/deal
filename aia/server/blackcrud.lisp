(process create-black 
  (with-description* "Endpoint REST utilizzato per la creazione di un nuovo elemento della black-list"
    (sync-server :name 'crea-black 
                :input black-format
                :command  (with-extraction-and-validation black-format 
                              ((valore (required) (minlen 2))
                               (tipo (required)))
                            (black (create-instance2 black-entity
                                                     (list (prop 'valore) valore
                                                           (prop 'tipo) tipo)))
                            ((http-response 201))))))
(process remove-black
  (let ((id-black (path-parameter 'id-black)))
    (with-description* "Endpoint REST utilizzato per la cancellazione di un elemento della black-list"
      (sync-server :name 'rimuovi-black 
                  :parameters (list id-black) 
                  :command (concat*
                            (black-valid
                             (validate2 id-black (list (regex "[0..9]+"))))
                            ((fork black-valid
                                   (concat* ((erase2 black-entity id-black))
                                            ((http-response 204)))
                                   (http-response 400))))))))

(process update-black
  (let* ((id-black (path-parameter 'id-black)))
    (with-description* "Endpoint REST utilizzato per la modifica di un elemento della black-list"
      (sync-server 
      :name 'modifica-black
      :parameters (list id-black) 
      :input black-format
      :command (concat* (black-valid (validate2 id-black (list (regex "[0..9]+"))))
                        ((fork black-valid
                               (with-extraction-and-validation black-format 
                                   ((valore (required) (minlen 2))
                                    (tipo (required)))
                                 (old-black (fetch2 black-entity :id id-black))
                                 ((fork (+null+ old-black)
                                        (http-response 404)
                                        (concat* 
                                         (new-black (update-instance2 black-entity old-black
                                                                      (list (prop 'valore) valore
                                                                            (prop 'tipo) tipo))) 
                                         ((http-response 200)))))) 
                               (http-response 403))))))))

(process read-black
  (let* ((black (path-parameter 'black)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento dei dati di uno specifico elemento della black-list"
      (sync-server 
      :name 'leggi-black
      :parameters (list black) 
      :command (concat* (black (fetch2 black-entity :id black)) 
                        (json (rel-to-json2 black (list 'tipo 'valore)))
                        ((http-response 200 :payload json)))))))
(process list-blacks
  (with-description* "Endpoint REST utilizzato per l'ottenimento della black-list."
    (sync-server 
    :name 'lista-black
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


