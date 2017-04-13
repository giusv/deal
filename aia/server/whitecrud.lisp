(process create-white 
  (with-description* "Endpoint REST utilizzato per la creazione di un nuovo elemento della white-list"
    (sync-server :name 'crea-white 
                :input white-format
                :command  (with-extraction-and-validation white-format 
                              ((valore (required) (minlen 2))
                               (tipo (required)))
                            (white (create-instance2 white-entity
                                                     (list (prop 'valore) valore
                                                           (prop 'tipo) tipo)))
                            ((http-response 201))))))
(process remove-white
  (let ((id-white (path-parameter 'id-white)))
    (with-description* "Endpoint REST utilizzato per la cancellazione di un elemento della white-list"
      (sync-server :name 'rimuovi-white 
                  :parameters (list id-white) 
                  :command (concat*
                            (white-valid
                             (validate2 id-white (list (regex "[0..9]+"))))
                            ((fork white-valid
                                   (concat* ((erase2 white-entity id-white))
                                            ((http-response 204)))
                                   (http-response 400))))))))

(process update-white
  (let* ((id-white (path-parameter 'id-white)))
    (with-description* "Endpoint REST utilizzato per la modifica di un elemento della white-list"
      (sync-server 
      :name 'modifica-white
      :parameters (list id-white) 
      :input white-format
      :command (concat* (white-valid (validate2 id-white (list (regex "[0..9]+"))))
                        ((fork white-valid
                               (with-extraction-and-validation white-format 
                                   ((valore (required) (minlen 2))
                                    (tipo (required)))
                                 (old-white (fetch2 white-entity :id id-white))
                                 ((fork (+null+ old-white)
                                        (http-response 404)
                                        (concat* 
                                         (new-white (update-instance2 white-entity old-white
                                                                      (list (prop 'valore) valore
                                                                            (prop 'tipo) tipo))) 
                                         ((http-response 200)))))) 
                               (http-response 403))))))))

(process read-white
  (let* ((white (path-parameter 'white)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento dei dati di uno specifico elemento della white-list"
      (sync-server 
      :name 'leggi-white
      :parameters (list white) 
      :command (concat* (white (fetch2 white-entity :id white)) 
                        (json (rel-to-json2 white (list 'tipo 'valore)))
                        ((http-response 200 :payload json)))))))
(process list-whites
  (with-description* "Endpoint REST utilizzato per l'ottenimento della white-list."
    (sync-server 
    :name 'lista-white
    :command (concat* (whites (fetch2 white-entity))
                      (json (rel-to-json2 whites 
                                          (list 'name 'address)))
                      ((http-response 200 :payload json))))))
(service white-service 
  (rest-service 'white-service 
                (url `(aia))
                (rest-post (url `(whitelist)) create-white)
                (rest-delete (url `(whitelist / id)) remove-white)
                (rest-put (url `(whitelist / id)) update-white)
                (rest-get (url `(whitelist)) list-whites)
                (rest-get (url `(whitelist / id)) read-white)))


