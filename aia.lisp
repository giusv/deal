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

(defparameter *aia* 
  (alt nil 
       (static :login nil  
	       (let* ((userid (input 'userid))
		      (passwd (input 'passwd))
		      (ok (button 'ok (const "ok") :click (target (url `(users / { ,(value userid) } / posts)))))
		      (cancel (button 'cancel (const "cancel"))))
		 (vert userid passwd (horz ok cancel))))
       (static :home nil 
	       (vert (label (const "welcome"))
		     (table 'table *query* #'render-fields)
		     (button 'go (const "go") :click (*submit-user*))))
       (static :users nil
	       (alt (label (const "user list"))
		    (dynamic2 user nil
			      (post-list user))))
       (static :form nil
	       *form*)))


(write-file "d:/giusv/temp/aia.html" 
	    (synth to-string 
		   (synth to-doc (html nil 
				       (head nil 
					     (title nil (text "AIA"))
					     (meta (list :charset "utf-8"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css")))
				       (body nil (synth to-html *aia* (void))))) 0))
