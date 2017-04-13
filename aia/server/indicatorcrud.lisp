;; (defun create-indicator-aux (id)
;;   (with-extraction-and-validation company-format 
;;       ((codice (required) (minlen 2))
;;        (data-inizio (required)))
;;     (result (translate2 codice))
;;     ((fork (+null+ result)
;;            (http-response 403)
;;            (concat* (indicator-record (create-instance2 
;;                                        indicator-entity 
;;                                        (list (prop 'name) (attr result 'name)
;;                                              (prop 'codice-sorgente) codice
;;                                              (prop 'codice-oggetto) (attr result 'codice)
;;                                              (prop 'data-inizio) data-inizio))) 
;;                     ((map-command (mu* parametro 
;;                                        (concat*
;;                                         (parametro (create-instance2 
;;                                                      parameter-entity
;;                                                      (list (prop 'id-indicatore) (attr indicator-record 'id-indicatore)
;;                                                            (prop 'name) (attr (argument parameter) 'name)
;;                                                            (prop 'valore) (attr (argument parametro) 'valore))))))
;;                                   (attr result 'parametri)))
;;                     ((http-response 201 :payload result))))))


;;   ;; (concat* (indicator-code (extract2 (prop 'text) indicator-format))
;;   ;;          (indicator-code-valid (validate2 indicator-code (list (required) (minlen 2))))
;;   ;;          (indicator-data-inizio (extract2 (prop 'data-inizio) indicator-format))
;;   ;;          (indicator-data-inizio-valid (validate2 indicator-data-inizio (list (required) (minlen 2))))
;;   ;;          ((fork
;;   ;;            (+and+ indicator-code-valid indicator-data-inizio-valid)
;;   ;;            (concat* (result (translate2 indicator-code))
;;   ;;                     ((fork (+equal+ result (const "Success"))
;;   ;;                            (concat* (indicator-record (create-instance2 indicator-entity 
;;   ;;                                                                         (list (prop 'id) id
;;   ;;                                                                               (prop 'code) (attr result 'code)
;;   ;;                                                                               (prop 'data-inizio) indicator-data-inizio)))
;;   ;;                                     ((persist indicator-record))
;;   ;;                                     ((map-command (mu* parametro 
;;   ;;                                                        (concat*
;;   ;;                                                         (parametro (create-instance2 parameter-entity
;;   ;;                                                                                       (list (prop 'id) (autokey)
;;   ;;                                                                                             (prop 'id-indicatore) (attr indicator-record 'id)
;;   ;;                                                                                             (prop 'nome) (attr (argument parametro) 'nome)
;;   ;;                                                                                             (prop 'valore) (attr (argument parametro) 'valore))))
;;   ;;                                                         ((persist parameter))))
;;   ;;                                                   (attr result 'parametri)
;;   ;;                                                   ))
;;   ;;                                     ((http-response 201 :payload result)))
;;   ;;                            (http-response 403))))
;;   ;;            (http-response 403))))
;;   )

(process create-indicator 
  (with-description* "Endpoint REST utilizzato per la creazione di un nuovo indicatore e dei suoi relativi parametri." 
    (sync-server :name 'crea-indicatore :input indicator-format :command
                (with-extraction-and-validation indicator-format 
                    ((codice (required) (minlen 2))
                     (data-inizio (required)))
                  (result (translate2 codice))
                  ((fork (+not+ (+null+ result))
                         (concat* (indicator (create-instance2 
                                              indicator-entity 
                                              (list (prop 'nome) (attr result 'nome)
                                                    (prop 'codice-sorgente) codice
                                                    (prop 'codice-oggetto) (attr result 'codice)
                                                    (prop 'data-inizio) data-inizio))) 
                                  ((map-command (mu* parametro 
                                                     (concat*
                                                      (parametro (create-instance2 
                                                                  parameter-entity
                                                                  (list (prop 'id-indicatore) (attr indicator 'id-indicatore)
                                                                        (prop 'nome) (attr (argument parametro) 'nome)
                                                                        (prop 'valore) (attr (argument parametro) 'valore))))))
                                                (attr result 'parametri)))
                                  ((http-response 201)))
                         (http-response 403)))))))

(process remove-indicator
  (let ((id-indicatore (path-parameter 'id-indicatore)))
    (with-description* "Endpoint REST utilizzato per la cancellazione di un indicatore e dei suoi relativi parametri." 
      (sync-server :name 'rimuovi-indicatore :parameters (list id-indicatore) :command
                  (concat*
                   (indicator-valid
                    (validate2 id-indicatore (list (regex "[0..9]+"))))
                   ((fork indicator-valid
                          (concat* ((erase2 indicator-entity id-indicatore))
                                   ((http-response 204)))
                          (http-response 400))))))))

(process update-indicator
  (let* ((id-indicatore (path-parameter 'id-indicatore)))
    (with-description* "Endpoint REST utilizzato per la modifica di un indicatore e dei suoi relativi parametri." 
      (sync-server 
      :name 'modifica-indicatore
      :parameters (list id-indicatore) 
      :input indicator-format
      :command (concat*
                (indicator-valid (validate2 id-indicatore (list (regex "[0..9]+"))))
                ((fork indicator-valid
                       (concat*
                        (result (query2 (project (restrict (equijoin (relation 'parameter-entity) (relation 'indicator-entity) :id-indicatore)
                                                           (+equal+ (prop 'id-indicatore) (value id-indicatore)))
                                                 'parameter-id))) 
                        ((map-command (mu* parametro 
                                           (erase2 parameter-entity (argument parametro)))
                                      result))
                        ((with-extraction-and-validation indicator-format 
                             ((codice (required) (minlen 2))
                              (data-inizio (required)))
                           (result (translate2 codice))
                           ((fork (+null+ result)
                                  (http-response 403) 
                                  (concat* 
                                   (old-indicator (fetch2 indicator-entity :id id-indicatore))
                                   (new-indicator (update-instance2 
                                                   indicator-entity 
                                                   old-indicator
                                                   (list (prop 'nome) (attr result 'nome)
                                                         (prop 'codice-sorgente) codice
                                                         (prop 'codice-oggetto) (attr result 'codice)
                                                         (prop 'data-inizio) data-inizio))) 
                                   ((map-command (mu* parametro 
                                                      (concat*
                                                       (parameter (create-instance2 
                                                                   parameter-entity
                                                                   (list (prop 'id-indicatore) (attr new-indicator 'id-indicatore)
                                                                         (prop 'nome) (attr (argument parametro) 'nome)
                                                                         (prop 'valore) (attr (argument parametro) 'valore))))))
                                                 (attr result 'parametri)))
                                   ((http-response 201))))))))
                       (http-response 400))))))))

(process update-indicator-parameters
  (let* ((id-indicatore (path-parameter 'id-indicatore)))
    (with-description* "Endpoint REST utilizzato per la modifica dei parametri di un indicatore." 
(sync-server 
      :name 'modifica-parametri-indicatore
      :parameters (list id-indicatore) 
      :input indicator-parameter-array-format
      :command (concat*
                (indicator-valid (validate2 id-indicatore (list (regex "[0..9]+"))))
                ((map-command (mu* parametro 
                                   (with-extraction-and-validation parameter-format 
                                       ((nome (required) (minlen 2))
                                        (valore (required)))
                                     (parameter (create-instance2 
                                                 parameter-entity
                                                 (list (prop 'id-indicatore) id-indicatore
                                                       (prop 'nome) (attr (argument parametro) 'nome)
                                                       (prop 'valore) (attr (argument parametro) 'valore))))))
                              indicator-parameter-array-format))
                ((http-response 200)))))))

(process read-indicator
  (let* ((ind (path-parameter 'indicator)))
    (with-description* "Endpoint REST utilizzato per ottenere informazioni su uno specifico indicatore." (sync-server 
      :name 'leggi-indicatore
      :parameters (list ind) 
      :command (concat* (indicator (query2 (restrict (equijoin (relation 'indicator-entity) 
                                                               (relation 'parameter-entity)
                                                               :id-indicatore)
                                                     (+equal+ (prop 'id-indicatore) ind))))
                        (json (rel-to-json2 indicator 
                                            (list 'codice-sorgente 'data-inizio)
                                            :group (list 'nome 'valore))) 
                        ((http-response 200 :payload json)))))))
(process list-indicators
  (with-description* "Endpoint REST utilizzato per ottenere la lista di tutti gli indicatori specificati."
    (sync-server 
    :name 'lista-indicatori
    :command (concat* (indicators (query2 (equijoin (relation 'indicator-entity) 
                                                    (relation 'parameter-entity)
                                                    :id-indicatore)))
                      (json (rel-to-json2 indicators 
                                          (list 'codice-sorgente 'data-inizio)
                                          :group (list 'nome 'valore)))
                      ((http-response 200 :payload json))))))

(service indicator-service 
         (rest-service 'indicator-service 
                       (url `(aia))
                       (rest-post (url `(indicatori)) create-indicator)
                       (rest-delete (url `(indicatori / id)) remove-indicator)
                       (rest-put (url `(indicatori / id)) update-indicator)
                       (rest-put (url `(indicatori / id / parametri)) update-indicator-parameters)
                       (rest-get (url `(indicatori)) list-indicators)
                       (rest-get (url `(indicatori / id)) read-indicator)))


