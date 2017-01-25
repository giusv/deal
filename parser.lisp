(defstruct tuple 
  (fst nil) 
  (snd nil))
(defun tuple (fst snd)
  (make-tuple :fst fst :snd snd)) 
(defun result (x)
  #'(lambda (s) 
      (list (tuple x s))))

(defun apply-parser (parser input)
  (funcall parser input))
(defun parse (parser input)
  (let ((res (car (apply-parser parser input)))) 
    (if (null res) 
	nil
	(tuple-fst res))))


(defun bind (p q)
  #'(lambda (s)
      (apply #'concatenate 
	     'list
	     (mapcar #'(lambda (tuple)
			 (let ((x (tuple-fst tuple))
			       (s1 (tuple-snd tuple)))
			   (apply-parser (funcall q x) s1)))
		     (apply-parser p s)))))


(defun fail ()
  #'(lambda (*) ()))
  
(defun item ()
  #'(lambda (s) (cond ((null s) ())
			(t (list (tuple (car s) (cdr s)))))))


(defun dooo (&rest binds)
  (if (eq (length binds) 1) 
      (car binds)
      (case (length (car binds))
	(1 `(bind ,(cadar binds) #'(lambda (*) ,(apply #'dooo (cdr binds)))))
	(2 `(bind ,(cadar binds) #'(lambda (,(caar binds)) ,(apply  #'dooo (cdr binds))))))))

(defmacro doo (&rest binds)
  (if (eq (length binds) 1) 
      (car binds)
      (case (length (car binds))
	(1 `(bind ,(cadar binds) #'(lambda (*) ,(apply #'dooo (cdr binds)))))
	(2 `(bind ,(cadar binds) #'(lambda (,(caar binds)) ,(apply #'dooo (cdr binds))))))))




(defun sat (p)
  (doo (s (item))
       (if (funcall p s)
 	   (result s)
	   (fail))))
;;; (parse (bind (item) #'(lambda (a) (bind (item) #'(lambda (*) (result (list (incf a))))))) '(1 2))

(defun sym (m)
  (doo (a (sat #'(lambda (x) (eq m x))))
       (result a)))

(defun choose (p q)
  #'(lambda (s)
      (let ((ps (apply-parser p s)))
	(if (null ps)
	    (apply-parser q s)
	    ps))))

(defun zero ()
  #'(lambda (*) ()))
(defun plus (p q)
  #'(lambda (s)
      (append (apply-parser p s) (apply-parser q s))))
(defun choice (p q)
  #'(lambda (s)
      (let ((res (apply-parser (plus p q) s)))
	(if (null res)
	    nil
	    (car res)))))

(defun many (p)
  (choose (many1 p)
	  (result nil)))
(defun many1 (p)
  (doo (a p)
       (as (many p))
       (result (cons a as))))
(defun sepby (p sep)
  (choose (sepby1 p sep)
	  (result nil)))
(defun sepby1 (p sep)
  (doo (a p)
       (as (many (doo (* sep)
		      p)))
       (result (cons a as))))