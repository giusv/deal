(defun create-indicator-aux (id)
  (concat* (indicator-code (extract2 (prop 'text) indicator-format))
           (indicator-code-valid (validate2 indicator-code (list (required) (minlen 2))))
           (indicator-start-date (extract2 (prop 'start-date) indicator-format))
           (indicator-start-date-valid (validate2 indicator-start-date (list (required) (minlen 2))))
           ((fork
             (+and+ indicator-code-valid indicator-start-date-valid)
             (concat* (result (translate2 indicator-code))
                      ((fork (+equal+ result (const "Success"))
                             (concat* (indicator-record (create-instance2 indicator-entity 
                                                                          (list (prop 'id) (autokey)
                                                                                (prop 'code) (attr result 'code)
                                                                                (prop 'start-date) indicator-start-date)))
                                      ((persist indicator-record))
                                      ((map-command (mu* parameter 
                                                         (concat*
                                                          (par-record (create-instance2 parameter-entity
                                                                                        (list (prop 'id) (autokey)
                                                                                              (prop 'indicator-id) (attr indicator-record 'id)
                                                                                              (prop 'name) (attr (argument parameter) 'name)
                                                                                              (prop 'value) (attr (argument parameter) 'value))))
                                                          ((persist par-record))))
                                                    (attr result 'parameters)
                                                    ))
                                      ((http-response 201 :payload result)))
                             (http-response 403))))
             (http-response 403)))))

(process create-indicator 
  (sync-server :name 'create-indicator :input indicator-format :command
               (create-indicator-aux (autokey))))

(process remove-indicator
  (let ((indicator-id (path-parameter 'indicator-id)))
    (sync-server :name 'remove-indicator :parameters (list indicator-id) :command
                 (concat*
                  (indicator-valid
                   (validate2 indicator-id (list (regex "[0..9]+"))))
                  ((fork indicator-valid
                         (concat* ((erase2 indicator-entity indicator-id))
                                  ((http-response 204)))
                         (http-response 400)))))))

(process modify-indicator
  (let* ((indicator-id (path-parameter 'indicator-id)))
    (sync-server 
     :name 'modify-indicator
     :parameters (list indicator-id) 
     :input indicator-format
     :command (concat*
               (indicator-valid (validate2 indicator-id (list (regex "[0..9]+"))))
               ((fork indicator-valid
                      (erase2 indicator-entity indicator-id)
                      (http-response 400)))
               (indicator-code (extract2 (prop 'text) indicator-format))
               (indicator-code-valid (validate2 indicator-code (list (required) (minlen 2))))
               (indicator-start-date (extract2 (prop 'start-date) indicator-format))
               (indicator-start-date-valid (validate2 indicator-start-date (list (required) (minlen 2))))
               ((fork
                 (+and+ indicator-code-valid indicator-start-date-valid)
                 (concat* (result (translate2 indicator-code))
                          ((fork (+equal+ result (const "Success"))
                                 (concat* (indicator-record (create-instance2 indicator-entity 
                                                                              (list (prop 'id) indicator-id
                                                                                    (prop 'code) (attr result 'code)
                                                                                    (prop 'start-date) indicator-start-date)))
                                          ((persist indicator-record))
                                          ((map-command (mu* parameter 
                                                             (concat*
                                                              (par-record (create-instance2 parameter-entity
                                                                                            (list (prop 'id) (autokey)
                                                                                                  (prop 'indicator-id) (attr indicator-record 'id)
                                                                                                  (prop 'name) (attr (argument parameter) 'name)
                                                                                                  (prop 'value) (attr (argument parameter) 'value))))
                                                              ((persist par-record))))
                                                        (attr result 'parameters)
                                                        ))
                                          ((http-response 201 :payload result)))
                                 (http-response 403))))
                 (http-response 403)))))))

;; (process modify-indicator-parameters
;;   (let* ((indicator-id (path-parameter 'indicator-id)))
;;     (sync-server 
;;      :name 'modify-indicator
;;      :parameters (list indicator-id) 
;;      :input indicator-format
;;      :command (concat*
;;                (indicator-valid (validate2 indicator-id (list (regex "[0..9]+"))))
;;                ((map-command (mu*  
;;                               (concat*
;;                                (par-record (create-instance2 parameter-entity
;;                                                              (list (prop 'id) (autokey)
;;                                                                    (prop 'indicator-id) (attr indicator-record 'id)
;;                                                                    (prop 'name) (attr (argument parameter) 'name)
;;                                                                    (prop 'value) (attr (argument parameter) 'value))))
;;                                ((persist par-record))))
;;                              (attr result 'parameters)
;;                              ))
;;                ((http-response 201 :payload result))
;;                (http-response 403)
;;                (http-response 403)))))

(service indicator-service 
         (rest-service 'indicator-service 
                       (url `(aia))
                       (rest-post (url `(indicatori)) create-indicator)
                       (rest-delete (url `(indicatori / id)) remove-indicator)
                       (rest-put (url `(indicatori / id)) modify-indicator)))


