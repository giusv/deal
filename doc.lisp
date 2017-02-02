(defun lower (sym)
  (let ((words (mapcar #'string-capitalize (split-str (symbol-name sym)))))
    (format nil "~(~a~)~{~a~}" (car words) (cdr words))))
(defun upper (sym)
  (let ((words (mapcar #'string-capitalize (split-str (symbol-name sym)))))
    (format nil "~{~a~}" words)))


(defun split-str (string &optional (separator "-"))
  (split-str-1 string separator))

(defun split-str-1 (string &optional (separator "-") (r nil))
  (let ((n (position separator string
		     :from-end t
		     :test #'(lambda (x y)
			       (find y x :test #'string=)))))
    (if n
	(split-str-1 (subseq string 0 n) separator (cons (subseq string (1+ n)) r))
      (cons string r))))

(defun flatten (ls &key (test #'atom))
  (labels ((mklist (x) (if (listp x) x (list x))))
    (mapcan #'(lambda (x) (if (funcall test x) (mklist x) (flatten x :test test))) ls)))

(defun flat (ls &optional (test #'atom))
  (if (or (null ls)
	  (funcall test ls))
      ls
      (if (funcall test (car ls))
	  (cons (car ls) (flat (cdr ls) test))
	  (concatenate 'list (flat (car ls) test) (flat (cdr ls) test)))))

(defprod doc (empty ())
  (pretty (indent) ())
  (extent () 0))
(defprod doc (nest ((amount integer) (doc doc)))
  (pretty (indent) (synth pretty doc (+ indent amount)))
  (extent () (+ amount (synth extent doc))))

(defprod doc (text ((template string) &rest (args (list doc))))
  (pretty (indent) (format t "~v,0t~?" indent template args))
  (extent () (length (apply #'format t template args))))

(defprod doc (vcat (&rest (docs (list doc))))
  (pretty (indent) (let ((fdocs (flatten docs :test #'hash-table-p)))
		     (if (null fdocs)
			 ()
			 (format t "~a~%~a" 
				 (synth pretty (car fdocs) indent)
				 (synth pretty (apply #'vcat (cdr fdocs)) indent)))))
  (extent () (let ((fdocs (flatten docs :test #'hash-table-p)))
		     (synth extent (car (last fdocs))))))

(defprod doc (hcat (&rest (docs (list doc))))
  (pretty (indent) (let ((fdocs (flatten docs :test #'hash-table-p)))
		     (print (length fdocs)) 
		     (if (null fdocs)
			 ()
			 (progn (synth pretty (car fdocs) indent)
				(synth pretty (apply #'hcat (cdr fdocs)) (+ indent (synth extent (car fdocs))))))))
  (extent () (let ((fdocs (flatten docs :test #'hash-table-p)))
	       (reduce #'+ (synth-all extent fdocs)))))
(defun dotted (x)
  (and (consp x)
       (atom (car x))
       (and (atom (cdr x))
	    (not (null (cdr x))))))
(defun assoc-list (x)
  (every #'dotted x))

(defparameter *doc* (hcat (text "first")
			  (text "second")))
;; (defparameter *doc* (text "~a~%" 1))
;; (defparameter *doc* (hcat (text "hello")
;; 			  (text "hello ~a" 3)))




;; (format nil "~a~v,0t~a"
;; 	(synth pretty (text "first") 0)
;; 	5
;; 	(format nil "~a~v,0t~a"
;; 		(synth pretty (text "second") 0)
;; 		5
;; 		""))


