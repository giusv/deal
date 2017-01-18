(def-typeclass primitive
  java
  to-list)
(defun class (name &rest body)
  (vcat (text "public class ~s{" name)
	(nest 4 (vcat body))
	(text "}")))


(defun annotation (name &optional vals)
  (if (null vals)
      (text "@~a" name)
      (if (atom vals)
	  (text "~a(~a)" name vals)
	  (text "more"))))

;; (defmacro destructuring-lambda (arg pattern &body body)
;;   `(lambda (,arg)
;;     (destructuring-bind ,pattern ,arg ,@body)))

(defun field (name type annotations)
  (apply #'vcat 
	 (append (mapcar #'(lambda (annotation)
			     (destructuring-bind (name &optional vals) annotation
			       (annotation name vals))) 
			 annotations) 
		 (list (text "private ~s ~s;" type name)))))

(defun setter (attribute)
  (let ((nm (slot-value 'name attribute))
	(tp (slot-value 'type  attribute)))
    (vcat (text "public void set~s(~s ~s){" nm tp nm)
	  (nest 4 (text "this.~s = ~s;" nm nm))
	  (text "}"))))

(defun getter (attribute)
  (let ((nm (slot-value 'name attribute))
	(tp (slot-value 'type  attribute)))
    (vcat (text "public ~s get~s(){" tp nm)
	  (nest 4 (text "return ~s;" nm))
	  (text "}"))))
(defmacro vcat-all (fn lst)
  `(apply #'vcat (mapcar #',fn ,lst)))

(def-instance primitive (attribute 
			 (name string required) 
			 (type string required))
  (java #'(lambda (annotations) (field name type annotations))) 
  (to-list `(attribute :name ,name :type ,type)))

(def-instance primitive (foreign-key
			 (reference nil required)
			 (attributes (list attribute) rest))
  (java (apply #'vcat (mapcar 
		       #'(lambda (attribute) (funcall (java attribute) (list (list reference))))
		       attributes))) 
  (to-list `(foreign-key :attributes ,(mapcar #'to-list attributes) :reference ,reference)))

(def-instance primitive (primary-key
			 (attributes (list attribute) rest))
  (java (case (length attributes)
	  (1 (funcall (java (first attributes)) (list (list 'id)))))) 
  (to-list `(primary-key :attributes ,attributes))) 

;; (def-instance primitive (simple-attrs
;; 			 (attributes nil required))
;;   (java (funcall (java (first attributes)) nil)) 
;;   (to-list `(simple :attributes ,attributes)))


(def-instance primitive (entity 
			 (name string required)
			 (primary primary-key required) 
			 (fields (list attribute) required)
			 (foreigns (list foreign-key) rest))
  (java (class name
	       (java primary)
	       (mapcar #'(lambda (attribute) (funcall (java attribute) nil)) fields)
	       (mapcar #'java foreigns)))
  (to-list `(entity :name ,name 
		    :primary ,(to-list primary)
		    :fields ,(mapcar #'to-list fields)
		    :foreigns ,(mapcar #'to-list foreigns))))

(defun pretty-java (entity)
  (funcall (pretty (java entity)) 0))

(defparameter *people* (entity 'people 
			       (primary-key 
				(attribute 'id 'string))
			       (list (attribute 'name 'string)
				     (attribute 'city 'string))
			       (foreign-key
				'cities
				(attribute 'city-id1 'string)
				(attribute 'city-id2 'string))
			       (foreign-key
				'cars
				(attribute 'car-id1 'string))))

(defparameter *test* 
  (pretty (vcat (text "s") 
		(nest 4 (vcat (field 'a 'b (list (list 'id)))))
		(text "a"))))
(defparameter *test2* (pretty (class 'name)))