(defmacro data (name &body d)
  `(defparameter ,name ,@d))

(defprod datasource (remote ((name symbol)
                             (schema jsschema)
                             (url url)))
  (to-list () `(remote (:name ,name :schema ,(synth to-list schema) :url ,(synth to-list url))))
  (to-html ()  (multitags
                (text "Sorgente dati remota identificata come ")
                (span-color (lower-camel name))
                (text ", istanza dello schema dati ~a " (lower-camel (synth name schema)))
                (text "e popolata al caricamento dell'elemento tramite richiesta HTTP GET verso l'URL ")
                (synth to-url url))))

;; (defmacro remote* (schema url)
;;   `(remote (gensym "REMOTE") schema url))

(defprod element (with-data ((bindings (list binding))
                             (element element)))
  (to-list () `(with-data (:bindings (synth-all to-list bindings) :element (synth to-list element))))
  (to-html (path) (multitags (text "Tale elemento fa uso delle seguenti sorgenti dati:")
                             (apply #'ul nil (mapcar #'listify (synth-all to-html bindings))) 
                             (synth to-html element path)))
  (to-brief (path) (synth to-brief element path))
  (toplevel () (list (synth toplevel element)))
  (req (path) (synth req element path)))


(defmacro with-data* (binds &body element)
  `(let* ,(mapcar #'(lambda (bind)
		      (destructuring-bind (name source) bind
			`(,name ,source)))
		  binds)
     (with-data (list ,@(mapcar #'car binds)) ,@element)))

