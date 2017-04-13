;; (process create-company
;;   (create* company company-format (prop 'id)
;;            ((name (prop 'nome) (prop 'nome) ((required) (minlen 2)))
;;             (indirizzo (prop 'indirizzo) (prop 'indirizzo) ((required) (minlen 2))))
;;            nil))
(process create-company 
  (with-description* "Endpoint REST utilizzato per la creazione di una nuova compagnia." 
    (sync-server :name 'crea-compagnia 
                :input company-format
                :command  (with-extraction-and-validation company-format 
                              ((nome (required) (minlen 2))
                               (indirizzo (required)))
                            (company (create-instance2 company-entity
                                                       (list (prop 'nome) nome
                                                             (prop 'indirizzo) indirizzo)))
                            ((http-response 201))))))

;; (process remove-company
;;   (remove* company company-entity ((regex "[0..9]+"))))
(process remove-company
  (let ((company-id (path-parameter 'id-compagnia)))
    (with-description* "Endpoint REST utilizzato per la rimozione di una compagnia." 
      (sync-server :name 'rimuovi-compagnia 
                  :parameters (list company-id) 
                  :command (concat*
                            (company-valid
                             (validate2 company-id (list (regex "[0..9]+"))))
                            ((fork company-valid
                                   (concat* ((erase2 company-entity company-id))
                                            ((http-response 204)))
                                   (http-response 400))))))))

(process update-company
  (let* ((company-id (path-parameter 'id-compagnia)))
    (with-description* "Endpoint REST utilizzato per la modifica dei dati di una nuova compagnia." 
      (sync-server 
      :name 'modifica-compagnia
      :parameters (list company-id) 
      :input company-format
      :command (concat* (company-valid (validate2 company-id (list (regex "[0..9]+"))))
                        ((fork company-valid
                               (with-extraction-and-validation company-format 
                                   ((nome (required) (minlen 2))
                                    (indirizzo (required)))
                                 (old-company (fetch2 company-entity :id company-id))
                                 ((fork (+null+ old-company)
                                        (http-response 404)
                                        (concat* 
                                         (new-company (update-instance2 company-entity old-company
                                                                        (list (prop 'nome) nome
                                                                              (prop 'indirizzo) indirizzo))) 
                                         ((http-response 200)))))) 
                               (http-response 403))))))))

(process read-company
  (let* ((comp (path-parameter 'compagnia)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento dei dati di una compagnia." 
      (sync-server 
      :name 'leggi-compagnia
      :parameters (list comp) 
      :command (concat* (company (fetch2 company-entity :id comp)) 
                        (json (rel-to-json2 company (list 'nome 'indirizzo)))
                        ((http-response 200 :payload json)))))))
(process list-companies
  (with-description* "Endpoint REST utilizzato per l'ottenimento della lista di tutte le compagnie." 
    (sync-server 
    :name 'lista-compagnie
    :command (concat* (companies (fetch2 company-entity))
                      (json (rel-to-json2 companies 
                                          (list 'nome 'indirizzo)))
                      ((http-response 200 :payload json))))))
(service company-service 
  (rest-service 'servizio-compagnie 
                (url `(aia))
                (rest-post (url `(compagnie)) create-company)
                (rest-delete (url `(compagnie / id)) remove-company)
                (rest-put (url `(compagnie / id)) update-company)
                (rest-get (url `(compagnie)) list-companies)
                (rest-get (url `(compagnie / id)) read-company)))


