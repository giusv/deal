(defprod element (form ((id string)
			(element element)
			&key (schema (schema jsschema))))
  (to-list () `(form (:id ,id :schema ,(synth to-list schema) :element ,(synth to-list element))))
  (to-req (path) (vcat (text "Form ~a collegato al seguente formato dati:" id) 
		       (nest 4 (synth to-req schema))
		       (text "e costituito da:") 
		       (synth to-req element path)))
  (to-html (path) (div nil 
		       (text "Form identificato con ~a collegato al seguente formato dati:" (lower id)) 
		       (pre nil (synth to-req schema))
		       (text "e costituito da:") 
		       (synth to-html element path))))

(defprod element (property-form ((id string)
				 (name symbol)
				 (element element)
				 &key (schema (schema jsschema))))
  (to-list () `(property-form (:id ,id :schema ,(synth to-list schema) :element ,(synth to-list element))))
  (to-req (path) (vcat (text "Property-Form ~a collegato al seguente formato dati:" id) 
		       (nest 4 (synth to-req schema))
		       (text "e costituito da:") 
		       (synth to-req element path)))
  (to-html (path) (div nil 
		       (text "Property-Form identificato con ~a collegato al seguente formato dati:" (lower id)) 
		       (pre nil (synth to-req schema))
		       (text "e costituito da:") 
		       (synth to-html element path)))
  (to-model () (list (keyw name) (synth to-model element))))


(defprod element (object-form ((id string)
			       (bindings (list property-form))
			       (element element)
			       &key (schema (schema jsschema))))
  (to-list () `(object-form (:id ,id :schema ,(synth to-list schema) :element ,(synth to-list element))))
  (to-req (path) (vcat (text "Object-Form ~a collegato al seguente formato dati:" id) 
		       (nest 4 (synth to-req schema))
		       (text "e costituito da:") 
		       (synth to-req element path)))
  (to-html (path) (div nil 
		       (text "Object-Form identificato con ~a collegato al seguente formato dati:" (lower id)) 
		       (pre nil (synth to-req schema))
		       (text "produce")
		       (synth to-string (synth to-model (object-form id bindings element)))
		       (text "e costituito da:") 
		       (synth to-html element path)))
  (to-model () (apply #'jobject (apply #'append (synth-all to-model bindings)))))


(defmacro object-form2 (id binds elem)
  `(let* ,(mapcar #'(lambda (bind)
		      (destructuring-bind (name elem key) bind
			`(,name (property-form ',name ,key ,elem))))
		  binds)
     (object-form ,id (list ,@(mapcar #'car binds)) ,elem)))

(defprod element (array-form ((id string)
			      (element element)
			      (min number)
			      (max number)
			      &key (schema (schema jsschema))))
  (to-list () `(array-form (:id ,id :schema ,(synth to-list schema) :element ,(synth to-list element) :min ,min :max ,max)))
  (to-req (path) (vcat (text "Array-Form ~a collegato al seguente formato dati:" id) 
		       (nest 4 (synth to-req schema))
		       (text "e costituito da:") 
		       (synth to-req element path)))
  (to-html (path) (div nil 
		       (text "Array-Form identificato con ~a collegato al seguente formato dati:" (lower id)) 
		       (pre nil (synth to-req schema))
		       (text "e costituito da:") 
		       (synth to-html element path)))
  (to-model () (jarray (synth to-model element))))

;; (defmacro array-form2 (id bind elem)
;;   `(let* ,(destructuring-bind (name elem min max) bind
;; 			      `(,name (property-form ',name ,key ,elem)))
;;      binds
;;      (object-form ,id (list ,@(mapcar #'car binds)) ,elem)))


(defparameter of (object-form2 'of ((uid (input 'userid (const "User id")) :userid)
				    (pwd (input 'password (const "Password")) :password))
			       (vert uid pwd)))

(defparameter af (array-form 'af (input 'userid (const "User id")) 0 1))

(synth output (synth to-string (synth to-model af)) 0)
;; (defparameter af (array-form of 2 'unbounded))

;; (defparameter uf (property-form 'uid :userid (input 'userid (const "User id"))))
;; (defparameter pf (property-form 'pwd :password (input 'password (const "Password"))))
;; (defparameter of (object-form (vert uf pf)))
;; (defparameter of (let ((uf (property-form 'uid :userid (input 'userid (const "User id"))))
;; 		       (pf (property-form 'pwd :password (input 'password (const "Password")))))
;; 		   (object-form 'of (vert uf pf))))

;; (defparameter f (form 'f 
;; 		      *user*
;; 		     (vert of
;; 			   (button 'ok (const "ok") :click (http-post (void) (value of))))))