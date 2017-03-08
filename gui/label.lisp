(defprod element (label ((expr expression)))
  (to-list () `(label :expr ,(synth to-list expr)))
  ;; (to-req (path) (funcall #'hcat (text "Etichetta inizializzata con la seguente espressione:") 
  ;;       		  (synth to-req expr)))
  (to-html (path) (div nil 
                       (text "Etichetta inizializzata con la seguente espressione: ") 
		       (synth to-html expr))))
