(defprod element (button ((id string) (expr expression)
			  &optional (transition transition)))
  (to-list () `(button (:id ,id :expr ,(synth to-list expr) :transition ,(synth to-list transition))))
  (to-req (path) (funcall #'hcat (text "Il bottone ~a è etichettato con la seguente espressione:" id) 
		      (synth to-req expr))))


(defprod element (input ((id string)
			 &optional (expr expression)))
  (to-list () `(input (:id ,id :expr ,(synth to-list expr))))
  (to-req (path) (funcall #'hcat (text "Il campo di input ~a è inizializzato con" id) 
		      (synth to-req expr))))

(defprod element (label ((expr expression)))
  (to-list () `(label :expr ,(synth to-list expr)))
  (to-req (path) (funcall #'hcat (text "L'etichetta viene inizializzata con la seguente espressione:") 
		      (synth to-req expr))))

(defprod element (horz (&rest (elements (list element))))
  (to-list () `(horz (:elements ,(synth-all to-list elements))))
  (to-req (path) (funcall #'vcat 
		    (text "Concatenazione orizzontale dei seguenti elementi:")
		    (nest 4 (apply #'vcat (synth-all to-req elements path))))))

(defprod element (vert (&rest (elements (list element))))
  (to-list () `(vert (:elements ,(synth-all to-list elements))))
  (to-req (path) (funcall #'vcat 
		    (text "Concatenazione verticale dei seguenti elementi:")
		    (nest 4 (apply #'vcat (synth-all to-req elements path))))))

(defmacro synth-alts (func plst path &rest args)
  `(apply #'append (mapcar #'(lambda (pair) 
			       (list (chain (static-chunk (car pair)) ,path)
				     (synth ,func (cadr pair) (chain (static-chunk (car pair)) ,path) ,@args)))
			   (group ,plst 2))))

(defprod element (alt (&rest (elements (plist element))))
  (to-list () `(alt (:elements ,(synth-plist to-list elements)))) 
  (to-req (path)
	  (let ((alts (synth-alts to-req elements path))) 
	    (funcall #'vcat 
		     (text "Scelta tra le seguenti viste:")
		     (nest 4 (apply #'vcat 
				    (mapcar #'(lambda (pair)
						(vcat (synth to-url (first pair)) (second pair)))
					    (group alts 2))))))))

(defprod element (abst ((parameters (list parameter))
		       (element element)))
  (to-list () `(abst (:parameters ,(synth-all to-list parameters) :element ,(synth to-list element))))
  (to-req (path) (vcat (text "Elemento parametrico con parametri:")
		   (nest 4 (apply #'vcat (synth-all to-req parameters)))
		   (synth to-req element (chain (synth to-url (car parameters)) path)))))

(defprod transition (transition ((target url) 
				 &optional (action process)))
  (to-list () `(transition (:target ,target :action ,(synth to-list action)))))


(defun *posts* (user)
  (let ((post (path-parameter 'post))) 
    (abst (list post) (vert (label user)
			    (label post)))))

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


(synth output (synth to-req *gui* (void)) 0)

