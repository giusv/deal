(defmacro process (name proc)
  `(defparameter ,name ,proc))


(defmacro defprocess ((name lambda-list) &rest attrs)
  (let* ((new-lambda-list (add-parameters lambda-list 'key '(name (name symbol))))) 
    `(defprod process (,name ,new-lambda-list) ,@attrs)))

;; (defmacro process (name proc) 
;;   `(defparameter ,name ,(append proc `(:name ',name))))






;; (defprod command (contractful ((precond bexp)
;;                                (command command)
;;                                (postcond bexp)))
;;   (to-list () `(contractful :precond ,precond :command ,command :postcond ,postcond))
;;   (to-html () (div nil (text "Comando con seguente contratto:")
;;                    (maybes (list precond (span nil (text "Precondizione:")))
;;                            (list postcond (span nil (text "Postcondizione:")))
;;                            (list command (span nil (text "Comando:")))))))



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

(defprod command (fork ((expr expression) 
                        (true command)
                        (false command)))
  (to-list () `(fork (:expr  ,(synth to-list expr) :true ,(synth to-list true) :false ,(synth to-list false))))
  (to-html () (div nil 
		   (text "Check condizione ")
		   (div (list :class 'well) (synth to-html expr))
		   (apply #'ul 
			  (list :class 'list-group)
			  (mapcar #'listify (list (span nil (i (list :class "fa fa-thumbs-up") nil) (synth to-html true)) 
						  (span nil (i (list :class "fa fa-thumbs-down") nil) (synth to-html false))))))))

(defprocess (sync-server (&key (command (command command))
                               (input (input format))
                               (parameters (parameters (list expression))) 
                               (output (output (output format)))))
    (to-list () `(sync-server :parameters ,(synth-all to-list parameters) :input ,(synth to-list input)
                              :command ,(synth to-list command) :output ,(synth to-list output)))
  (to-html () (div nil 
                   (text "Processo server sincrono denominato ~a" (lower name))
                   (if input 
                       (div nil 
                            (text " con ingresso una istanza del seguente formato dati:")
                            (pre nil (synth to-req input))))
                   (if parameters 
                       (apply #'div nil (text " con parametri:")
                              (synth-all to-html parameters))) 
                   (text "che esegue i seguenti passi:")
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
