(defprod transition (transition (url url))
  (to-list () `(transition )))
(defprod element (button ((id string) (expr expression)
			  &optional (transition transition)))
  (to-list () `(button (:id ,id :expr ,(synth to-list expr) :transition ,(synth to-list transition)))))

(defprod element (input ((id string)
			 &optional (expr expression)))
  (to-list () `(input (:id ,id :expr ,(synth to-list expr)))))

(defprod element (label ((expr expression)))
  (to-list () `(label :expr ,(synth to-list expr))))

(defprod element (horz (&rest (elements (list element))))
  (to-list () `(horz (:elements ,(synth-all to-list elements)))))

(defprod element (vert (&rest (elements (list element))))
  (to-list () `(vert (:elements ,(synth-all to-list elements)))))

(defprod element (alt (&rest (elements (plist element))))
  (to-list () `(alt (:elements ,(synth-plist to-list elements)))))

(alt :home (button 'ok (const "ok"))
     :login (input 'userid))

(synth to-list (vert (button 'ok (const "ok")) (input 'userid)))


(defprod transition (transition ((target url)
				 &optional (action process)))
  (to-list () `(transition (:target ,target :action ,(synth to-list action)))))
;; (alt :home home
;;      :login login)

(defprod element (abst ((parameters (list parameter))
		       (element element)))
  (to-list () `(abst (:parameters ,parameters :element ,(synth to-list element)))))

(defparameter *gui* (alt :login (vert (input 'userid)
				      (input 'passwd)
				      (horz (button 'ok (const "ok")) 
					    (button 'cancel (const "cancel")) ()))
			 :home (label (const "welcome"))))

