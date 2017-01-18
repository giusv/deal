(def-typeclass doc
  pretty
  to-list)

(defun flatten (ls)
  (labels ((mklist (x) (if (listp x) x (list x))))
    (mapcan #'(lambda (x) (if (atom x) (mklist x) (flatten x))) ls)))

(def-instance doc (empty)
  (pretty #'(lambda (*) 
	      nil))
  (to-list `(empty)))
(def-instance doc (text (template string required) 
			(args nil rest))
  (pretty #'(lambda (indent) 
	      (apply #'format nil 
		     (concatenate 'string 
				  (make-string indent :initial-element #\Space) 
				  template)
		     args)))
  (to-list `(text (:template ,template :args ,args))))
(def-instance doc (nest (amount number required) 
			(doc doc required))
  (pretty #'(lambda (indent) 
	      (funcall (pretty doc) (+ indent amount))))
  (to-list `(nest :amount ,amount :doc ,(to-list doc))))

(def-instance doc (vcat (docs (list doc) rest))
  (pretty #'(lambda (indent)
	      (format nil "~{~a~^~%~}" 
		      (mapcar #'(lambda (doc) (funcall (pretty doc) indent)) 
			      (flatten docs)))))
  (to-list `(vcat :docs ,(mapcar #'to-list docs))))



(defparameter *doc* (vcat (text "hello")
			  (nest 4 (text "hello ~a" 3))))

(defun test-rest (&rest args)
  (princ args))