;; (process create-report 
;;   (with-description* "Endpoint REST utilizzato per la creazione di un nuovo report." 
;;     (sync-server :name 'create-report 
;;                 :input report-format
;;                 :command  (with-extraction-and-validation report-format 
;;                               ((name (required) (minlen 2))
;;                                (address (required)))
;;                             (report (create-instance2 report-entity
;;                                                        (list (prop 'name) name
;;                                                              (prop 'address) address)))
;;                             ((http-response 201))))))

;; (process remove-report
;;   (remove* report report-entity ((regex "[0..9]+"))))
;; (process remove-report
;;   (let ((report-id (path-parameter 'report-id)))
;;     (with-description* "Endpoint REST utilizzato per la rimozione di una compagnia." 
;;       (sync-server :name 'remove-report 
;;                   :parameters (list report-id) 
;;                   :command (concat*
;;                             (report-valid
;;                              (validate2 report-id (list (regex "[0..9]+"))))
;;                             ((fork report-valid
;;                                    (concat* ((erase2 report-entity report-id))
;;                                             ((http-response 204)))
;;                                    (http-response 400))))))))

;; (process update-report
;;   (let* ((report-id (path-parameter 'report-id)))
;;     (with-description* "Endpoint REST utilizzato per la modifica dei dati di un nuovo report." 
;;       (sync-server 
;;       :name 'update-report
;;       :parameters (list report-id) 
;;       :input report-format
;;       :command (concat* (report-valid (validate2 report-id (list (regex "[0..9]+"))))
;;                         ((fork report-valid
;;                                (with-extraction-and-validation report-format 
;;                                    ((name (required) (minlen 2))
;;                                     (address (required)))
;;                                  (old-report (fetch2 report-entity :id report-id))
;;                                  ((fork (+null+ old-report)
;;                                         (http-response 404)
;;                                         (concat* 
;;                                          (new-report (update-instance2 report-entity old-report
;;                                                                         (list (prop 'name) name
;;                                                                               (prop 'address) address))) 
;;                                          ((http-response 200)))))) 
;;                                (http-response 403))))))))

(process read-report
  (let* ((rep (path-parameter 'report)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento dei dati di un report." 
      (sync-server 
       :name 'read-report
       :parameters (list rep) 
       :command (concat* (report (fetch2 report-entity :id rep)) 
                         (json (rel-to-json2 report (list 'data 'descrizione 'pdf)))
                         ((http-response 200 :payload json)))))))
(process list-reports
  (let* ((data-inizio (query-parameter 'data-inizio))
         (data-fine (query-parameter 'data-fine)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento della lista di tutti i report." 
      (sync-server 
       :name 'list-reports
       :parameters (list data-inizio data-fine)
       :command (concat* (reports (query2 (restrict (relation 'report-entity)
                                                    (+and+ (+or+ 
                                                            (+greater-than+ (prop 'data) data-inizio)
                                                            (+less-than+ (prop 'data) data-fine))))))
                         (json (rel-to-json2 reports 
                                             (list 'data 'descrizione 'pdf)))
                         ((http-response 200 :payload json)))))))
(service report-service 
  (rest-service 'report-service 
                (url `(aia))
                (rest-get (url `(report)) list-reports)
                (rest-get (url `(report / id)) read-report)))


