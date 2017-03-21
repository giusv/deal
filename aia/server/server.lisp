(process ind-spec 
         (sync-server 
          :name 'ind-spec
          :input indicator-format
          :command (concat* (ind-code (extract2 (prop 'codice) indicator-format)) 
                            (ind-startdate (extract2 (prop 'data-inizio) indicator-format)) 
                            ;; (ind-code ind-startdate (extract2 indicator-format (prop 'codice) (prop 'data-inizio)))
                            (result (translate2 ind-code :pre (+false+) :post (+true+)))
                            ((fork (+equal+ result (const "Success"))
                                   (concat* (indic (create-instance2 indicator-entity 
                                                                     (list (prop 'id) (autokey)
                                                                           (prop 'code) result
                                                                           (prop 'start-date) ind-startdate)))
                                            ((persist indic))
                                            ((http-response 201 :payload result)))
                                   (http-response 403))))))

(process ind-collection
         (let* ((page (query-parameter 'page))
                (length (query-parameter 'length)))
           (sync-server 
            :name 'ind-collection
            :parameters (list page length)
            :command (concat* (result (fetch2 indicator-entity))
                              ((http-response 200 :payload result))))))

