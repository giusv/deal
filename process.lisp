(defprod action (target ((pose pose)))
  (to-list () `(target :pose ,pose))
  (to-req () (hcat (text "effettua una transizione verso ") (synth to-url pose)))
  (to-html () (span nil (text "effettua una transizione verso ") (synth to-url pose))))

(defmacro def-http-action (name &optional (payload t))
  (let ((full-name (symb "HTTP-" name)))
    `(defprod action (,full-name ((url expression)
				 ,@(if payload `((payload payload)))
				 (response variable)))
       (to-list () (list ',full-name (list :url (synth to-list url) 
					   ,@(if payload (list ':payload '(synth to-list payload))) 
					   :response response)))
       (to-html () (div nil 
			(text "Azione ~a verso l'URL " ',name)
			(synth to-html url)
			,@(if payload (list '(text "con il payload seguente:")
					    '(synth to-html payload))))))))

(def-http-action get nil)
(def-http-action post)
(def-http-action put)
(def-http-action delete nil)

(pprint (synth to-list (http-get (void) (gensym "GET"))))

(defprod exp (status ((action action)))
  (to-list () `(status (:action ,action)))
  (to-html () (span nil (text "Codice HTTP di risposta"))))

(defprod command (skip ())
  (to-list () `(skip))
  (to-html () (div nil)))

(defprod command (concat (&rest (actions (list action))))
  (to-list () `(concat (:actions ,(synth-all to-list actions))))
  (to-html () (div nil 
		   (apply #'ol 
			  (list :class 'list-group)
			  (mapcar #'listify (synth-all to-html actions))))))

(defprod command (condition ((expr expression) 
			     (true command)
			     (false command)))
  (to-list () `(condition (:expr  ,(synth to-list expr) :true ,(synth to-list true) :false ,(synth to-list false))))
  (to-html () (div nil 
		   (text "Check condizione ")
		   (div (list :class 'well) (synth to-html expr))
		   (apply #'ul 
			  (list :class 'list-group)
			  (mapcar #'listify (list (span nil (i (list :class "fa fa-thumbs-up") nil) (synth to-html true)) 
						  (span nil (i (list :class "fa fa-thumbs-down") nil) (synth to-html false))))))))

(defprod action (compile ((source expression)
                          (target variable)))
  (to-list () `(compile (:source  ,(synth to-list source) :target ,(synth to-list target))))
  (to-html () (div nil 
		   (text "Compilazione del seguente sorgente:")
		   (div (list :class 'well) (synth to-html source)))))

;; (defprod process (sync-server ((parameters (list expression))
;; 			       (input format)
;; 			       (command command)
;; 			       (output format)))
;;   (to-list () `(sync-server :parameters ,(synth-all to-list parameters) :input ,(synth to-list input)
;; 			    :command ,(synth to-list command) :output ,(synth to-list output)))
;;   ())

;; (defprod process (async-server ((parameters (list expression))
;; 				(input format)
;; 				(command command)
;; 				(output format)))
;;   (to-list () `(async-server :parameters ,(synth-all to-list parameters) :input ,(synth to-list input)
;; 			     :command ,(synth to-list command) :output ,(synth to-list output)))
;;   ())

;; (defparameter *validation* ())
;; (defun *submit-user* (data) (let* ((post (http-post data))
;; 				   (choice (<equal> (synth response))))))
