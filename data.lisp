(defmacro data (name d)
  `(defparameter ,name ,d))

(defprod datasource (remote ((name symbol)
                             (format format)
                             (url url)))
  (to-list () `(remote (:name ,name :format ,(synth to-list format) :url ,(synth to-list url))))
  (to-html ()  (div (list :class 'well) 
                    (div nil (text "Sorgente dati remota identificata come")
                         (span (list :class "label label-info") (text "~a" (lower name))) 
                         (text "istanza del formato dati ~a:" (lower (synth name format)))
                         (text "e popolata al caricamento dell'elemento tramite richiesta HTTP GET verso il seguente URL:")
                         (span nil (synth to-url url))))))

;; (defmacro remote* (format url)
;;   `(remote (gensym "REMOTE") format url))

(defprod element (with-data ((bindings (list binding))
                             (element element)))
  (to-list () `(with-data (:bindings (synth-all to-list bindings) :element (synth to-list element))))
  (to-html (path) (div nil (text "Tale elemento fa uso delle seguenti sorgenti dati:")
                       (apply #'multitags (synth-all to-html bindings)) 
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

