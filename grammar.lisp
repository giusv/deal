(defprod tree (fork l r)
  (synthesize (minimum (min (minimum l) (minimum r))))
  (inherit ((replacement l) (replacement))
	   ((replacement r) (replacement))))
(deprod tree (tip i)
	(synthesize (minimum i)
		    (tree (tip replacement)))
	(inherit replacement))
(defstart tree 
    (synthesize tr minimum)
  (inherit replacement))



(defstart doc
    (synthesize pretty)
  (inherit indent))
(defprod doc (text template args)
  (synthesize (pretty (apply #'format nil 
			     (concatenate 'string 
					  (make-string indent :initial-element #\Space) 
					  template)
			     args)))
  (inherit indent indent))

(defprod doc (nest amount doc)
  (synthesize (pretty (pretty doc)))
  (inherit indent (+ amount indent)))
(defprod doc (vcat docs)
  (synthesize (pretty (format nil "~{~a~^~%~}" 
			      (concat pretty (flatten docs)))))
  (inherit indent indent))


(defstart doc
    (synthesize pretty)
  (inherit indent))
(defprod (text template args)
    (synthesize (pretty (apply #'format nil 
			       (concatenate 'string 
					    (make-string indent :initial-element #\Space) 
					    template)
			       args))))

(defprod doc (nest amount doc)
  (synthesize (pretty (pretty doc)))
  (inherit (doc indent) (+ amount indent)))

(defprod doc (vcat doc1 doc2)
  (synthesize (pretty (format nil "~a~%~a}" (pretty doc1) (pretty doc2))))
  (inherit ((doc1 indent) indent) 
	   ((doc2 indent) indent)))




(defstart doc)
(defprod doc (text template args)
  (pretty (indent indent) (apply #'format nil 
				 (concatenate 'string 
					      (make-string indent :initial-element #\Space) 
					      template)
		    args)))

(defprod doc (nest amount doc)
  (pretty (indent (+ amount indent)) (pretty doc)))

(defprod doc (vcat doc1 doc2)
  (pretty (indent ) (format nil "~a~%~a}" (pretty doc1) (pretty doc2)))
  (inherit ((doc1 indent) indent) 
	   ((doc2 indent) indent)))

(defprod term (factor term-prime)
  ((inherit term-prime inh) (val factor)
   (synthesize term val) (syn term-prime)))
(defprod term-prime (times factor term-prime1)
  ((inherit term-prime1 inh) (* (inh term-prime) (val factor))
   (synthesize term-prime syn) (syn term-prime1)))
(defprod term-prime (empty)
  ((synthesize term-prime syn) (inh term-prime1)))
(defprod factor (digit i)
  ((synthesize factor val) i))

(defun group (source n)
  (if (zerop n) (error "zero length"))
  (labels ((rec (source acc)
	     (let ((rest (nthcdr n source)))
	       (if (consp rest)
		   (rec rest (cons (subseq source 0 n) acc))
		   (nreverse (cons source acc))))))
    (if source (rec source nil) nil)))

(defun alist (&rest l)
  (destructuring-bind (key values) (group l 2)
    (pairlis key values)))
(defun term (factor term-prime)
  (list 'factor factor
	'term-prime term-prime
	'inh (val factor)))


(defun nest (amount doc)
  (list 'amount amount
	'doc doc
	))
(defun text (template args))