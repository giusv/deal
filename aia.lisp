(defun post-data (user post)
  (vert (label user)
	(label post)))

(defun post-list (user)
  (vert (label user)
	(alt nil 
	     (static2 :posts nil
		     (alt (label (const "user posts"))
			  (dynamic2 post
				    (post-data user post))))
	     (static2 :profile nil 
		     (label (const "profile"))))))

(defun render-fields (id name)
  (list (label (attr id))
	(label (attr name))))

(defun submit-user nil 
    (let* ((resp (http-get (void) (gensym))))
      (condition (<equal> (const (synth response resp)) (const "200"))
		 (target (void))
		 (target (void)))))

(defparameter plate-form
  (form 'plate-form 
	(vert (object-form2 'of ((plate (input 'plate (const "Targa")) :targa)
				 (start-date (input 'start-date (const "Data inizio")) :data-inizio)
				 (end-date (input 'end-date (const "Data fine")) :data-fine))
			    (vert plate start-date end-date)) 
	      (button 'ok (const "Submit") :click ()))))


(defun plate-results (plate start-date end-date)
  (vert (label (const plate))
	(label (const start-date))
	(label (const end-date))))

(defparameter person-form
  (form 'person-form 
	(vert (object-form2 'of ((code (input 'code (const "Codice fiscale")) :codice-fiscale)
				 (start-date (input 'start-date (const "Data inizio")) :data-inizio)
				 (end-date (input 'end-date (const "Data fine")) :data-fine))
			    (vert code start-date end-date)) 
	      (button 'ok (const "Submit") :click ()))))

(defparameter plate-section
  (alt plate-form
       (static2 :results (plate start-date end-date) (plate-results plate start-date end-date))))


(defparameter person-section
  (alt person-form
       (static2 :results nil (label (const "search-by-person")))))


(defparameter navbar (navbar (gensym) 
			       (anchor (gensym) (const "Ricerca per veicolo") :click (target (url `(:home / :search-by-plate))))
			       (anchor (gensym) (const "Ricerca per persona") :click (target (url `(:home / :search-by-person))))))
(defparameter aia 
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

;; (defparameter gui-test (hub-spoke ((search-by-plate "Ricerca per targa" search-by-plate)
;; 				     (search-by-person "Ricerca per persona" search-by-person))
;; 				    :home
;; 				    (horz search-by-plate search-by-person)))
;; (defparameter gui-test (alt nil 
;; 			      (static2 :home nil 
;; 				       (label (const "hello")))))

;; (pprint (synth to-list person-form))
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
