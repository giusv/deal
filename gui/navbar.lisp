(defprod element (navbar ((id symbol) &rest (anchors (list element))))
  (to-list () `(navbar (:id ,id :anchors ,(synth-all to-list anchors))))
  (to-req (path) (funcall #'vcat 
			  (text "Barra di navigazione con i seguenti elementi:")
			  (nest 4 (apply #'vcat (synth-all to-req anchors path)))))
  (to-html (path) (div nil (text "Barra di navigazione ")
		       (if (not  anchors) (text "vuota") (text "composta dai seguenti link:"))
		       (apply #'ul (list :class 'list-group)
			      (mapcar #'listify (synth-all to-html anchors path))))))