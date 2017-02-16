(defun post-data (user post)
  (vert (label user)
	(label post)))

(defun post-list (user)
  (vert (label user)
	(alt nil 
	     (static :posts nil
		     (alt (label (const "user posts"))
			  (dynamic2 post nil 
				    (post-data user post))))
	     (static :profile nil 
		     (label (const "profile"))))))

(defun render-fields (id name)
  (list (label (attr id))
	(label (attr name))))

(defun *submit-user* nil 
    (let* ((resp (http-get (void) (gensym))))
      (condition (<equal> (const (synth response resp)) (const "200"))
		 (target (void))
		 (target (void)))))

(defparameter *plate-form*
  (let* ((plate (input 'plate (const "Targa")))
	 (start-date (input 'start-date (const "Data inizio")))
	 (end-date (input 'end-date (const"Data fine")))
	 (ok (button 'ok (const "Submit") :click ())))
    (form 'plate-form (vert plate start-date end-date ok))))
(defparameter *plate-results*
  (empty)
  )
(defparameter *person-form*
  (let* ((code (input 'code (const "Codice fiscale")))
	 (start-date (input 'start-date (const "Data inizio")))
	 (end-date (input 'end-date (const "Data fine")))
	 (ok (button 'ok (const "Submit") :click ())))
    (form 'plate-form (vert code start-date end-date ok))))

(defparameter *search-by-plate* 
  (alt *plate-form*
       (static :results nil *plate-results*)))
(defparameter *search-by-person* 
  (alt *person-form*
       (static :results nil (label (const "search-by-person")))))


(defparameter *navbar* (navbar (gensym) 
			       (anchor (gensym) (const "Ricerca per veicolo") :click (target (url `(:home / :search-by-plate))))
			       (anchor (gensym) (const "Ricerca per persona") :click (target (url `(:home / :search-by-person))))))
(defparameter *aia* 
  (alt nil 
       (static :login nil  
	       (let* ((userid (input 'userid (const "User id") :init (const "nome.cognome@mail.com")))
		      (passwd (input 'passwd (const "Password")))
		      (ok (button 'ok (const "ok") :click (target (url `(:users / { ,(value userid) } / :posts)))))
		      (cancel (button 'cancel (const "cancel"))))
		 (vert userid passwd (horz ok cancel))))
       (static :home nil 
	       (let* ((nav *navbar*) 
		      (main (hub-spoke ((search-by-plate "Ricerca per targa" *search-by-plate*)
					(search-by-person "Ricerca per persona" *search-by-person*))
				       :home
				       (horz search-by-plate search-by-person))))
		 (vert nav main)))))

(defparameter *gui-test* (let* ((search-by-plate 
		       (panel (label (const "Ricerca per targa"))
			      (anchor (gensym) (const "Vai alla pagina") :click (target (void))))))
		 (vert (horz search-by-plate))))

(write-file "d:/giusv/temp/aia.html" 
	    (synth to-string 
		   (synth to-doc (html nil 
				       (head nil 
					     (title nil (text "AIA"))
					     (meta (list :charset "utf-8"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css")))
				       (body nil 
					     (h1 nil (text "Archivio Integrato Antifrode - Requisiti funzionali")) 
					     (synth to-html *aia* (void))))) 0))
