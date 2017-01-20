(defmacro mac (expr)
  `(pprint (macroexpand-1 ',expr)))

;; (defun make-slot (name)
;;   `(,name 
;;     :initarg ,(intern (symbol-name name) "KEYWORD")
;;     :accessor ,name
;;     ))


(defmacro def-typeclass (class &body methods)
`(progn 
     (defclass ,class () ())
     ,@(mapcar #'(lambda (method) 
		   `(defgeneric ,method (,class))) 
	       methods))
  )

;; (defmacro def-instance (class (instance &body slots) &body methods)
;;   `(progn 
;;      (defclass ,instance (,class)
;;        ,(mapcar #'make-slot slots))
;;      (defun ,instance ,slots
;;        (make-instance ',instance 
;; 		      ,@(reduce #'append (mapcar #'(lambda (slot) `(,(intern (symbol-name slot) "KEYWORD") ,slot)) slots) :initial-value nil)))
;;      ,@(mapcar #'(lambda (method) 
;; 		   (destructuring-bind (name func) method
;; 		     `(defmethod ,name ((,class ,instance))
;; 			(funcall #'(lambda (,@slots) ,func)
;; 				 ,@(mapcar #'(lambda (slot) 
;; 					       `(,slot ,class)) slots))))) methods)))

(defun make-arg-list (slots)
  (apply #'concatenate 
	 'list
	 (mapcar #'(lambda (slot)
		     (case (third slot)
		       (required `(,(first slot)))
		       (rest `(&rest ,(first slot)))))
		 slots)))
(defun make-assignments (slots)
  (apply #'concatenate 
	 'list
	 (mapcar #'(lambda (slot)
		     `(,(intern (symbol-name (first slot)) 
				"KEYWORD") ,(first slot)))
		 slots)))

(defun make-slot2 (slot)
  (destructuring-bind (name type flag) slot
    `(,name
      :initarg ,(intern (symbol-name name) "KEYWORD")
      :accessor ,name
      )))

(defmacro def-instance (class (instance &body slots) &body methods)
  `(progn 
     (defclass ,instance (,class)
       ,(mapcar #'make-slot2 slots))
     (defun ,instance ,(make-arg-list slots)
       (make-instance ',instance 
       		      ,@(make-assignments slots)))
     ,@(let ((slot-names (mapcar #'first slots)))
	    (mapcar #'(lambda (method) 
			(destructuring-bind (name func) method
			  `(defmethod ,name ((,class ,instance))
			     (funcall #'(lambda (,@slot-names) ,func)
				      ,@(mapcar #'(lambda (slot) 
						    `(,slot ,class)) slot-names))))) methods))))
(defmacro def-instance2 (class (instance &body slots) &body methods)
  `(progn 
     (defclass ,instance (,class)
       ,(mapcar #'make-slot2 slots))
     (defun ,instance ,(make-arg-list slots)
       (make-instance ',instance 
       		      ,@(make-assignments slots)))
     ,@(let ((slot-names (mapcar #'first slots)))
	    (mapcar #'(lambda (method) 
			(destructuring-bind (name func (args)) method
			  `(defmethod ,name ((,class ,instance))
			     (funcall #'(lambda (,@slot-names) ,func)
				      ,@(mapcar #'(lambda (slot) 
						    `(,slot ,class)) slot-names))))) methods))))



(defmacro def-cool (class instance slots &body methods)
  (destruc body))
(defun destruc (pat)
  (format t "~a~%" pat)
  (format t "~a~%" (listp pat))
  (format t  "~a~%" (car (cdr pat)))
  (cond ((null pat) nil)
	((listp (car pat)) (apply #'list (caar pat) (destruc (cdr pat))))
	((eq (car pat) '&rest) (funcall #'list '&rest (caadr pat)))
	((eq (car pat) '&optional )))

  ;; (if (null pat)
  ;;     nil
  ;;     (let (( (cond ((listp (car pat)) (caar pat))
  ;; 			((eq (car pat) '&rest) (caadr pat))
  ;; 			(t nil))))
  ;; 	(if elem
  ;; 	    (apply #'list elem (destruc (cdr pat))))))
  )
;; (def-typeclass doc2
;;   to-list
;;   java)

;; (def-instance doc2 
;;     (nest 
;;      (amount number required) 
;;      (doc doc2 required)))
;; (def-instance doc2
;;     (vcat
;;      (docs (list doc2) rest)))
;; (def-instance doc2
;;     (text
;;      (template string required)
;;      (args (list (or number string)) rest)))


;; (defun foo (first &rest rest &key a b c)
;;   (list first rest a b c))