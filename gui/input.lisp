(defprod element (input ((id string)
			 (label expression)
			 &key (init (init expression))
			 (binding (binding filter))))
  (to-list () `(input (:id ,id :label ,(synth to-list label) :init ,(synth to-list init) :binding ,(synth to-list binding))))
  ;; (to-req (path) (vcat (nest 4 (vcat (if expr (hcat ))
  ;; 				     ))))
  (to-html (path) (div (list :class 'well) 
		       (div nil (text "Campo di input identificato come ~a " (lower id)) 
			    (if (or init label binding) (text "con le seguenti caratteristiche:"))
			    (maybes (list label (span nil (text "Etichetta")))
				    (list init (span nil (text  "Valore iniziale")))
				    (list binding (span nil (text "Data binding")))))))
  (to-model () (jstring (value (input id label :binding binding))))
;; (to-model (father) (let ((schema (car (funcall binding father))))
;; 		       ;; (pprint (synth to-list (synth instance schema (value (input id label :binding binding)))))
;; 		       ;; (pprint (synth to-list (synth instance schema (const "ddd"))))
;; 		       (synth instance schema (value (input id label :binding binding)))))
)

;; (pprint (synth to-list (synth to-model (input 'userid (const "userid") 
;; 					      :binding (synth to-func (prop 'name))))))
