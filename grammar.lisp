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
  ((pretty (indent)) (pretty doc (+ amount indent))))

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
  `((amount . ,amount)
    (doc . ,doc)
    ;; (pretty . (#'lambda (doc indent)
    ;; 		(macrolet ((pretty (doc) `(funcall (assoc 'pretty ,doc) doc ,(+ indent amount)))))))
    (pretty . ,#'(lambda (doc indent)
		  (labels ((pretty (doc1 indent) 
			     (funcall (assoc 'pretty doc) doc1 indent)))
		    (pretty doc (+ indent amount)))))))

(defun primary (attributes)
  `((attributes . ,attributes)
    (java . ,#'(lambda (primary)
		 (let ((attributes (assoc 'attributes primary)))
		   (apply #'vcat (mapcar #'field attributes)))))
    (imports . .(lambda (primary)
		 (let ((attributes (assoc 'attributes primary)))
		   (apply #'vcat (mapcar #'import attributes)))))))

(defun entity (name primary simple foreigns)
  `((name . ,name)
    (primary . ,primary)
    (simple . ,simple)
    (foreigns . ,foreigns)
    (java . ,#'(lambda (entity)
		 (let ((name (assoc 'name entity))
		       (primary (assoc 'primary entity)))
		   (compilation-unit
		    (synth (imports primary indent))
		    (class name 
			   ...)))))))
(defmacro synth (func name &rest args)
  `(funcall (cdr (assoc ',func ,name)) ,@args))

(defun synth2 (func name &rest args)
  (funcall (cdr (assoc func ,name)) ,@args))

(defprod primitive 
    (entity primary simple foreigns)
  )



(defun nest (amount doc)
  `((amount . ,amount)
    (doc . ,doc)
    ;; (pretty . (#'lambda (doc indent)
    ;; 		(macrolet ((pretty (doc) `(funcall (assoc 'pretty ,doc) doc ,(+ indent amount)))))))
    ;; (pretty . ,#'(lambda (doc indent)
    ;; 		  (labels ((pretty (doc1 indent) 
    ;; 			     (funcall (assoc 'pretty doc) doc1 indent)))
    ;; 		    (pretty doc (+ indent amount)))))
    (pretty . ,#'(lambda (doc indent)
		   (synth (pretty doc (+ indent amount))))
	    )))

(defmacro defprod (base (name &rest slots) &rest attrs)
  (labels ((attr-name (attr) 
	     (car attr))
	   (attr-func (attr)  
	     `#'(lambda ,(apply #'list (second attr))
		  ,(third attr))))
    `(defun ,name (,@slots)
       (pairlis ',(append slots (mapcar #'attr-name attrs)) 
		(list ,@slots ,@(mapcar #'attr-func attrs))))))

(defun make-slot (name)
  `(name . ,name))

(defun attr-name (attr)
  (first attr))

(defun attr-func (attr)
  #'(lambda () third attr))

(defun flatten (ls)
  (labels ((mklist (x) (if (listp x) x (list x))))
    (mapcan #'(lambda (x) (if (atom x) (mklist x) (flatten x))) ls)))

(defprod doc (nest amount doc)
  (pretty (indent) (synth pretty doc (+ indent amount))))

(defprod doc (text template args)
  (pretty (indent) (apply #'format nil 
			  (concatenate 'string 
				       (make-string indent :initial-element #\Space) 
				       template)
			  args)))

(defprod doc (vcat docs)
  (pretty (indent) (format nil "~{~a~^~%~}" 
			   (mapcar #'(lambda (doc) (synth pretty doc indent)) 
				   docs))))

(defparameter *doc* (text "~a~%" (list 1)))
(defparameter *doc* (vcat (list (text "hello ~a" (list 4))
				(nest 4 (text "hello ~a" (list 3))))))

(defparameter *doc* (nest 4 (text "hello ~a" (list 3))))

(defparameter *closure* (cdr (assoc 'pretty *doc*)))

