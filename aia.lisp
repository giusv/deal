(defelement plate-form
  (form 'plate-form 
	(vert (object-form2 'of ((plate (input 'plate (const "Targa")) :targa)
				 (start-date (input 'start-date (const "Data inizio")) :data-inizio)
				 (end-date (input 'end-date (const "Data fine")) :data-fine))
			    (vert plate start-date end-date)) 
	      (button 'ok (const "Submit") :click ()))))


(defun plate-results (plate start-date end-date)
  (vert (label plate)
	(label start-date)
	(label end-date)))

(defelement person-form
    (let* ((of (object-form2 'of ((code (input 'code (const "Codice fiscale")) :codice-fiscale)
                                  (start-date (input 'start-date (const "Data inizio")) :data-inizio)
                                  (end-date (input 'end-date (const "Data fine")) :data-fine))
                             (vert code start-date end-date))))
      (form 'person-form 
            (vert  of (button 'ok (const "Submit") :click (http-post (const "www.example.com") (payload of) nil))))))


(defelement plate-section
  (alt plate-form
       (static2 :results (plate start-date end-date) (plate-results plate start-date end-date))))


(defelement person-section
  (alt person-form
       (static2 :results nil (label (const "search-by-person")))))


(defelement navbar 
    (navbar (gensym) 
	    (anchor (gensym) (const "Ricerca per veicolo") :click (target (url `(:home / :search-by-plate))))
	    (anchor (gensym) (const "Ricerca per persona") :click (target (url `(:home / :search-by-person))))))


(defelement aia 
  (alt nil 
       (static2 :login nil  
	       (let* ((userid (input 'userid (const "User id") :init (const "nome.cognome@mail.com")))
		      (passwd (input 'passwd (const "Password")))
		      (ok (button 'ok (const "ok") :click (target (url `(:users / { ,(value userid) } / :posts)))))
		      (cancel (button 'cancel (const "cancel"))))
		 (vert userid passwd (horz ok cancel))))
       (static2 :home nil 
       	       (let* ((nav navbar) 
       		      (main (hub-spoke ((search-by-plate "Ricerca per targa" plate-section)
       					(search-by-person "Ricerca per persona" person-section))
       				       :home
       				       (horz search-by-plate search-by-person))))
       		 (vert nav main)))))

(write-file "d:/giusv/temp/aia.html" 
	    (synth to-string 
		   (synth to-doc (html nil 
				       (head nil 
					     (title nil (text "AIA"))
					     (meta (list :charset "utf-8"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css")))
				       (body nil
					     (h1 nil (text "Archivio Integrato Antifrode"))
					     (h2 nil (text "Requisiti funzionali web application"))
					     (synth to-html aia (void))))) 0))
