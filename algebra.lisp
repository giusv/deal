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


