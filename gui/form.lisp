(defprod element (form ((id string)
			(element element)
			&key (schema (schema jsschema))))
  (to-list () `(form (:id ,id :schema ,(synth to-list schema) :element ,(synth to-list element))))
  (to-req (path) (vcat (text "Form ~a collegato al seguente formato dati:" id) 
		       (nest 4 (synth to-req schema))
		       (text "e costituito da:") 
		       (synth to-req element path)))
  (to-html (path) (div nil 
		       (text "Form identificato con ~a collegato al seguente formato dati:" (lower id)) 
		       (pre nil (synth to-req schema))
		       (text "e costituito da:") 
		       (synth to-html element path))))



