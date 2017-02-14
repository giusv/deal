(defprod element (form ((id string)
			(schema jsschema)
			(element element)))
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

(defparameter *form*
  (let* ((user *user*)
	 (name (input 'name nil :binding (prop 'name)))
	 (number (input 'number nil :binding (comp (prop 'numbers) (elem))))
	 ;; (numbers (replicate number :binding ((prop 'numbers))))
	 (city (input 'city nil :binding (comp (prop 'addresses) (elem) (prop 'city))))
	 (state (input 'state nil :binding (comp (prop 'addresses) (elem) (prop 'state))))
	 ;; (addresses (replicate address :binding ((prop 'addresses))))
	 (address (vert city state #| :binding (comp (prop 'addresses) (elem)) |#))
	 (ok (button 'ok (const "Submit") :click ())))
    (form 'form user (vert name number address ok))))

(synth output (synth to-req *form* (void)) 0)

