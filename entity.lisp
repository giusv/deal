(def-typeclass primitive
  java
  to-list)

(def-instance primitive (attribute name type)
  (java #'(lambda (annotations) (field name type annotations))) 
  (to-list `(attribute :name ,name :type ,type)))
		       
(def-instance primitive (foreign attributes reference)
  (java nil) 
  (to-list `(foreign :attributes ,(mapcar #'to-list attributes) :reference ,reference))))

(def-instance primitive (primary attributes)
  (java (case (length attributes)
	  (1 (funcall (java (first attributes)) (list (list 'id)))))) 
  (to-list `(primary :attributes ,attributes))) 

(def-instance primitive (simple attributes)
  (java (funcall (java (first attributes)) nil)) 
  (to-list `(simple :attributes ,attributes))) 

(def-instance primitive (entity name primary simple foreign)
  (java (class name
	       (vcat-all field  simple)
	       (vcat-all getter simple)
	       (vcat-all setter simple)))
  (to-list))


(defun class (name &rest body)
  (vcat (list (text "public class ~s{" (list name))
	      (apply #'nest 4 body)
	      (text "}" nil))))


(defun annotation (name &optional vals)
  (if (null vals)
      (text "@~a" (list name))
      (if (atom vals)
	  (text "~a(~a)" (list name vals))
	  (text "more" nil))))

(defmacro destructuring-lambda (arg pattern &body body)
  `(lambda (,arg)
    (destructuring-bind ,pattern ,arg ,@body)))


(defun field (name type annotations)
  (vcat (append (mapcar #'(lambda (annotation)
			    (destructuring-bind (name &optional vals) annotation
				(annotation name vals))) 
			annotations) 
		(list (text "private ~s ~s;" (list type name))))))

(defun setter (attribute)
  (let ((nm (slot-value 'name attribute))
	(tp (slot-value 'type  attribute)))
    (vcat (list (text "public void set~s(~s ~s){" (list nm tp nm))
		(nest 4 (text "this.~s = ~s;" (list nm nm)))
		(text "}" nil)))))

(defun getter (attribute)
  (let ((nm (slot-value 'name attribute))
	(tp (slot-value 'type  attribute)))
    (vcat (list (text "public ~s get~s(){" (list tp nm))
		(nest 4 (text "return ~s;" (list nm)))
		(text "}" nil)))))
(defmacro vcat-all (fn lst)
  `(apply #'vcat (mapcar #',fn ,lst)))
