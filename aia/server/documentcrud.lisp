(defmacro with-extraction-and-validation (format processors &body commands)
  `(concat* ,@(apply #'append (loop for processor in processors
                  collect (let ((selector (car processor))
                                (validators (cdr processor))) 
                            (list `(,selector (extract2 (prop ',selector) ,format))
                                  `(,(symb selector "-VALID") (validate2 ,selector (list ,@validators)))))))
            ((fork (+and+ ,@(loop for processor in processors
                  collect (let ((selector (car processor))) 
                            (symb selector "-VALID"))))
                   (concat*
                    ,@commands)
                   (http-response 403)))))




(process create-document 
  (sync-server :name 'create-document 
               :input document-format
               :command  (with-extraction-and-validation document-format 
                             ((type (required) (minlen 2))
                              (cue (required))
                              (binary (required)))
                           (document (create-instance2 document-entity
                                                       (list (prop 'id) (autokey)
                                                             (prop 'type) type
                                                             (prop 'cue) cue
                                                             (prop 'binary) binary)))
                           ((persist document)) 
                           ((http-response 201 :payload (value document))))


               ;; (concat* (document-type (extract2 (prop 'type) document-format))
               ;;          (document-type-valid (validate2 document-type (list (required) (minlen 2))))
               ;;          (document-type (extract2 (prop 'type) document-format))
               ;;          (document-type-valid (validate2 document-type (list (required) (minlen 2))))
               ;;          (document-cue (extract2 (prop 'cue) document-format))
               ;;          (document-cue-valid (validate2 document-cue (list (required) (minlen 2)))) 
               ;;          (document-binary (extract2 (prop 'cue) document-format))
               ;;          (document-binary-valid (validate2 document-binary (list (required) (minlen 2)))) 
               ;;          ((fork
               ;;            (+and+ document-type-valid document-cue-valid document-binary-valid)
               ;;            (concat*
               ;;             ;; (audit (create-instance2 document-audit-entity
               ;;             ;;                             (list (prop 'id) (autokey)
               ;;             ;;                                   (prop 'type) document-type
               ;;             ;;                                   (prop 'cue) document-cue
               ;;             ;;                                   (prop 'binary) document-binary
               ;;             ;;                                   (prop 'binary) document-binary)))
               ;;             ;; ((persist audit))
               ;;             (document (create-instance2 document-entity
               ;;                                         (list (prop 'id) (autokey)
               ;;                                               (prop 'type) document-type
               ;;                                               (prop 'cue) document-cue
               ;;                                               (prop 'binary) document-binary)))
               ;;             ((persist document)) 
               ;;             ((http-response 201 :payload (value document))))
               ;;            (http-response 403))))
               ))

(process remove-document
  (let* ((document (path-parameter 'document)))
    (sync-server
     :name 'remove-document
     :parameters (list document) 
     :command (concat* (document-valid (validate2 document (list (regex "[0..9]+"))))
                       ((fork document-valid
                              (concat* 
                               ((erase2 document-entity document))
                               ((http-response 204)))
                              (http-response 400)))))))

(process modify-document
  (let* ((document-id (path-parameter 'document-id)))
    (sync-server 
     :name 'modify-document
     :parameters (list document-id) 
     :input document-format
     :command (concat* (document-valid (validate2 document-id (list (regex "[0..9]+"))))
                       ((fork document-valid
                              (erase2 document-entity document-id)
                              (http-response 400)))
                       (document-type (extract2 (prop 'type) document-format))
                       (document-type-valid (validate2 document-type (list (required) (minlen 2))))
                       (document-cue (extract2 (prop 'cue) document-format))
                       (document-cue-valid (validate2 document-cue (list (required) (minlen 2))))
                       (document-binary (extract2 (prop 'cue) document-format))
                       (document-binary-valid (validate2 document-binary (list (required) (minlen 2))))
                       ((fork
                          (+and+ document-type-valid document-cue-valid document-binary-valid)
                          (concat*
                           (document (create-instance2 document-entity
                                                       (list (prop 'id) (autokey)
                                                             (prop 'type) document-type
                                                             (prop 'cue) document-cue
                                                             (prop 'binary) document-binary)))
                           ((persist document)) 
                           ((http-response 201 :payload (value document))))
                          (http-response 403)))))))

(service document-service 
         (rest-service 'document-service 
                       (url `(aia))
                       (rest-post (url `(documenti)) create-document)
                       (rest-delete (url `(documenti / id)) remove-document)
                       (rest-put (url `(documenti / id)) modify-document)))


