(process create-document 
  (let* ((dossier-id (path-parameter 'dossier-id)))
    (with-description* "Endpoint REST utilizzato per la creazione di un documento relativo a uno specifico dossier"
      (sync-server :name 'create-document 
                  :input document-format
                  :parameters (list dossier-id)
                  :command  (with-extraction-and-validation document-format 
                                ((type (required) (minlen 2))
                                 (binary (required)))
                              (document (create-instance2 document-entity
                                                          (list (prop 'dossier-id) dossier-id
                                                                (prop 'type) type
                                                                (prop 'binary) binary
                                                                (prop 'state) (const "new"))))
                              ((http-response 201)))))))

(process remove-document
  (let* ((dossier (path-parameter 'dossier))
         (document (path-parameter 'document)))
    (with-description* "Endpoint REST utilizzato per la cancellazione di un documento relativo a uno specifico dossier"
      (sync-server
      :name 'remove-document
      :parameters (list document) 
      :command (concat* (document-valid (validate2 document (list (regex "[0..9]+"))))
                        ((fork document-valid
                               (concat* 
                                ((erase2 document-entity document))
                                ((http-response 204)))
                               (http-response 400))))))))

(process update-document
  (let* ((dossier-id (path-parameter 'dossier-id))
         (document-id (path-parameter 'document-id)))
    (with-description* "Endpoint REST utilizzato per la modifica di un documento relativo a uno specifico dossier"
      (sync-server 
      :name 'update-document
      :parameters (list dossier-id document-id) 
      :input document-format
      :command (concat* (document-valid (validate2 document-id (list (regex "[0..9]+"))))
                        ((fork document-valid
                               (with-extraction-and-validation document-format 
                                   ((type (required) (minlen 2))
                                    (cue (required))
                                    (binary (required)))
                                 (old-document (fetch2 document-entity :id document-id))
                                 ((fork (+not+ (+null+ old-document))
                                        (concat* 
                                         (new-document (update-instance2 document-entity old-document
                                                                         (list (prop 'type) type
                                                                               (prop 'cue) cue
                                                                               (prop 'binary) binary))) 
                                         ((http-response 200 :payload (value new-document))))
                                        (http-response 404))))
                               (http-response 403))))))))
(process read-document
  (let* ((dossier-id (path-parameter 'dossier-id))
         (document-id (path-parameter 'document)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento di informazioni relative a un documento di uno specifico dossier"
      (sync-server 
      :name 'read-document
      :parameters (list dossier-id document-id) 
      :command (concat* (document (fetch2 document-entity :id document-id)) 
                        (json (rel-to-json2 document (list 'type 'binary 'state)))
                        ((http-response 200 :payload json)))))))
(process list-documents
  (let* ((dossier-id (path-parameter 'dossier-id)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento dei documenti relativi a uno specifico dossier"
      (sync-server 
      :name 'list-documents
      :command (concat* (documents (query2 (equijoin (relation 'dossier-entity) 
                                                     (relation 'document-entity)
                                                     :dossier-id)))
                        (json (rel-to-json2 documents 
                                            (list 'type 'binary 'state)))
                        ((http-response 200 :payload json)))))))


(service document-service 
         (rest-service 'document-service 
                       (url `(aia))
                       (rest-post (url `(documenti)) create-document)
                       (rest-delete (url `(documenti / id)) remove-document)
                       (rest-put (url `(documenti / id)) update-document)))


