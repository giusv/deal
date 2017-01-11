(defparameter *db* nil)
(defstruct attr
     name type)
(defstruct ent
  name attrs constr)
(defmacro defattr (name type)
  `(defparameter ,name
	 (make-attr :name ',name
		    :type ,type)))
(defmacro defent (name attrs constr)
  `(defparameter ,name
     (make-ent :name ',name
	       :attrs ,attrs
	       :constr ,constr)))

(defun defdb (&rest entities)
  (setf *db* entities))

(defent people nil nil)
(defdb people)

(defparameter *indentation* 0)
(defmacro class (name &rest body)
  () (format t "public class ~A {" name)
  ())


(defparameter *test* 
  '(fork (tip 1) (fork (tip 2) (tip 3))))
