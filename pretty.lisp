(defun line (format &rest args)
  `(line ,format ,@args))
(defun line-format (line)
  (second line))
(defun line-args (line)
  (cddr line))

(defun flatten (ls)
  (labels ((mklist (x) (if (listp x) x (list x))))
    (mapcan #'(lambda (x) (if (atom x) (mklist x) (flatten x))) ls)))

(defun nest (amt &rest docs)
  `(nest ,amt (vcat ,@docs)))

(defun nest-amount (nest)
  (second nest))
(defun nest-doc (nest)
  (third nest))

(defun vcat (&rest args)
  `(vcat ,@args))
(defun vcat-docs (vcat)
  (cdr vcat))

(defun doc (&rest args)
  (apply #'nest 0 args))
;; (defun hcat (&rest args)
;;   `(hcat ,@args))

(defun pretty-print (doc)
  (pretty doc 0))

(defun pretty (doc indent)
  (case (car doc) 
    (line (apply #'format nil (concatenate 'string 
					  (make-string indent :initial-element #\Space) 
					  (line-format doc) 
					  "~%") (line-args doc)))
    (nest (apply #'pretty (list (nest-doc doc) (+ indent (nest-amount doc)))))
    (vcat (apply #'concatenate 'string (mapcar #'(lambda (doc) (pretty doc indent)) (vcat-docs doc))))))

(defparameter *doc* (doc (line "hello") 
			  (nest 4 
			    (line "hello ~a" 3)
			    (line "third")
			    (nest 4 
			      (line "fourth")
			      (line "fifth")))))
