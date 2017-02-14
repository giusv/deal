(defprod element (button ((id string) (expr expression)
			  &key (click (click process)) (hover (hover process))))
  (to-list () `(button (:id ,id :expr ,(synth to-list expr) 
			    :click ,(synth to-list click)
			    :hover ,(synth to-list hover))))
  (to-req (path) (vcat (hcat (text "Pulsante identificato come ~a e etichettato con la seguente espressione:" (lower id)) 
			     (synth to-req expr))
		       (nest 4 (hcat (text "Sottoposto a click, ") (synth to-req click)))
		       (synth to-req hover)))
  (to-html (path) (div (list :class 'well) 
		       (div nil (text "Pulsante identificato come ~a e etichettato con la seguente espressione:" (lower id)) 
			    (synth to-html expr))
		       (if click (div nil (text "Sottoposto a click, ") (synth to-html click)))
		       (if hover (div nil (text "Sottoposto a hover, ") (synth to-html hover))))))

(defprod element (input ((id string)
			 &optional (expr expression)
			 &key (binding (binding filter))))
  (to-list () `(input (:id ,id :expr ,(synth to-list expr) :binding ,(synth to-list binding))))
  ;; (to-req (path) (vcat (nest 4 (vcat (if expr (hcat ))
  ;; 				     ))))
  (to-html (path) (div (list :class 'well) 
		       (div nil (text "Campo di input identificato come ~a " (lower id)) 
			    (if (or expr binding) (text "con le seguenti caratteristiche:"))
			    (ul (list :class 'list-group)
				(if expr (hcat (text "inizializzato con ") (synth to-html expr)))
				(if binding (hcat (text "legato all'elemento ") (synth to-req binding))))))))

(defprod element (label ((expr expression)))
  (to-list () `(label :expr ,(synth to-list expr)))
  (to-req (path) (funcall #'hcat (text "Etichetta inizializzata con la seguente espressione:") 
			  (synth to-req expr)))
  (to-html (path) (div nil (text "Etichetta inizializzata con la seguente espressione: ") 
		       (synth to-html expr))))

(defprod element (horz (&rest (elements (list element))))
  (to-list () `(horz (:elements ,(synth-all to-list elements))))
  (to-req (path) (funcall #'vcat 
			  (text "Concatenazione orizzontale dei seguenti elementi:")
			  (nest 4 (apply #'vcat (synth-all to-req elements path)))))
  (to-html (path) (div nil (text "Concatenazione orizzontale ")
		       (if (not  elements) (text "vuota") (text "dei seguenti elementi:"))
		       (apply #'ul (list :class 'list-inline)
			      (mapcar #'listify (synth-all to-html elements path))))))

(defprod element (vert (&rest (elements (list element))))
  (to-list () `(vert (:elements ,(synth-all to-list elements))))
  (to-req (path) (funcall #'vcat 
		    (text "Concatenazione verticale dei seguenti elementi:")
		    (nest 4 (apply #'vcat (synth-all to-req elements path)))))
  (to-html (path) (div nil (text "Concatenazione verticale ")
		       (if (not  elements) (text "vuota") (text "dei seguenti elementi:"))
		       (apply #'ul (list :class 'list-group)
			      (mapcar #'listify (synth-all to-html elements path))))))

(defprod element (alt ((default element) &rest (elements (list named-element))))
  (to-list () `(alt (:default ,(synth to-list default) :elements ,(synth-all to-list elements)))) 
  (to-req (path)
	  (funcall #'vcat 
		   (text "Scelta tra le seguenti viste:")
		   (nest 4 (apply #'vcat (synth-all to-req (cons default elements) path)))))
  (to-html (path)
	   (apply #'div nil 
		  (text "Scelta ")
		  (if (not elements) (text "vuota") (text "tra le seguenti viste:"))
		  (apply #'ul (list :class 'list-group)
			 (synth to-html default path)
			 (mapcar #'listify (synth-all to-brief elements path)))
		  (synth-all to-html elements path))))


(defprod named-element (static ((name string) 
				(queries (list expression))
				(element element)))
  (to-list () `(static (:name ,name :queries ,queries :element ,(synth to-list element))))
  (to-req (path) (let ((newpath (chain (static-chunk name) path)))
		   (vcat (text "Elemento statico di nome ~a" 
			       (lower name)) 
			 (hcat (text "percorso: ") (synth to-url newpath))
			 (synth to-req element newpath))))
  (to-brief (path) (let ((newpath (chain (static-chunk name) path)))
		     (synth output newpath) 
		     (div nil 
			  (text "Elemento statico di nome ~a " (lower name)) 
			  (parens (hcat (text "percorso: ") (synth to-url newpath))))))
  (to-html (path) (let ((newpath (chain (static-chunk name) path)))
		    (div nil 
			    (h3 nil (text "Vista statica ~a " (lower name)) 
				(parens (hcat (text "percorso: ") (synth to-url newpath))))
			    (synth to-html element newpath)))))

(defprod named-element (dynamic ((name string) 
				 (queries (list expression))
				 (element element)))
  (to-list () `(dynamic(:name ,name :queries ,queries :element ,(synth to-list element))))
  (to-brief (path) (let ((newpath (chain (dynamic-chunk name) path)))
		     (div nil (text "Elemento dinamico di nome ~a " (lower name)) 
			  (parens (hcat (text "percorso: ") (synth to-url newpath))))))
  (to-req (path) (let ((newpath (chain (dynamic-chunk name) path)))
		   (vcat (text "Elemento dinamico di nome ~a" 
			       name) 
			 (hcat (text "percorso: ") (synth to-url newpath))
			 (synth to-req element newpath))))
  (to-html (path) (let ((newpath (chain (dynamic-chunk name) path)))
		    (div nil 
			 (h3 nil (text "Vista dinamica ~a " (lower name)) 
			     (parens (hcat (text "percorso: ") (synth to-url newpath))))
			 (synth to-html element newpath)))))


(defprod element (abst ((parameters (list parameter))
		       (element element)))
  (to-list () `(abst (:parameters ,(synth-all to-list parameters) :element ,(synth to-list element))))
  (to-req (path) (vcat (text "Elemento parametrico con parametri:")
		   (nest 4 (apply #'vcat (synth-all to-req parameters)))
		   (synth to-req element path)))
  (to-html (path) (div nil (text "Elemento parametrico ")
		       (synth-all to-html parameters)
		       (synth to-html element path))))

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
			   fields))))
  (to-html (path)
	   (let* ((sch (synth schema query)) 
		(fields (pairlis sch (synth-all to-html (apply render sch) path))))
	     (apply #'div nil 
		    (text "Tabella ") 
		    (if (not  fields) (text "vuota") (text "con i seguenti campi:"))
		    (mapcar #'listify 
			    (mapcar #'(lambda (pair)
					(text "~a: " (car pair)) (cdr pair))
				    fields))))))

(defmacro dynamic2 (name queries element)
  `(dynamic ',name ,queries 
	    (let ((,name (path-parameter ',name)))
	      ,element)))

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
      (condition (<equal> (synth response resp) (const "200"))
		 (target (void))
		 (target (void)))))

(defparameter *gui* 
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

(write-file "d:/giusv/temp/test.html" 
	    (synth to-string 
		   (synth to-doc (html nil 
				       (head nil 
					     (title nil (text "GUI"))
					     (meta (list :charset "utf-8"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css")))
				       (body nil (synth to-html *gui* (void))))) 0))
;;(synth output (synth to-req *gui* (void)) 0)


