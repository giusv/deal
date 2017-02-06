(defprod element (button ((id string) (expr expression)
			  &optional (transition transition)))
  (to-list () `(button (:id ,id :expr ,(synth to-list expr) :transition ,(synth to-list transition))))
  (to-req (path) (funcall #'hcat (text "Il bottone ~a è etichettato con la seguente espressione:" id) 
		      (synth to-req expr))))


(defprod element (input ((id string)
			 &optional (expr expression)))
  (to-list () `(input (:id ,id :expr ,(synth to-list expr))))
  (to-req (path) (funcall #'hcat (text "Il campo di input ~a è inizializzato con" id) 
		      (synth to-req expr))))

(defprod element (label ((expr expression)))
  (to-list () `(label :expr ,(synth to-list expr)))
  (to-req (path) (funcall #'hcat (text "L'etichetta viene inizializzata con la seguente espressione:") 
		      (synth to-req expr))))

(defprod element (horz (&rest (elements (list element))))
  (to-list () `(horz (:elements ,(synth-all to-list elements))))
  (to-req (path) (funcall #'vcat 
		    (text "Concatenazione orizzontale dei seguenti elementi:")
		    (nest 4 (apply #'vcat (synth-all to-req elements path))))))

(defprod element (vert (&rest (elements (list element))))
  (to-list () `(vert (:elements ,(synth-all to-list elements))))
  (to-req (path) (funcall #'vcat 
		    (text "Concatenazione verticale dei seguenti elementi:")
		    (nest 4 (apply #'vcat (synth-all to-req elements path))))))

(defmacro synth-alts (func plst path &rest args)
  `(apply #'append (mapcar #'(lambda (pair) 
			       (list (chain (static-chunk (car pair)) ,path)
				     (synth ,func (cadr pair) (chain (static-chunk (car pair)) ,path) ,@args)))
			   (group ,plst 2))))

(defprod element (alt-old (&rest (elements (plist named-element))))
  (to-list () `(alt (:elements ,(synth-plist to-list elements)))) 
  (to-req (path)
	  (let ((alts (synth-alts to-req elements path))) 
	    (funcall #'vcat 
		     (text "Scelta tra le seguenti viste:")
		     (nest 4 (apply #'vcat 
				    (mapcar #'(lambda (pair)
						(vcat (synth to-url (first pair)) (second pair)))
					    (group alts 2))))))))

(defprod element (alt (&rest (elements (list named-element))))
  (to-list () `(alt (:elements ,(synth-all to-list elements)))) 
  (to-req (path)
	  (funcall #'vcat 
		   (text "Scelta tra le seguenti viste:")
		   (nest 4 (apply #'vcat (synth-all to-req elements path))))))


(defprod named-element (static ((name string) 
				(queries (list expression))
				(element element)))
  (to-list () `(static (:name ,name :queries ,queries :element ,(synth to-list element))))
  (to-req (path) (let ((newpath (chain (static-chunk name) path)))
		   (vcat (text "Elemento statico di nome ~a" 
			       name) 
			 (hcat (text "percorso: ") (synth to-url newpath))
			 (synth to-req element newpath)))))

(defprod named-element (dynamic ((name string) 
				 (queries (list expression))
				 (element element)))
  (to-list () `(static (:name ,name :queries ,queries :element ,(synth to-list element))))
  (to-req (path) (let ((newpath (chain (dynamic-chunk name) path)))
		   (vcat (text "Elemento dinamico di nome ~a" 
			       name) 
			 (hcat (text "percorso: ") (synth to-url newpath))
			 (synth to-req element newpath)))))


(defprod element (abst ((parameters (list parameter))
		       (element element)))
  (to-list () `(abst (:parameters ,(synth-all to-list parameters) :element ,(synth to-list element))))
  (to-req (path) (vcat (text "Elemento parametrico con parametri:")
		   (nest 4 (apply #'vcat (synth-all to-req parameters)))
		   (synth to-req element path))))

(defprod transition (transition ((target url) 
				 &optional (action process)))
  (to-list () `(transition (:target ,target :action ,(synth to-list action)))))

(defmacro dynamic2 (name queries element)
  `(dynamic ',name ,queries 
	    (let ((,name (path-parameter ',name)))
	      ,element)))

(defun post-data (user post)
  (vert (label user)
	(label post)))

(defun post-list (user)
  (vert (label user)
	(alt (static :posts nil
		     (alt (static nil nil 
				  (label (const "user posts")))
			  (dynamic2 post nil 
				    (post-data user post))))
	     (static :profile nil 
		     (label (const "profile"))))))

(defparameter *gui* (alt (static :login nil  
				 (vert (input 'userid)
				       (input 'passwd)
				       (horz (button 'ok (const "ok")) 
					     (button 'cancel (const "cancel")))))
			 (static :home nil 
				 (label (const "welcome")))
			 (static :users nil 
				 (alt (static nil nil 
					      (label (const "user list")))
				      (dynamic2 user nil
					       (post-list user))))))


(synth output (synth to-req *gui* (void)) 0)

