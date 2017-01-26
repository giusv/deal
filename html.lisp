(defmacro deftag (name)
  `(defun ,name (&optional attrs &rest body)
     (labels ((open-tag (as) (format nil "<~(~a~)~{ \"~(~a~)\"=~a~}>" ',name as))
	      (close-tag () (format nil "</~(~a~)>" ',name))
	      (open-close-tag (as) (format nil "<~(~a~)~{ \"~(~a~)\"=~a~}>" ',name as)))
       (if (null body)
	   (text  (open-close-tag attrs))
	   (vcat (text  (open-tag attrs))
		 (nest 4 (apply #'vcat body))
		 (text  (close-tag)))))))



(defmacro deftags (&rest names)
  `(progn
     ,@(mapcar #'(lambda (name)
		   `(deftag ,name))
		 names)))

(deftags div h1)


(format t "~a" (synth pretty (div (list :id 1) 
				  (h1 nil 
				      (text "hello"))) 0))