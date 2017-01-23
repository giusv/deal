;; (defmacro synth (func arg &rest args)
;;   `(funcall (cdr (assoc ',func ,arg)) ,@args))

(defmacro synth (func arg &rest args)
  `(funcall (gethash ',func ,arg) ,@args))

(defmacro synth-all (func lst &rest args)
  `(mapcar #'(lambda (arg) (synth ,func arg ,@args))
	   ,lst))


(defmacro defprod (base (name &optional slots) &rest attrs)
  (labels ((attr-name (attr) 
	     (car attr))
	   (attr-func (attr)  
	     `#'(lambda ,(apply #'list (second attr))
		  ,(third attr))))
    `(defun ,name (,@slots)
       (pairhash ',(append #|slots|# (mapcar #'attr-name attrs)) 
		(list #|,@slots|# ,@(mapcar #'attr-func attrs))))))


(defun pairhash (keys vals)
  (let ((table (make-hash-table)))
    (mapcar #'(lambda (key val) (setf (gethash key table) val)) keys vals)
    table))

(defprod tree (tip (i))
  (minimum () i)
  (tree (rep) (tip rep))
  (to-list () `(tip ,i)))


(defprod tree (fork (l r))
  (minimum () (min (synth minimum l) (synth minimum r)))
  (tree (rep) (fork (synth tree l rep) (synth tree r rep)))
  (to-list () `(fork ,(synth to-list l) ,(synth to-list r))))



(defparameter *tree* (fork (tip 1) (fork (tip 2) (tip 3))))

(defun destruc (pat)
  (if (null pat)
      nil
      (cond ((eq (length (car pat)) 2) (apply #'list (caar pat) (destruc (cdr pat))))
	    ((eq (car pat) '&rest) (destruc (cadr pat)))
	    (t nil))))

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



