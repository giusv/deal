(defprod element (vert (&rest (elements (list element))))
  (to-list () `(vert (:elements ,(synth-all to-list elements))))
  (to-req (path) (funcall #'vcat 
		    (text "Concatenazione verticale dei seguenti elementi:")
		    (nest 4 (apply #'vcat (synth-all to-req elements path)))))
  (to-html (path) (div nil (text "Concatenazione verticale ")
		       (if (not  elements) (text "vuota") (text "dei seguenti elementi:"))
		       (apply #'ul (list :class 'list-group)
			      (mapcar #'listify (synth-all to-html elements path))))))

(defmacro vert* (&rest elements)
  (let ((new-elements (mapcar #'(lambda (element)
			  (cons (gensym) element)) 
			      elements)))
    `(bindall ,new-elements
      (vert ,@(mapcar #'car new-elements)))))
