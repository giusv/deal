(defmacro process (name &body proc)
  `(defparameter ,name ,@proc))

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

(defprocess (map-command ((command command)
                          (array format)))
    (to-list () `(map-command (:command ,(synth to-list command) :array ,(synth to-list array))))
  (to-html () (multitags
               (text "Processo che mappa sull'array ") 
               (synth to-html array) 
               (text " il seguente comando:")
               (p nil (synth to-html command)))))

;; (defprocess (client (&key (command (command command))))
;;     (to-list () `(client :command ,(synth to-list command)))
;;   (to-html () (multitags
;;                (text "Processo client denominato ~a" (lower-camel name)) 
;;                (text " che esegue i seguenti passi:")
;;                (p nil (synth to-html command)))))

(defprocess (mu ((input symbol)
                 (command command)))
    (to-list () `(mu (:input ,input :command ,(synth to-list command))))
  (to-html () (multitags
               (text "Comando parametrico di parametro ")
               (span-color (lower-camel input)) 
               (text " che esegue:" )
               (p nil (synth to-html command)))))

(defmacro mu* (input command)
  `(let* ((,input ',input)) 
     (mu ,input ,command)))

(defprocess (sync-server (&key (command (command command))
                               (input (input format))
                               (parameters (parameters (list expression))) 
                               (output (output (output format)))))
    (to-list () `(sync-server :parameters ,(synth-all to-list parameters) :input ,(synth to-list input)
                              :command ,(synth to-list command) :output ,(synth to-list output)))
  (to-html () (multitags
               (text "Processo server sincrono denominato ~a" (lower-camel name))
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

;; (defprocess (auxiliary (&key (command (command command))
;;                                (input (input format))
;;                                (parameters (parameters (list expression))) 
;;                                (output (output (output format)))))
;;     (to-list () `(auxiliary :parameters ,(synth-all to-list parameters) :input ,(synth to-list input)
;;                               :command ,(synth to-list command) :output ,(synth to-list output)))
;;   (to-html () (multitags
;;                (text "Processo ausiliario denominato ~a" (lower-camel name))
;;                (if input 
;;                    (multitags
;;                     (text " con ingresso una istanza del seguente formato dati:")
;;                     (p nil (synth to-html input))))
;;                (if parameters 
;;                    (p nil (apply #'multitags 
;;                                  (text " con parametri:")
;;                                  (synth-all to-html parameters))))
               
;;                (text "che esegue i seguenti passi:")
;;                (p nil (synth to-html command)))))



(defmacro create* (name format autogen fields additions &optional finally)
  (labels ((generate-extractor (field)
             (destructuring-bind (fname getter setter validators) field
               (declare (ignorable validators setter))
               (let* ((extracted (symb name "-" fname))
                      (valid (symb extracted "-VALID")))
                 `((,extracted (extract2 ,getter ,format))
                   (,valid (validate2 ,extracted (list ,@validators)))))))
           (generate-persistor (field)
             (destructuring-bind (fname getter setter validators) field
               (declare (ignorable getter validators))
               `(,setter ,(symb name "-" fname)))))
    `(sync-server 
      :name ',(symb "CREATE-" name)
      ,@(if format `(:input ,(symb name "-FORMAT")))
      :command (concat* ,@(apply #'append (mapcar #'generate-extractor fields)) 
                        ((fork (+and+ ,@(append (mapcar #'(lambda (arg) (symb name "-" arg "-VALID"))
                                                        (mapcar #'car fields)))) 
                               (concat* 
                                (,name (create-instance2 ,(symb name "-ENTITY") 
                                                         (list 
                                                          ,@(if autogen `(,autogen (autokey)))
                                                          ,@additions
                                                          ,@(apply #'append (mapcar #'generate-persistor fields))))) 
                                ((persist ,name))
                                ,@(if finally (list `(,finally)) nil)
                                ((http-response 201 :payload (value ,name))))
                               (http-response 403)))))))

(defmacro remove* (name format validators &optional finally)
  (let* ((valid (symb name "-VALID")))
    `(let ((,name (path-parameter ',name)))
       (sync-server 
        :name ',(symb "REMOVE-" name)
        :parameters (list ,name) 
        :command (concat* (,valid (validate2 ,name (list ,@validators)))
                          ((fork ,valid
                                 (concat* 
                                  ((erase2 ,format ,name)) 
                                  ,@(if finally (list `(,finally)) nil)
                                  ((http-response 204)))
                                 (http-response 400))))))))






