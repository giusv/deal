(defprod element (button ((id string) (expr expression)
			  &key (click (click process)) (hover (hover process))))
  (to-list () `(button (:id ,id :expr ,(synth to-list expr) 
			    :click ,(synth to-list click)
			    :hover ,(synth to-list hover))))
  (to-req (path) (vcat (hcat (text "Pulsante identificato come ~a e etichettato con la seguente espressione:" id) 
			     (synth to-req expr))
		       (nest 4 (hcat (text "Sottoposto a click, ") (synth to-req click)))
		       (synth to-req hover))))

(defprod element (input ((id string)
			 &optional (expr expression)
			 &key (binding (binding filter))))
  (to-list () `(input (:id ,id :expr ,(synth to-list expr) :binding ,(synth to-list binding))))
  (to-req (path) (vcat (text "Campo di input ~a con le seguenti caratteristiche" id) 
		       (nest 4 (vcat (if expr (hcat (text "inizializzato con ") (synth to-req expr)))
				     (if binding (hcat (text "legato all'elemento ") (synth to-req binding))))))))

(defprod element (label ((expr expression)))
  (to-list () `(label :expr ,(synth to-list expr)))
  (to-req (path) (funcall #'hcat (text "Etichetta inizializzata con la seguente espressione:") 
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

(defprod element (table ((id string)
			 (query query)
			 (render function)))
  (to-list () `(table (:id ,id :query ,(synth to-list query) :render ,render)))
  (to-req (path)
	  (let* ((sch (synth schema query)) 
		(fields (pairlis sch (synth-all to-req (apply render sch) path))))
	    (apply #'vcat 
		   (text "Tabella con i seguenti campi:") 
		   (mapcar #'(lambda (pair)
			       (nest 4 (hcat (text "~a: " (car pair)) (cdr pair))))
			   fields)))))

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

(defun render-fields (id name)
  (list (label (attr id))
	(label (attr name))))
(defparameter *gui* 
  (alt (static :login nil  
	       (let* ((userid (input 'userid))
		      (passwd (input 'passwd))
		      (ok (button 'ok (const "ok") :click (target (url `(users / { ,(value userid) } / posts))
							   ;; (url `(users / { user } / posts / { post }))
								  )))
		      (cancel (button 'cancel (const "cancel"))))
		 (vert userid passwd (horz ok cancel))))
       (static :home nil 
	       (vert (label (const "welcome"))
		     (table 'table *query* #'render-fields)))
       (static :users nil 
	       (alt (static nil nil 
			    (label (const "user list")))
		    (dynamic2 user nil
			      (post-list user))))))


(synth output (synth to-req *gui* (void)) 0)






