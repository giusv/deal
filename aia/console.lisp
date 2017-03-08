(element navbar 
    (navbar* (anchor* (const "Amministrazione") :click (target (url `(admin))))
             (anchor* (const "Specifica indicatori") :click (target (url `(ind-spec))))))

(element admin-section
  (label (const "Amministrazione")))

(element indicator-form
         (vert* (ind (obj* 'ind-data indicator-format 
                           ((code codice (textarea* (const "Codice indicatore")))
                            (start-date data-inizio (input* (const "Data inizio validità"))))
                           (vert code start-date)))
                ((button* (const "Invio") :click (http-post (const "www.example.com") (payload ind) (gensym))))))
(element ind-section
  (alt indicator-form)) 

(element console 
  (let* ((nav navbar) 
         (main (hub-spoke ((admin "Amministrazione" admin-section)
                           (ind-spec "Specifica indicatori" ind-section))
                          nil
                          (horz admin ind-spec))))
    (vert nav main)))

(write-file "d:/giusv/temp/console.html" 
	    (synth to-string 
		   (synth to-doc (html nil 
				       (head nil 
					     (title nil (text "Console"))
					     (meta (list :charset "utf-8"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css")))
				       (body nil
					     (h1 nil (text "Archivio Integrato Antifrode"))
					     (h2 nil (text "Requisiti funzionali Console amministrazione"))
					     (synth to-html console (void-url))))) 0))
