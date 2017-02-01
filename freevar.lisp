(defparameter f #'(lambda (x) (+ i x)))

(defparameter g #'(lambda (i) #'(lambda (x) (+ i x))))

(defmacro fp (x) 
  `#'(lambda (,x) (+ i ,x)))
(defparameter h #'(lambda (i) (fp x)))