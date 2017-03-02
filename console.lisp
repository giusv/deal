(defelement navbar 
    (navbar (gensym) 
	    (anchor (gensym) (const "Amministrazione") :click (target (url `(:admin))))
	    (anchor (gensym) (const "Specifica indicatori") :click (target (url `(:ind-spec))))))

(defelement admin-section
  (label (const "Amministrazione")))

(defelement indicator-form
    (let* ((of (object-form2 'of ((code (textarea 'code (const "Codice indicatore")) :codice)
                                  (start-date (input 'start-date (const "Data inizio validità")) :data-inizio))
                             (vert code start-date))))
      (form 'indicator-form 
            (vert  of (button 'ok (const "Invio") :click (http-post (const "www.example.com") (payload of) (gensym)))))))
(defelement ind-section
  (alt indicator-form)) 

(defelement console 
  (let* ((nav navbar) 
         (main (hub-spoke ((admin "Amministrazinoe" admin-section)
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
					     (synth to-html console (void))))) 0))
