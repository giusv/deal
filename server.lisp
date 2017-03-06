(deformat indicator-format 
    (jsobject 'formato-indicatore
              (jsprop 'codice t (jsstring 'stringa-codice))
              (jsprop 'data-inizio t (jsstring 'data-data-inizio))))

(deformat company-format 
    (jsobject 'formato-compagnia
              (jsprop 'name t (jsstring 'stringa-nome))
              (jsprop 'address t (jsstring 'stringa-indirizzo))))

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
                                                                   (list (prop 'id) (variab (gensym)) 
                                                                         (prop 'code) result
                                                                         (prop 'start-date) ind-startdate)))
                                          ((persist indic))
                                          ((http-response 201 :payload result)))
                                 (http-response 403))))))

(defprocess ind-collection
    (let* ((page (query-parameter 'page))
           (length (query-parameter 'length)))
      (sync-server (list page length)
                   nil
                   (concat2 (result (fetch2 indicator-entity))
                            ((http-response 200 :payload result))))))

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
                          (comp-name-valid (validate2 comp-name (list (required) (minlen 2) (maxlen 5))))
                          (comp-add-valid (validate2 comp-add (list (regex "[0..9]+"))))
                          ((fork (+and+ comp-name-valid comp-add-valid) 
                                 (concat2 
                                  (company (create-instance2 company-entity 
                                                             (list (prop 'id) (variab (gensym)) 
                                                                   (prop 'name) comp-name
                                                                   (prop 'address) comp-add))) 
                                  ((persist company)) 
                                  ((http-response 201 :payload company)))
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
					     (synth to-html ind-spec)))) 0))
