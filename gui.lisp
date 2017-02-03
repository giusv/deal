(defprod element (button ((id string) (expr expression)
			  &optional (transition transition)))
  (to-list () `(button (:id ,id :expr ,(synth to-list expr) :transition ,(synth to-list transition))))
  (to-req () (funcall #'hcat (text "Il bottone ~a è etichettato con la seguente espressione:" id) 
		      (synth to-req expr))))


(defprod element (input ((id string)
			 &optional (expr expression)))
  (to-list () `(input (:id ,id :expr ,(synth to-list expr))))
  (to-req () (funcall #'hcat (text "Il campo di input ~a è inizializzato con" id) 
		      (synth to-req expr))))

(defprod element (label ((expr expression)))
  (to-list () `(label :expr ,(synth to-list expr)))
  (to-req () (funcall #'hcat (text "L'etichetta viene inizializzata con la seguente espressione:") 
		      (synth to-req expr))))

(defprod element (horz (&rest (elements (list element))))
  (to-list () `(horz (:elements ,(synth-all to-list elements))))
  (to-req () (funcall #'vcat 
		    (text "Concatenazione orizzontale dei seguenti elementi:")
		    (nest 4 (apply #'vcat (synth-all to-req elements))))))

(defprod element (vert (&rest (elements (list element))))
  (to-list () `(vert (:elements ,(synth-all to-list elements))))
  (to-req () (funcall #'vcat 
		    (text "Concatenazione verticale dei seguenti elementi:")
		    (nest 4 (apply #'vcat (synth-all to-req elements))))))

(defprod element (alt (&rest (elements (plist element))))
  (to-list () `(alt (:elements ,(synth-plist to-list elements)))) 
  (to-req () (let ((alts (synth-plist to-req elements)))
	       (funcall #'vcat 
			(text "Scelta tra le seguenti viste:")
			(nest 4 (apply #'vcat (mapcar #'(lambda (pair)
							  (hcat (text "~a" (first pair)) (text ":") (second pair)))
						      (group alts 2))))))))


(synth to-list (vert (button 'ok (const "ok")) (input 'userid)))

(defprod transition (transition ((target url) 
				 &optional (action process)))
  (to-list () `(transition (:target ,target :action ,(synth to-list action)))))
;; (alt :home home
;;      :login login)

(defprod element (abst ((parameters (list parameter))
		       (element element)))
  (to-list () `(abst (:parameters ,(synth-all to-list parameters) :element ,(synth to-list element))))
  (to-req () (vcat (text "Elemento parametrico con parametri:")
		   (nest 4 (apply #'vcat (synth-all to-req parameters)))
		   (synth to-req element))))

;; (defparameter *gui* (alt :login (vert (input 'userid)
;; 				      (input 'passwd)
;; 				      (horz (button 'ok (const "ok")) 
;; 					    (button 'cancel (const "cancel")) ()))
;; 			 :home (label (const "welcome"))
;; 			 :users #'(lambda (user) 
;; 				    (vert (label (const user))
;; 					  (alt :default (label (const "default"))
;; 					       :posts #'(lambda (post)
;; 							  (vert (label (const user))
;; 								(label (const post)))))))))

(defparameter *gui* (alt :login (vert (input 'userid)
				      (input 'passwd)
				      (horz (button 'ok (const "ok")) 
					    (button 'cancel (const "cancel"))))
			 :home (label (const "welcome"))
			 :users (let ((user (path-parameter 'user))) 
				  (abst (list user) (vert (label user)
						      (alt :default (label (const "default"))
							   :posts (*posts* user)))))))

(defparameter *users* #'(lambda (user post) 
			  (vert (label (const user))
				(label (const post)))))

(defun *posts* (user)
  (let ((post (path-parameter 'post))) 
    (abst (list post) (vert (label user)
			    (label post)))))

