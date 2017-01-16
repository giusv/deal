(defmacro mac (expr)
  `(pprint (macroexpand-1 ',expr)))

(defun make-slot (name)
  `(,name 
    :initarg ,(intern (symbol-name name) "KEYWORD")
    :accessor ,name
    ))

;; (defsum doc
;;   (empty)
;;   (text template args)
;;   (nest amount doc)
;;   (vcat docs))

;; (defalgebra doc pretty
;;   ((empty)
;;    #'(lambda (indent) nil))
;;   ((text template args)
;;    #'(lambda (indent) (apply #'format nil 
;; 			   (concatenate 'string 
;; 					(make-string indent :initial-element #\Space) 
;; 					template 
;; 					"~%")
;; 			   args)))
;;   ((nest amount doc)
;;    #'(lambda (indent) (funcall (pretty doc) (+ indent amount))))
;;   ((vcat docs) 
;;    #'(lambda (indent) (apply #'concatenate 'string 
;; 			   (mapcar #'(lambda (doc) 
;; 				       (funcall (pretty doc) indent)) docs)))))

(def-typeclass doc
  pretty)
(def-instance doc (empty)
  (pretty #'(lambda (indent) 
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
     ,@(mapcar #'(lambda (method) 
		   (destructuring-bind (name func) method
		     `(defmethod ,name ((,class ,instance))
			(funcall #'(lambda (,@slots) ,func)
				 ,@(mapcar #'(lambda (slot) 
					       `(,slot ,class)) slots))))) methods)))


;; (defmacro defsum (name &body args)
;;   `(progn 
;;      (defclass ,name () ())
;;      ,@(mapcar #'(lambda (arg) 
;; 		   `(defclass ,(car arg) (,name) (,@(mapcar #'make-slot (cdr arg))))) 
;; 	       args)))

;; (defun make-slot2 (slot)
;;   `(,(intern (symbol-name slot) "KEYWORD")))

;; (defmacro defsum2 (name &body args)
;;   `(progn 
;;      ,@(mapcar #'(lambda (arg)
;; 		   (destructuring-bind (name &rest slots) arg
;; 		     `(defun ,name ,slots
;; 			`(,name ,(mapcar #'make-slot2 slots))))) 
;; 	       args)))


;; (defsum doc
;;   (empty)
;;   (text format args)
;;   (nest amount doc)
;;   (vcat docs))
 
;; (defclass doc () ())
;; (defclass empty (doc) ())
;; (defclass nest (doc) (amount doc))
;; (defclass vcat (doc) (docs))

;; (defalgebra doc pretty 
;;   ((empty (lambda () (format nil "")))
;;    (text  (lambda (format args) ()))
	 
;;    ))

;; (defsum tree 
;;   (leaf val)
;;   (bin left right))

;; (defalgebra tree min-alg
;;   (leaf (lambda (val) val))
;;   (bin  (lambda (left right) (min (min-alg left) (min-alg right)))))

;; (defgeneric min-alg (tree))
;; (defmethod min-alg ((tree leaf))
;;   (val tree))
;; (defmethod min-alg ((tree bin))
;;   (min (min-alg (left tree)) (min-alg (right tree))))

;; (defgeneric min-alg2 (tree))
;; (defmethod min-alg2 ((tree leaf))
;;   (funcall #'(lambda (val) val) (val tree)))
;; (defmethod min-alg2 ((tree bin))
;;   (funcall #'(lambda (left right) (min (min-alg2 left) (min-alg2 right))) (left tree) (right tree)))

;; (defmacro defalgebra (sum name &body args)
;;  `(progn 
;;      (defgeneric ,name (,sum))
;;      ,@(mapcar #'(lambda (arg)
;; 		   (let ((elem (caar arg))
;; 			 (accessors (cdar arg))
;; 			 (func (second arg)))
;; 		    ;;destructuring-bind ((elem &rest accessors) func) 
;; 		    ;;   arg
;; 		     `(defmethod ,name ((,sum ,elem))
;; 			(funcall #'(lambda (,@accessors) ,func)
;; 				 ,@(mapcar #'(lambda (accessor) 
;; 					       `(,accessor ,sum)) accessors))))) args)))



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

;; (defalgebra tree rep-alg
;;   ((leaf val) 
;;    #'(lambda (m) (make-instance 'leaf :val m)))
;;   ((bin left right) 
;;    #'(lambda (m) (make-instance 'bin :left (funcall (rep-alg left) m) :right (funcall (rep-alg right) m)))))

;; (defalgebra tree min-alg3
;;   ((leaf val)
;;    val)
;;   ((bin left right)
;;    (min (min-alg3 left) (min-alg3 right))))

;;(rep-alg tree (min-alg tree))

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

