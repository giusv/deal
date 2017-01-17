(def-typeclass doc
  pretty
  to-list)
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
				  template 
				  "~%")
		     args)))
  (to-list `(text (:template ,template :args ,args))))
(def-instance doc (nest (amount number required) 
			(doc doc required))
  (pretty #'(lambda (indent) 
	      (funcall (pretty doc) (+ indent amount))))
  (to-list `(nest :amount ,amount :doc ,(to-list doc))))
(def-instance doc (vcat (docs (list doc) rest))
  (pretty #'(lambda (indent) 
	      (apply #'concatenate 'string 
		     (mapcar #'(lambda (doc) 
				 (funcall (pretty doc) indent)) docs))))
  (to-list `(vcat :docs ,(mapcar #'to-list docs))))



(defparameter *doc* (vcat (text "hello")
			  (nest 4 (text "hello ~a" 3))))

