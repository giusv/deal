(deformat indicator-format 
    (jsobject (jsprop 'codice t (jsstring))
              (jsprop 'data-inizio t (jsstring))))

(deformat company-format 
    (jsobject (jsprop 'name t (jsstring))
              (jsprop 'address t (jsstring))))

(defentity indicator-entity (entity 'indicator-entity
			       (primary-key 
				(attribute 'id 'string))
			       (list (attribute 'code 'string)
				     (attribute 'start-date 'string))))
(defprocess ind-spec 
    (sync-server nil 
                 indicator-format
		 (concat2 (ind-code (extract2 (prop 'codice) indicator-format)) 
                          (ind-startdate (extract2 (prop 'data-inizio) indicator-format)) 
                          ;; (ind-code ind-startdate (extract2 indicator-format (prop 'codice) (prop 'data-inizio))) 
                          (result (translate2 ind-code))
			  ((fork (+equal+ result (const "Success"))
                                 (concat2 (indic (create-instance2 indicator-entity 
                                                                   (prop 'id) (variab (gensym)) 
                                                                   (prop 'code) result
                                                                   (prop 'start-date) ind-startdate))
                                          ((persist indic))
                                          ((http-response 201 result)))
                                 (http-response 403))))))

(defprocess ind-collection
    (let* ((page (query-parameter 'page))
           (length (query-parameter 'length)))
      (sync-server (list page length)
                   nil
                   (concat2 (result (fetch2 indicator-entity))
                            ((http-response 200 result))))))

(defentity company-entity (entity 'company-entity
                                  (primary-key
                                   (attribute 'id 'integer))
                                  (list (attribute 'name 'string)
                                        (attribute 'address 'string))))

(defprocess add-company 
    (sync-server nil 
                 company-format
		 (concat2 (comp-name (extract2 (prop 'name) company-format)) 
                          (comp-add (extract2 (prop 'address) company-format))
                          (comp-name-valid (validate2 comp-name (required) (minlen 2) (maxlen 5)))
                          (comp-add-valid (validate2 comp-add (regex "[0..9]+")))
                          ((fork (+and+ comp-name-valid comp-add-valid) 
                                 (concat2 
                                  (company (create-instance2 company-entity 
                                                             (prop 'id) (variab (gensym)) 
                                                             (prop 'name) comp-name
                                                             (prop 'adderss) comp-add)) 
                                  ((persist company)) 
                                  ((http-response 201 company)))
                                 (http-response 403))))))

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
					     (synth to-html add-company)))) 0))
