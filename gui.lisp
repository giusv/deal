(def-typeclass gui
  to-list)

(def-instance gui 
    (button (id string required)
	    (expr expression required)
	    (transition transition required))
  (to-list `(button (:id ,id :expr ,expr :transition ,(to-list transition)))))

(def-instance gui 
    (input (id string required)
	   (expr expression required))
  (to-list `(button (:id ,id :expr ,expr :transition ,(to-list transition)))))

