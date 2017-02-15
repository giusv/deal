

(defprod element (input ((id string)
			 &optional (expr expression)
			 &key (binding (binding filter))))
  (to-list () `(input (:id ,id :expr ,(synth to-list expr) :binding ,(synth to-list binding))))
  ;; (to-req (path) (vcat (nest 4 (vcat (if expr (hcat ))
  ;; 				     ))))
  (to-html (path) (div (list :class 'well) 
		       (div nil (text "Campo di input identificato come ~a " (lower id)) 
			    (if (or expr binding) (text "con le seguenti caratteristiche:"))
			    (ul (list :class 'list-group)
				(if expr (hcat (text "inizializzato con ") (synth to-html expr)))
				(if binding (hcat (text "legato all'elemento ") (synth to-req binding))))))))