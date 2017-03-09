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
                                                                     (list (prop 'id) (variab (gensym)) 
                 aia2                                                          (prop 'code) result
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

(process add-company 
         (sync-server
          :name 'add-company
          :input company-format
          :command (concat* (comp-name (extract2 (prop 'name) company-format))
                            (comp-add (extract2 (prop 'address) company-format))
                            (comp-name-valid (validate2 comp-name (list (required) (minlen 2) (maxlen 5))))
                            (comp-add-valid (validate2 comp-add (list (regex "[0..9]+"))))
                            ((fork (+and+ comp-name-valid comp-add-valid) 
                                   (concat* 
                                    (company (create-instance2 company-entity 
                                                               (list (prop 'id) (variab (gensym)) 
                                                                     (prop 'name) comp-name
                                                                     (prop 'address) comp-add))) 
                                    ((persist company)) 
                                    ((http-response 201 :payload company)))
                                   (http-response 403))))))
(process remove-company
         (let* ((comp (path-parameter 'company)))
           (sync-server
            :name 'remove-company
            :parameters (list comp) 
            :command (concat* (comp-valid (validate2 comp (list (regex "[0..9]+"))))
                              ((fork comp-valid
                                     (concat* 
                                      ((erase2 company-entity comp)) 
                                      ((http-response 204)))
                                     (http-response 400)))))))

(process modify-company
         (let* ((comp (path-parameter 'company)))
           (sync-server 
            :name 'modify-company
            :parameters (list comp) 
            :input company-format
            :command (concat* (comp-valid (validate2 comp (list (regex "[0..9]+"))))
                              (comp-name (extract2 (prop 'name) company-format))
                              (comp-add (extract2 (prop 'address) company-format))
                              (comp-name-valid (validate2 comp-name (list (required) (minlen 2) (maxlen 5))))
                              (comp-add-valid (validate2 comp-add (list (regex "[0..9]+"))))
                              ((fork (+and+ comp-valid comp-name-valid comp-add-valid) 
                                     (concat* 
                                      (company (create-instance2 company-entity 
                                                                 (list (prop 'id) (variab (gensym)) 
                                                                       (prop 'name) comp-name
                                                                       (prop 'address) comp-add))) 
                                      ((persist company)) 
                                      ((http-response 201 :payload company)))
                                     (http-response 403)))))))

(service company-service 
         (rest-service 'company-service 
                       (url `(aia / compagnie))
                       (rest-post (void-url) add-company)))

(write-file "d:/giusv/temp/server.html" 
	    (synth to-string 
		   (synth to-doc (html nil 
				       (head nil 
					     (title nil (text "Server"))
					     (meta (list :charset "utf-8"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css")))
				       (body nil
					     (h1 nil (text "Archivio Integrato Antifrode"))
					     (h2 nil (text "Requisiti funzionali processo acquisizione indicatori"))
					     (synth to-html company-service)))) 0))
