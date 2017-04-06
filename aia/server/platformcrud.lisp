(process list-accidents
  (let* ((plate (query-parameter 'targa))
         (start-date (query-parameter 'inizio))
         (end-date (query-parameter 'fine))
         (page (query-parameter 'pagina)))
    (sync-server 
     :name 'list-accidents
     :parameters (list plate start-date end-date page)
     :command (concat* 
               (log (create-instance2 inquiry-entity
                                      (list (prop 'inquiry-id) (autokey)
                                            (prop 'plate) plate
                                            (prop 'start-date) start-date
                                            (prop 'end-date) end-date)))
               ((persist log))
               (accidents (fetch2 (relation 'accidents-entity))) 
               ((http-response 200 :payload accidents))))))

(process list-inquiries
  (let* ((plate (query-parameter 'targa))
         (userid (query-parameter 'userid))
         (company (query-parameter 'company))
         (cue (query-parameter 'cue))
         (start-date (query-parameter 'inizio))
         (end-date (query-parameter 'fine))
         (page (query-parameter 'pagina)))
    (sync-server 
     :name 'list-accidents
     :parameters (list plate userid company cue start-date end-date page)
     :command (concat* 
               (inquiries (query2 (restrict (relation 'inquiry-entity)
                                            (+or+ 
                                             (+equal+ (prop 'plate) plate)
                                             (+equal+ (prop 'userid) userid)
                                             (+equal+ (prop 'company) company)
                                             (+equal+ (prop 'cue) cue))))) 
               ((http-response 200 :payload inquiries))))))


(service inquiry-service 
  (rest-service 'inquiry-service 
                (url `(aia))
                (rest-get (url `(sinistri)) list-accidents)
                (rest-get (url `(inquiries)) list-inquiries)))
