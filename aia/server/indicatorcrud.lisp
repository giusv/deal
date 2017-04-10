;; (defun create-indicator-aux (id)
;;   (with-extraction-and-validation company-format 
;;       ((code (required) (minlen 2))
;;        (start-date (required)))
;;     (result (translate2 code))
;;     ((fork (+null+ result)
;;            (http-response 403)
;;            (concat* (indicator-record (create-instance2 
;;                                        indicator-entity 
;;                                        (list (prop 'name) (attr result 'name)
;;                                              (prop 'source-code) code
;;                                              (prop 'target-code) (attr result 'code)
;;                                              (prop 'start-date) start-date))) 
;;                     ((map-command (mu* parameter 
;;                                        (concat*
;;                                         (parameter (create-instance2 
;;                                                      parameter-entity
;;                                                      (list (prop 'indicator-id) (attr indicator-record 'indicator-id)
;;                                                            (prop 'name) (attr (argument parameter) 'name)
;;                                                            (prop 'value) (attr (argument parameter) 'value))))))
;;                                   (attr result 'parameters)))
;;                     ((http-response 201 :payload result))))))


;;   ;; (concat* (indicator-code (extract2 (prop 'text) indicator-format))
;;   ;;          (indicator-code-valid (validate2 indicator-code (list (required) (minlen 2))))
;;   ;;          (indicator-start-date (extract2 (prop 'start-date) indicator-format))
;;   ;;          (indicator-start-date-valid (validate2 indicator-start-date (list (required) (minlen 2))))
;;   ;;          ((fork
;;   ;;            (+and+ indicator-code-valid indicator-start-date-valid)
;;   ;;            (concat* (result (translate2 indicator-code))
;;   ;;                     ((fork (+equal+ result (const "Success"))
;;   ;;                            (concat* (indicator-record (create-instance2 indicator-entity 
;;   ;;                                                                         (list (prop 'id) id
;;   ;;                                                                               (prop 'code) (attr result 'code)
;;   ;;                                                                               (prop 'start-date) indicator-start-date)))
;;   ;;                                     ((persist indicator-record))
;;   ;;                                     ((map-command (mu* parameter 
;;   ;;                                                        (concat*
;;   ;;                                                         (parameter (create-instance2 parameter-entity
;;   ;;                                                                                       (list (prop 'id) (autokey)
;;   ;;                                                                                             (prop 'indicator-id) (attr indicator-record 'id)
;;   ;;                                                                                             (prop 'name) (attr (argument parameter) 'name)
;;   ;;                                                                                             (prop 'value) (attr (argument parameter) 'value))))
;;   ;;                                                         ((persist parameter))))
;;   ;;                                                   (attr result 'parameters)
;;   ;;                                                   ))
;;   ;;                                     ((http-response 201 :payload result)))
;;   ;;                            (http-response 403))))
;;   ;;            (http-response 403))))
;;   )

(process create-indicator 
  (with-description* "Endpoint REST utilizzato per la creazione di un nuovo indicatore e dei suoi relativi parametri." 
    (sync-server :name 'create-indicator :input indicator-format :command
                (with-extraction-and-validation indicator-format 
                    ((code (required) (minlen 2))
                     (start-date (required)))
                  (result (translate2 code))
                  ((fork (+not+ (+null+ result))
                         (concat* (indicator (create-instance2 
                                              indicator-entity 
                                              (list (prop 'name) (attr result 'name)
                                                    (prop 'source-code) code
                                                    (prop 'target-code) (attr result 'code)
                                                    (prop 'start-date) start-date))) 
                                  ((map-command (mu* parameter 
                                                     (concat*
                                                      (parameter (create-instance2 
                                                                  parameter-entity
                                                                  (list (prop 'indicator-id) (attr indicator 'indicator-id)
                                                                        (prop 'name) (attr (argument parameter) 'name)
                                                                        (prop 'value) (attr (argument parameter) 'value))))))
                                                (attr result 'parameters)))
                                  ((http-response 201)))
                         (http-response 403)))))))

(process remove-indicator
  (let ((indicator-id (path-parameter 'indicator-id)))
    (with-description* "Endpoint REST utilizzato per la cancellazione di un indicatore e dei suoi relativi parametri." 
      (sync-server :name 'remove-indicator :parameters (list indicator-id) :command
                  (concat*
                   (indicator-valid
                    (validate2 indicator-id (list (regex "[0..9]+"))))
                   ((fork indicator-valid
                          (concat* ((erase2 indicator-entity indicator-id))
                                   ((http-response 204)))
                          (http-response 400))))))))

(process update-indicator
  (let* ((indicator-id (path-parameter 'indicator-id)))
    (with-description* "Endpoint REST utilizzato per la modifica di un indicatore e dei suoi relativi parametri." 
      (sync-server 
      :name 'update-indicator
      :parameters (list indicator-id) 
      :input indicator-format
      :command (concat*
                (indicator-valid (validate2 indicator-id (list (regex "[0..9]+"))))
                ((fork indicator-valid
                       (concat*
                        (result (query2 (project (restrict (equijoin (relation 'parameter-entity) (relation 'indicator-entity) :indicator-id)
                                                           (+equal+ (prop 'indicator-id) (value indicator-id)))
                                                 'parameter-id))) 
                        ((map-command (mu* parameter 
                                           (erase2 parameter-entity (argument parameter)))
                                      result))
                        ((with-extraction-and-validation indicator-format 
                             ((code (required) (minlen 2))
                              (start-date (required)))
                           (result (translate2 code))
                           ((fork (+null+ result)
                                  (http-response 403) 
                                  (concat* 
                                   (old-indicator (fetch2 indicator-entity :id indicator-id))
                                   (new-indicator (update-instance2 
                                                   indicator-entity 
                                                   old-indicator
                                                   (list (prop 'name) (attr result 'name)
                                                         (prop 'source-code) code
                                                         (prop 'target-code) (attr result 'code)
                                                         (prop 'start-date) start-date))) 
                                   ((map-command (mu* parameter 
                                                      (concat*
                                                       (parameter (create-instance2 
                                                                   parameter-entity
                                                                   (list (prop 'indicator-id) (attr new-indicator 'indicator-id)
                                                                         (prop 'name) (attr (argument parameter) 'name)
                                                                         (prop 'value) (attr (argument parameter) 'value))))))
                                                 (attr result 'parameters)))
                                   ((http-response 201))))))))
                       (http-response 400))))))))

(process update-indicator-parameters
  (let* ((indicator-id (path-parameter 'indicator-id)))
    (with-description* "Endpoint REST utilizzato per la modifica dei parametri di un indicatore." 
(sync-server 
      :name 'update-indicator
      :parameters (list indicator-id) 
      :input indicator-parameter-array-format
      :command (concat*
                (indicator-valid (validate2 indicator-id (list (regex "[0..9]+"))))
                ((map-command (mu* parameter 
                                   (with-extraction-and-validation parameter-format 
                                       ((name (required) (minlen 2))
                                        (value (required)))
                                     (parameter (create-instance2 
                                                 parameter-entity
                                                 (list (prop 'indicator-id) indicator-id
                                                       (prop 'name) (attr (argument parameter) 'name)
                                                       (prop 'value) (attr (argument parameter) 'value))))))
                              indicator-parameter-array-format))
                ((http-response 200)))))))

(process read-indicator
  (let* ((ind (path-parameter 'indicator)))
    (with-description* "Endpoint REST utilizzato per ottenere informazioni su uno specifico indicatore." (sync-server 
      :name 'read-indicator
      :parameters (list ind) 
      :command (concat* (indicator (query2 (restrict (equijoin (relation 'indicator-entity) 
                                                               (relation 'parameter-entity)
                                                               :indicator-id)
                                                     (+equal+ (prop 'indicator-id) ind))))
                        (json (rel-to-json2 indicator 
                                            (list 'source-code 'start-date)
                                            :group (list 'name 'value))) 
                        ((http-response 200 :payload json)))))))
(process list-indicators
  (with-description* "Endpoint REST utilizzato per ottenere la lista di tutti gli indicatori specificati."
    (sync-server 
    :name 'list-indicators
    :command (concat* (indicators (query2 (equijoin (relation 'indicator-entity) 
                                                    (relation 'parameter-entity)
                                                    :indicator-id)))
                      (json (rel-to-json2 indicators 
                                          (list 'source-code 'start-date)
                                          :group (list 'name 'value)))
                      ((http-response 200 :payload json))))))

(service indicator-service 
         (rest-service 'indicator-service 
                       (url `(aia))
                       (rest-post (url `(indicatori)) create-indicator)
                       (rest-delete (url `(indicatori / id)) remove-indicator)
                       (rest-put (url `(indicatori / id)) update-indicator)
                       (rest-put (url `(indicatori / id / parameters)) update-indicator-parameters)
                       (rest-get (url `(indicatori)) list-indicators)
                       (rest-get (url `(indicatori / id)) read-indicator)))


