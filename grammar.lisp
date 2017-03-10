(defun arg-list (sym args &optional (pref nil) (func #'car))
  (let ((l (mapcar func (gethash sym args))))
    (if (null l)
	nil
	(if (null pref)
	    l
	    (cons pref l)))))

(defun make-lambda-list (args)
  (let* ((req (arg-list 'req args nil #'identity))
	 (opt (arg-list 'opt args '&optional #'identity))
	 (rest (arg-list 'rest args '&rest #'identity))
	 (key (arg-list 'key args '&key #'identity)))
    ;; (pprint (gethash 'key args))
    (append req opt rest key)))

(defun add-parameters (lambda-list key &rest pars)
  (let* ((args (parse (destruc) lambda-list)))
    (setf (gethash key args) (append (gethash key args) pars))
    (make-lambda-list args)))

(defun arg-names (lambda-list)
  (let* ((args (parse (destruc) lambda-list))
	 (req (arg-list 'req args))
	 (opt (arg-list 'opt args))
	 (rest (arg-list 'rest args))
	 (key (arg-list 'key args #'caadr)))
    (append req opt rest key)))

(defun untype (lambda-list)
  (let* ((args (parse (destruc) lambda-list))
	 (req (arg-list 'req args))
	 (opt (arg-list 'opt args '&optional))
	 (rest (arg-list 'rest args '&rest))
	 (key (arg-list 'key args '&key #'caadr)))
    (append req opt rest key)))

(defmacro synth (func arg &rest args)
  `(and ,arg 
   	(gethash ',func ,arg)
   	(funcall (gethash ',func ,arg) ,@args))
  ;; `(funcall (gethash ',func ,arg) ,@args)
  )

(defmacro synth-all (func lst &rest args)
  `(mapcar #'(lambda (arg) (synth ,func arg ,@args))
	   ,lst))

(defmacro synth-plist (func plst &rest args)
  `(apply #'append (mapcar #'(lambda (pair) (list (car pair) (synth ,func (cadr pair) ,@args)))
			   (group ,plst 2))))

(defmacro synth-plist2 (func plst &rest args)
  `(apply #'append (mapcar #'(lambda (pair) (list (synth ,func (cadr pair) ,@args)))
			   (group ,plst 2))))

(defmacro synth-plist-both (key-func value-func plst &rest args)
  `(apply #'append (mapcar #'(lambda (pair) (list (synth ,key-func (car pair)) (synth ,value-func (cadr pair) ,@args)))
			   (group ,plst 2))))
(defmacro synth-list-merge (n func plst &rest args)
  `(mapcar #'(lambda (pair) (funcall ,func pair ,@args))
	   (group ,plst ,n)))

(defmacro synth-plist-merge (func plst &rest args)
  `(mapcar #'(lambda (pair) (funcall ,func pair ,@args))
	   (group ,plst 2)))

(defmacro defprod-old (base (name lambda-list) &rest attrs)
  (declare (ignorable base))
  (labels ((attr-name (attr) 
	     (car attr))
	   (attr-func (attr)  
	     `#'(lambda (,@(second attr))
		  (declare (ignorable ,@(second attr))) 
		  ,(third attr))))
    `(defun ,name (,@(untype lambda-list))
       (pairhash ',(append #|slots|# (mapcar #'attr-name attrs)) 
		(list #|,@slots|# ,@(mapcar #'attr-func attrs))))))

(defmacro defprod (base (name lambda-list) &rest attrs)
  (let ((accessors (mapcar #'(lambda (arg)
			       (list arg () arg))
			   (arg-names lambda-list))))
    `(defprod-old ,base (,name ,lambda-list) ,@(append accessors attrs))))



