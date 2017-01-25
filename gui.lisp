(defprod element (button ((id string) (expr expression)
			  &optional (transition transition)))
  (to-list () `(button (:id ,id :expr ,expr :transition ,(synth to-list transition)))))

(defprod element (input ((id string)
			 (expr expression)))
  (to-list () `(input (:id ,id :expr ,expr))))
(defprod element (horz (&rest (elements (list element))))
  (to-list () `(horz (:elements ,(synth-all to-list elements)))))

(defprod element (vert (&rest (elements (list element))))
  (to-list () `(vert (:elements ,(synth-all to-list elements)))))

(defprod element (alt (&rest (elements (list (pair string element))))))