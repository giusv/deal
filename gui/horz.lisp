
(defprod element (horz (&rest (elements (list element))))
  (to-list () `(horz (:elements ,(synth-all to-list elements))))
  (to-req (path) (funcall #'vcat 
			  (text "Concatenazione orizzontale dei seguenti elementi:")
			  (nest 4 (apply #'vcat (synth-all to-req elements path)))))
  (to-html (path) (div nil (text "Concatenazione orizzontale ")
		       (if (not  elements) (text "vuota") (text "dei seguenti elementi:"))
		       (apply #'ul (list :class 'list-inline)
			      (mapcar #'listify (synth-all to-html elements path))))))