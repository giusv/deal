(defmacro process (name proc)
  `(defparameter ,name ,proc))


(defmacro defprocess ((name lambda-list) &rest attrs)
  (let* ((new-lambda-list (add-parameters lambda-list 'key '(name (name symbol))))) 
    `(defprod process (,name ,new-lambda-list) ,@attrs)))

;; (defmacro process (name proc) 
;;   `(defparameter ,name ,(append proc `(:name ',name))))

(defprod command (skip ())
  (to-list () `(skip))
  (to-html () (div nil)))

(defprod command (concat (&rest (actions (list action))))
  (to-list () `(concat (:actions ,(synth-all to-list actions))))
  (to-html () (apply #'ol nil
                     (mapcar #'listify (synth-all to-html actions)))))

(defmacro concat* (&rest bindings)
  (let ((new-bindings (mapcar #'(lambda (binding)
			  (cons (gensym) binding)) 
			      bindings)))
    `(bindall ,new-bindings
      (concat ,@(mapcar #'car new-bindings)))))

(defprod command (fork ((expr expression) 
                        (true command)
                        (false command)))
  (to-list () `(fork (:expr  ,(synth to-list expr) :true ,(synth to-list true) :false ,(synth to-list false))))
  (to-html () (multitags
               (text "Check della condizione ")
               (synth to-html expr)
               (ul nil
                   (li nil (multitags (text "In caso di successo, ") (synth to-html true)))
                   (li nil (multitags (text "In caso di fallimento, ") (synth to-html false)))))))
(defprocess (client (&key (command (command command))))
    (to-list () `(client :command ,(synth to-list command)))
  (to-html () (multitags
               (text "Processo client denominato ~a" (lower name)) 
               (text " che esegue i seguenti passi:")
               (p nil (synth to-html command)))))

(defprocess (sync-server (&key (command (command command))
                               (input (input format))
                               (parameters (parameters (list expression))) 
                               (output (output (output format)))))
    (to-list () `(sync-server :parameters ,(synth-all to-list parameters) :input ,(synth to-list input)
                              :command ,(synth to-list command) :output ,(synth to-list output)))
  (to-html () (multitags
               (text "Processo server sincrono denominato ~a" (lower name))
               (if input 
                   (multitags
                    (text " con ingresso una istanza del seguente formato dati:")
                    (p nil (synth to-html input))))
               (if parameters 
                   (p nil (apply #'multitags 
                                 (text " con parametri:")
                                 (synth-all to-html parameters))))
               
               (text "che esegue i seguenti passi:")
               (p nil (synth to-html command)))))

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
