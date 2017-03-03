(defmacro defentity (name ent)
  `(defparameter ,name ,ent))

(defun klass (name &rest body)
  (vcat (text "public klass ~a{" name)
	(nest 4 (apply #'vcat body))
	(text "}")))


(defun annotation (name &optional vals)
  (if (null vals)
      (text "@~a" (upper name))
      (if (atom vals)
	  (text "~a(~a)" name vals)
	  (text "more"))))

(defun field (name type annotations)
  (apply #'vcat 
	 (mapcar #'(lambda (annotation)
		     (destructuring-bind (name &optional vals) annotation
		       (annotation name vals))) 
		 annotations)
	 (list (text "private ~a ~a;" (upper type) (lower name)))))

(defun setter (attribute)
  (let ((nm (slot-value 'name attribute))
	(tp (slot-value 'type  attribute)))
    (vcat (text "public void-url set~a(~a ~a){" nm tp nm)
	  (nest 4 (text "this.~a = ~a;" nm nm))
	  (text "}"))))

(defun getter (attribute)
  (let ((nm (slot-value 'name attribute))
	(tp (slot-value 'type  attribute)))
    (vcat (text "public ~a get~a(){" tp nm)
	  (nest 4 (text "return ~a" nm))
	  (text "}"))))

(defprod primitive (attribute ((name string) 
			       (type string)))
  (java (annotations) (field name type annotations)) 
  (to-list () `(attribute :name ,name :type ,type))
  (to-html () (div nil (text "Attributo ~a (~a)" (lower name) (lower type)))))

(defprod primitive (foreign-key ((reference string) &rest (attributes (list attribute))))
  (java () (apply #'vcat (synth-all java attributes (list (list reference))))) 
  (to-list () `(foreign-key :attributes ,(synth-all to-list attributes) :reference ,reference))
  (attributes () (synth-all name attributes))
  (to-html () (apply #'div nil 
                   (text "Foreign key verso ~a costituita dai seguenti attributi:" (lower reference))
                   (synth-all to-html attributes))))

(defprod primitive (primary-key (&rest (attributes (list attribute))))
  (java () (case (length attributes)
	     (0 (error "Empty primary key"))
	     (1 (synth java (first attributes) (list (list 'id))))
	     (otherwise (error "Multiple primary keys not supported")))) 
  (to-list () `(primary-key :attributes ,(synth-all to-list attributes)))
  (attributes () (synth-all name attributes))
  (to-html () (apply #'div nil 
                     (text "Primary key costituita dai seguenti attributi:")
                     (synth-all to-html attributes))))

(defprod primitive (entity ((name string) 
			    (primary primary-key)
			    (fields (list attribute))
			    &rest (foreigns (list foreign-key))))
  (java () (klass (upper name) 
		  (synth java primary)
		  (synth-all java fields nil)
		  (synth-all java foreigns)))
  (to-list () `(entity :name ,name 
		       :primary ,(synth to-list primary)
		       :fields ,(synth-all to-list fields)
		       :foreigns ,(synth-all to-list foreigns)))
  (attributes () (apply #'append (synth attributes primary) (synth-all name fields) (synth-all attributes foreigns)))
  (to-html () (apply #'div nil 
                   (text "Entità di nome ~a costituita da:" (lower name))
                   (synth to-html primary)
                   (apply #'div nil (synth-all to-html fields))
                   (synth-all to-html foreigns))))

(defun pretty-java (entity)
  (synth pretty (synth java entity) 0))



;; (defparameter *people* (entity 'people 
;; 			       (primary-key 
;; 				(attribute 'id 'string))
;; 			       (list (attribute 'name 'string)
;; 				     (attribute 'city 'string))
;; 			       (foreign-key
;; 				'cities
;; 				(attribute 'city-id1 'string)
;; 				(attribute 'city-id2 'string))
;; 			       (foreign-key
;; 				'cars
;; 				(attribute 'car-id1 'string))))

;; (synth attributes *people*)
