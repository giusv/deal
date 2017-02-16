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

(defparameter *form*
  (let* ((user *user*)
	 (name (input 'name nil :binding (prop 'name)))
	 (number (input 'number nil :binding (comp (prop 'numbers) (elem))))
	 ;; (numbers (replicate number :binding ((prop 'numbers))))
	 (city (input 'city nil :binding (comp (prop 'addresses) (elem) (prop 'city))))
	 (state (input 'state nil :binding (comp (prop 'addresses) (elem) (prop 'state))))
	 ;; (addresses (replicate address :binding ((prop 'addresses))))
	 (address (vert city state #| :binding (comp (prop 'addresses) (elem)) |#))
	 (ok (button 'ok (const "Submit") :click ())))
    (form 'form user (vert name number address ok))))

;;(synth output (synth to-req *form* (void)) 0)

(defun option-panel (label target)
  (panel (label (const label))
	 (anchor (gensym) (const "Vai alla pagina") :click (target target))))
(defmacro hub-spoke (pairs base layout)
  `(let* ,(mapcar #'(lambda (pair)
		      (destructuring-bind (name label) pair
			`(,name (option-panel ,label ,(url `(,base / ,name))))))
		  pairs)
     ,layout))


(defparameter *aia* 
  (alt nil 
       (static :login nil  
	       (let* ((userid (input 'userid))
		      (passwd (input 'passwd))
		      (ok (button 'ok (const "ok") :click (target (url `(users / { ,(value userid) } / posts)))))
		      (cancel (button 'cancel (const "cancel"))))
		 (vert userid passwd (horz ok cancel))))
       (static :home nil 
	       (hub-spoke ((search-by-plate "Ricerca per targa" )
			   (search-by-person "Ricerca per persona"))
			  home
			  (horz search-by-plate search-by-person)))))

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
				       (body nil (synth to-html *aia* (void))))) 0))
