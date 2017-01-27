;; (defmacro synth (func arg &rest args)
;;   `(funcall (cdr (assoc ',func ,arg)) ,@args))

(defun arg-list (sym args &optional (pref nil) (func #'car))
  (let ((l (mapcar func (gethash sym args))))
    (if (null l)
	nil
	(if (null pref)
	    l
	    (cons pref l)))))

(defun untype (lambda-list)
  (let* ((args (parse (destruc) lambda-list))
	 (req (arg-list 'req args))
	 (opt (arg-list 'opt args '&optional))
	 (rest (arg-list 'rest args '&rest))
	 (key (arg-list 'key args '&key #'caadr)))
    (append req opt rest key)))

(defmacro synth (func arg &rest args)
  `(funcall (gethash ',func ,arg) ,@args))

(defmacro synth-all (func lst &rest args)
  `(mapcar #'(lambda (arg) (synth ,func arg ,@args))
	   ,lst))





(defmacro defprod (base (name lambda-list) &rest attrs)
  (declare (ignorable base))
  (labels ((attr-name (attr) 
	     (car attr))
	   (attr-func (attr)  
	     `#'(lambda ,(apply #'list (second attr))
		  ,(third attr))))
    `(defun ,name (,@(untype lambda-list))
       (pairhash ',(append #|slots|# (mapcar #'attr-name attrs)) 
		(list #|,@slots|# ,@(mapcar #'attr-func attrs))))))




(defprod tree (tip ((i integer)))
  (minimum () i)
  (tree (rep) (tip rep))
  (to-list () `(tip ,i)))


(defprod tree (fork ((l tree) (r tree)))
  (minimum () (min (synth minimum l) (synth minimum r)))
  (tree (rep) (fork (synth tree l rep) (synth tree r rep)))
  (to-list () `(fork ,(synth to-list l) ,(synth to-list r))))



(defparameter *tree* (fork (tip 1) (fork (tip 2) (tip 3))))


;; (defprod term (factor term-prime)
;;   ((inherit term-prime inh) (val factor)
;;    (synthesize term val) (syn term-prime)))
;; (defprod term-prime (times factor term-prime1)
;;   ((inherit term-prime1 inh) (* (inh term-prime) (val factor))
;;    (synthesize term-prime syn) (syn term-prime1)))
;; (defprod term-prime (empty)
;;   ((synthesize term-prime syn) (inh term-prime1)))
;; (defprod factor (digit i)
;;   ((synthesize factor val) i))



