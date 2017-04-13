(process create-document 
  (let* ((id-dossier (path-parameter 'id-dossier)))
    (with-description* "Endpoint REST utilizzato per la creazione di un documento relativo a uno specifico dossier"
      (sync-server :name 'crea-documento 
                  :input document-format
                  :parameters (list id-dossier)
                  :command  (with-extraction-and-validation document-format 
                                ((tipo (required) (minlen 2))
                                 (binario (required)))
                              (document (create-instance2 document-entity
                                                          (list (prop 'id-dossier) id-dossier
                                                                (prop 'tipo) tipo
                                                                (prop 'binario) binario
                                                                (prop 'stato) (const "new"))))
                              ((http-response 201)))))))

(process remove-document
  (let* ((dossier (path-parameter 'dossier))
         (documento (path-parameter 'documento)))
    (with-description* "Endpoint REST utilizzato per la cancellazione di un documento relativo a uno specifico dossier"
      (sync-server
      :name 'rimuovi-documento
      :parameters (list documento) 
      :command (concat* (document-valid (validate2 documento (list (regex "[0..9]+"))))
                        ((fork document-valid
                               (concat* 
                                ((erase2 document-entity documento))
                                ((http-response 204)))
                               (http-response 400))))))))

(process update-document
  (let* ((id-dossier (path-parameter 'id-dossier))
         (id-documento (path-parameter 'id-documento)))
    (with-description* "Endpoint REST utilizzato per la modifica di un documento relativo a uno specifico dossier"
      (sync-server 
      :name 'modifica-documento
      :parameters (list id-dossier id-documento) 
      :input document-format
      :command (concat* (document-valid (validate2 id-documento (list (regex "[0..9]+"))))
                        ((fork document-valid
                               (with-extraction-and-validation document-format 
                                   ((tipo (required) (minlen 2))
                                    (cue (required))
                                    (binario (required)))
                                 (old-document (fetch2 document-entity :id id-documento))
                                 ((fork (+not+ (+null+ old-document))
                                        (concat* 
                                         (new-document (update-instance2 document-entity old-document
                                                                         (list (prop 'tipo) tipo
                                                                               (prop 'cue) cue
                                                                               (prop 'binario) binario))) 
                                         ((http-response 200 :payload (value new-document))))
                                        (http-response 404))))
                               (http-response 403))))))))
(process read-document
  (let* ((id-dossier (path-parameter 'id-dossier))
         (id-documento (path-parameter 'documento)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento di informazioni relative a un documento di uno specifico dossier"
      (sync-server 
      :name 'leggi-documento
      :parameters (list id-dossier id-documento) 
      :command (concat* (document (fetch2 document-entity :id id-documento)) 
                        (json (rel-to-json2 document (list 'tipo 'binario 'stato)))
                        ((http-response 200 :payload json)))))))
(process list-documents
  (let* ((id-dossier (path-parameter 'id-dossier)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento dei documenti relativi a uno specifico dossier"
      (sync-server 
      :name 'lista-documenti
      :command (concat* (documents (query2 (equijoin (relation 'dossier-entity) 
                                                     (relation 'document-entity)
                                                     :id-dossier)))
                        (json (rel-to-json2 documents 
                                            (list 'tipo 'binario 'stato)))
                        ((http-response 200 :payload json)))))))


(service document-service 
         (rest-service 'servizio-documenti
                       (url `(aia))
                       (rest-post (url `(documenti)) create-document)
                       (rest-delete (url `(documenti / id)) remove-document)
                       (rest-put (url `(documenti / id)) update-document)))


