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
  (output (indent) ())
  (to-string (indent) ())
  (extent () 0))
(defprod doc (nest ((amount integer) (doc doc)))
  (output (indent) (synth output doc (+ indent amount)))
  (to-string (indent) (with-output-to-string (*standard-output*)
			(synth output (nest amount doc) indent)))
  (extent () (+ amount (synth extent doc))))

(defprod doc (text ((template string) &rest (args (list doc))))
  (output (indent) (format t "~v,0t~?" indent template args))
  (to-string (indent) (with-output-to-string (*standard-output*)
		      (synth output (text template args) indent)))
  (extent () (length (apply #'format nil template args))))

(defprod doc (vcat (&rest (docs (list doc))))
  (output (indent) (let ((fdocs (flatten docs :test #'hash-table-p)))
		     (unless (null fdocs) 
		       (progn (synth output (car fdocs) indent)
			      (unless (null (cdr fdocs)) 
				(progn (format t "~%"))
				(synth output (apply #'vcat (cdr fdocs)) indent))))))
  (to-string (indent) (with-output-to-string (*standard-output*)
			(synth output (apply #'vcat docs) indent)))
  (extent () (let ((fdocs (flatten docs :test #'hash-table-p)))
		     (synth extent (car (last fdocs))))))

(defprod doc (hcat (&rest (docs (list doc))))
  (output (indent) (let ((fdocs (flatten docs :test #'hash-table-p)))
		     (unless (null fdocs) 
		     	 (progn (synth output (car fdocs) indent)
		     		(synth output (apply #'hcat (cdr fdocs)) (+ indent (synth extent (car fdocs))))))))
  (to-string (indent) (with-output-to-string (*standard-output*)
			(synth output (apply #'hcat docs) indent)))
  (extent () (let ((fdocs (flatten docs :test #'hash-table-p)))
	       (reduce #'+ (synth-all extent fdocs)))))
(defun dotted (x)
  (and (consp x)
       (atom (car x))
       (and (atom (cdr x))
	    (not (null (cdr x))))))
(defun assoc-list (x)
  (every #'dotted x))

(defun wrap (doc start end &key newline (padding 0))
  (if newline 
      (vcat start doc end)
      (hcat start (padding padding) doc (padding padding) end)))
(defmacro defwrapper (name start end)
  `(defun ,name (doc &key newline (padding 0))
     (wrap doc (text ,start) (text ,end) :newline newline :padding padding)))

(defwrapper parens "(" ")")
(defwrapper brackets "[" "]")
(defwrapper braces "{" "}")
(defwrapper double-quotes "\"" "\"")

(defun padding (p)
  (text "~a" (make-string p :initial-element #\Space)))

(defun comma ()
  (text ","))

(defun punctuate (p newline &rest docs)
  (cond ((null docs) nil)
	((eq 1 (length docs)) (car docs))
	(t (if newline
	       (vcat (hcat (car docs) p) (apply #'punctuate p newline (cdr docs)))
	       (hcat (car docs) p (apply #'punctuate p  newline (cdr docs)))))))



(defparameter *doc* (vcat (hcat (text "public static main(")
				(vcat (text "String[] argv,")
				      (text "int a"))
				(text ") {"))
			  (nest 4 (text "print();"))
			  (text "}")))
;; (defparameter *doc* (text "~a~%" 1))
;; (defparameter *doc* (hcat (text "hello")
;; 			  (text "hello ~a" 3)))



