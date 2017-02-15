(defprod element (panel ((header element)
			 (body element)
			 &optional (footer element)))
  (to-list () `(panel (:header ,(synth to-list header) :body ,(synth to-list body) :footer ,(synth to-list footer))))
  (to-req (path) (text "Pannello composto da????????"))
  (to-html (path) (div (list :class 'well) 
		       (div nil 
			    (text "Pannello composto da: ") 
			    (description-list (apply #'list (text "header") (text "body") (if footer (text "footer")))
					      (synth-all to-html (apply #'list header body footer) path))))))