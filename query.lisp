(defprod query (table ((name (reference entity))))
  (to-list () `(table :name ,name))
  (schema () (synth attributes (symbol-value name))))

(defprod query (project ((query query)
			 &rest (attributes (list attribute)))) 
  (to-list () `(project :attributes ,@attributes :query ,(synth to-list query)))
  (schema () attributes))

(defprod query (restrict ((query query)
			(expression bexpr))) 
  (to-list () `(restrict :expression ,(synth to-list expression) :query ,(synth to-list query)))
  (schema () (synth attributes query)))

(defparameter *query* (project (restrict (table '*people*) (+equal+ (+true+) (+true+))) 'id 'name))

(synth schema *query*)


;;(synth attributes *people*)

