(defstruct tuple 
  (fst nil) 
  (snd nil))
(defun tuple (fst snd)
  (make-tuple :fst fst :snd snd)) 

(defun p-succeed (v)
  #'(lambda (input) 
      (list (tuple v input))))

(defun p-fail ()
  #'(lambda (*) ()))

(defun p-sym (a)
  #'(lambda (input) 
      (unless (null input)
	(if (eq a (car input))
	    (list (tuple (car input) (cdr input)))
	    ()))))

(defun <bar> (p q)
  #'(lambda (input) 
      (append (apply p input) (apply q input))))

(defun <star> (p q))