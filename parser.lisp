(defstruct tuple 
  (fst nil) 
  (snd nil))
(defun tuple (fst snd)
  (make-tuple :fst fst :snd snd)) 
(defun result (v)
  #'(lambda (inp) (tuple v inp)))

(defun zero ()
  #'(lambda () ()))
  
(defun item ()
  #'(lambda (inp) (cond ((null inp) ())
			(t (list (tuple (car inp) (cdr inp)))))))

(defun parse (parser input)
  (funcall (funcall parser) input))