(defprod element (alt ((default element) &rest (elements (list named-element))))
  (to-list () `(alt (:default ,(synth to-list default) :elements ,(synth-all to-list elements)))) 
  (to-req (path)
	  (funcall #'vcat 
		   (text "Scelta tra le seguenti viste:")
		   (nest 4 (apply #'vcat (synth-all to-req (cons default elements) path)))))
  (to-html (path)
	   (apply #'div nil 
		  (text "Scelta ")
		  (if (not elements) (text "vuota") (text "tra le seguenti viste:"))
		  (apply #'ul (list :class 'list-group)
			 (synth to-html default path)
			 (mapcar #'listify (synth-all to-brief elements path)))
		  (synth-all to-html elements path))))