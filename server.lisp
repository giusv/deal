(deformat ind-form 
    (jsobject (jsprop 'codice t (jsstring))
              (jsprop 'data-inizio t (jsstring))))
(defprocess ind-spec 
    (sync-server nil 
                 ind-form
		 (concat2 (result (translate2 (prop 'codice)))
			  ((condition (+equal+ result (const "Success"))
				      (skip)
				      (skip))))))


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
