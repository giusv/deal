(defmacro defprocess (name proc)
  `(defparameter ,name ,proc))

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

;; (pprint (synth to-list (http-get (void) (gensym "GET"))))

(defprod exp (status ((action action)))
  (to-list () `(status (:action ,action)))
  (to-html () (span nil (text "Codice HTTP di risposta"))))

;; (defprod exp (result ((action action)))
;;   (to-list () `(result (:action ,action)))
;;   (to-html () (span nil (text "Risultato dell'azione"))))

(defprod command (skip ())
  (to-list () `(skip))
  (to-html () (div nil)))

(defprod command (concat (&rest (actions (list action))))
  (to-list () `(concat (:actions ,(synth-all to-list actions))))
  (to-html () (div nil 
		   (apply #'ol 
			  (list :class 'list-group)
			  (mapcar #'listify (synth-all to-html actions))))))

(defmacro concat2 (&rest bindings)
  (let ((new-bindings (mapcar #'(lambda (binding)
			  (cons (gensym) binding)) 
			      bindings)))
    `(bindall ,new-bindings
      (concat ,@(mapcar #'car new-bindings)))))

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

(defprod action (translate ((source filter)
                            (target variable)
                            (result variable)))
  (to-list () `(translate (:source  ,(synth to-list source) :target ,(synth to-list target) :result ,(synth to-list result))))
  (to-html () (div nil 
		   (text "Sia ") 
		   (synth to-html result) 
		   (text " il risultato della compilazione del seguente sorgente:")
		   (div (list :class 'well) (synth to-req source)))))
(defun translate2 (source)
  (let ((result (variable (gensym))))
    (values (translate source nil result) result)))


(defprod process (sync-server ((parameters (list expression))
			       (input format)
			       (command command)
			       &optional (output format)))
  (to-list () `(sync-server :parameters ,(synth-all to-list parameters) :input ,(synth to-list input)
			    :command ,(synth to-list command) :output ,(synth to-list output)))
  (to-html () (div nil 
                   (text "Processo server sincrono che prende in ingresso una istanza del seguente formato dati:")
                   (pre nil (synth to-req input))
                   (text "e esegue i seguenti passi:")
                   (synth to-html command))))

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
