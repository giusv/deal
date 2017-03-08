(element navbar 
    (navbar* (anchor* (const "Amministrazione") :click (target (url `(admin))))
             (anchor* (const "Specifica indicatori") :click (target (url `(ind-spec))))))

(element admin-section
         (label (const "Amministrazione")))

(defun post-ind-spec (payload)
  (concat* (response (http-post* (const "www.ivass.it/aia/indspec") payload))
           ((fork (+equal+ response (const 201))
                  (target (url `(ind-list)))
                  (target (url `(ind-error)))))))

(element indicator-form
         (vert* (ind (obj* 'ind-data indicator-format 
                           ((code codice (textarea* (const "Codice indicatore")))
                            (start-date data-inizio (input* (const "Data inizio validità"))))
                           (vert code start-date)))
                ((button* (const "Invio") :click (post-ind-spec (payload ind))))))
(element indicator-list 
         (label (const "indicator list")))
(element ind-section
  (alt indicator-list
       (static2 :ind-spec nil indicator-form))) 

(element console 
  (vert* (nav navbar) 
         (main (hub-spoke ((admin "Amministrazione" admin-section)
                           (ind-spec "Indicatori" ind-section))
                          nil
                          (horz admin ind-spec)))))

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
