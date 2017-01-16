(defmacro mac (expr)
  `(pprint (macroexpand-1 ',expr)))

(defun make-slot (name)
  `(,name 
    :initarg ,(intern (symbol-name name) "KEYWORD")
    :accessor ,name
    ))

(def-typeclass doc
  pretty)
(def-instance doc (empty)
  (pretty #'(lambda (*) 
	      nil)))
(def-instance doc (text template args)
  (pretty #'(lambda (indent) 
	      (apply #'format nil 
		     (concatenate 'string 
				  (make-string indent :initial-element #\Space) 
						 template 
						 "~%")
		     args))))
(def-instance doc (nest amount doc)
  (pretty #'(lambda (indent) 
	      (funcall (pretty doc) (+ indent amount)))))
(def-instance doc (vcat docs)
  (pretty #'(lambda (indent) 
	      (apply #'concatenate 'string 
		     (mapcar #'(lambda (doc) 
				 (funcall (pretty doc) indent)) docs)))))


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
       (make-instance ',instance ,@mapcar #'(lambda (slot))))
     ,@(mapcar #'(lambda (method) 
		   (destructuring-bind (name func) method
		     `(defmethod ,name ((,class ,instance))
			(funcall #'(lambda (,@slots) ,func)
				 ,@(mapcar #'(lambda (slot) 
					       `(,slot ,class)) slots))))) methods)))

(defparameter *doc* (make-instance 'vcat
				   :docs (list (make-instance 'text :template  "hello" :args nil)
					       (make-instance 'nest :amount 4 :doc (make-instance 'text :template "hello ~a" :args (list 3))))))

  
(def-typeclass tree min-alg rep-alg)
(def-instance tree (leaf val)
  (rep-alg #'(lambda (m) (make-instance 'leaf :val m)))
  (min-alg val))

(def-instance tree (bin left right)
  (rep-alg #'(lambda (m) (make-instance 'bin :left (funcall (rep-alg left) m) :right (funcall (rep-alg right) m))))
  (min-alg (min (min-alg left) (min-alg right))))


(defparameter *tree* (make-instance 'bin 
				    :left (make-instance 'bin 
							 :left (make-instance 'leaf :val 1)
							 :right (make-instance 'leaf :val 2))
				    :right (make-instance 'leaf :val 3)))

(defparameter *tree-out* (funcall (rep-alg *tree*) (min-alg *tree*)))
(defgeneric to-list (t))
(defmethod to-list ((tree leaf))
  `(leaf (:val ,(val tree))))
(defmethod to-list ((tree bin))
  `(bin (:left ,(to-list (left tree)) :right ,(to-list (right tree)))))

