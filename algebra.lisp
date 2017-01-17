(defmacro mac (expr)
  `(pprint (macroexpand-1 ',expr)))

(defun make-slot (name)
  `(,name 
    :initarg ,(intern (symbol-name name) "KEYWORD")
    :accessor ,name
    ))

(defmacro def-typeclass (class &body methods)
`(progn 
     (defclass ,class () ())
     ,@(mapcar #'(lambda (method) 
		   `(defgeneric ,method (,class))) 
	       methods))
  )

(defmacro def-instance (class (instance &body slots) &body methods)
  `(progn 
     (defclass ,instance (,class)
       ,(mapcar #'make-slot slots))
     (defun ,instance ,slots
       (make-instance ',instance 
		      ,@(reduce #'append (mapcar #'(lambda (slot) `(,(intern (symbol-name slot) "KEYWORD") ,slot)) slots) :initial-value nil)))
     ,@(mapcar #'(lambda (method) 
		   (destructuring-bind (name func) method
		     `(defmethod ,name ((,class ,instance))
			(funcall #'(lambda (,@slots) ,func)
				 ,@(mapcar #'(lambda (slot) 
					       `(,slot ,class)) slots))))) methods)))


(def-typeclass doc2
  to-list
  java)

(def-instance doc2 
    (nest 
     (amount number required) 
     (doc doc2 required)))
(def-instance doc2
    (vcat
     (docs (list doc2) rest)))
(def-instance doc2
    (text
     (template string required)
     (args (list (or number string)) rest)))

(defun foo (first &rest rest &key a b c)
  (list first rest a b c))