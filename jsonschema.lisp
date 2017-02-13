;;https://hackage.haskell.org/package/json-schema-0.7.4.1/docs/Data-JSON-Schema-Types.html
;;http://cswr.github.io/JsonSchema/spec/grammar/
;; (defprod jsdoc (jsdoc ((id jid) (defs jdefs) (sch jsch)))
;;   (to-json () (apply #'jobject 
;; 		     :id id
;; 		     :definitions (apply #'jobject defs)
;; 		     (synth-plist to-json defs))))

(defprod jsschema (jsstring ())
  (to-list () `(jsstring))
  (to-req () (text "stringa")))

(defprod jsschema (jsnumber ())
  (to-list () `(jsnumber))
  (to-req () (text "numero")))

(defprod jsschema (jschoice (&rest (schemas (list jsschema))))
  (to-list () `(jschoice :schemas ,(synth-all to-list schemas)))
  (to-req () (vcat (text "scelta tra i seguenti schemi:")
		   (nest 4 (apply #'vcat (synth-all to-req schemas))))))

(defprod jsschema (jsobject (&rest (props (list jsprop))))
  (to-list () `(jsobject :props ,(synth-all to-list props)))
  (to-req () (vcat (text "oggetto dalle seguenti proprietà:")
		   (nest 4 (apply #'vcat (synth-all to-req props))))))

(defprod jsprop (jsprop ((name string) (required bool) (content jsschema)))
  (to-list () `(jsprop :name ,name :required ,required :content ,(synth to-list content)))
  (to-req () (hcat (text "~a" name) (if required (text " (obbligatoria)") (text " (facoltativa)")) 
		   (text ": ") (synth to-req content))))

(defprod (jsschema) (jsarray ((elem jsschema)))
  (to-list () `(jsarray :elem ,(synth to-list elem)))
  (to-req () (vcat (text "array costituito dal seguente elemento:")
		   (nest 4 (synth to-req elem)))))

(defun get-elem ()
  #'(lambda (jsschema)
      (list (synth elem jsschema))))

(defun get-prop (name)
  #'(lambda (jsschema)
      (synth-all content 
		 (remove-if-not #'(lambda (prop) 
				    (eql name (synth name prop)))
				(synth props jsschema)))))

(defun compose-filter (f g)
  #'(lambda (jsschema)
      (let ((temps (funcall f jsschema))) ;;temps is a list of jsschema
	(apply #'append (mapcar #'(lambda (temp) 
				    (funcall g temp))
				temps)))))
(defun compose-filters (&rest filters)
  #'(lambda (jsschema)
      (funcall (reduce #'compose-filter filters) jsschema)))

(defun parse-filter ()
  (do-with ((filters (sepby (item) (sym '>>>))))
    (result (apply #'comp (mapcar #'eval filters)))))

(defprod filter (prop ((name string)))
  (to-list () `(prop (:name ,name)))
  (to-func () (get-prop name))
  (to-req () (text "~a" (lower name))))

(defprod filter (elem ())
  (to-list () `(elem))
  (to-func () (get-elem))
  (to-req () (text "#")))

(defprod filter (comp (&rest (filters (list filter))))
  (to-list () `(comp (:filters ,(synth-all to-list filters))))
  (to-func () (apply #'compose-filters (synth-all to-func filters)))
  (to-req () (apply #'punctuate (forward-slash) nil (synth-all to-req filters))))




;; (pprint (synth to-list (car (funcall (get-prop 'addresses) *user*))))
;; (pprint (synth to-list (car (funcall (get-elem) *addresses*))))

;; (pprint (synth to-list (car (funcall (comp (comp (get-prop 'addresses) (get-elem)) (get-prop 'city)) *user*))))
(defparameter *address*
  (jsobject (jsprop 'city t (jsstring))
	   (jsprop 'state t (jsstring))))
(defparameter *addresses* (jsarray *address*))
(defparameter *user* 
  (jsobject (jsprop 'name t (jsstring))
	   (jsprop 'addresses t *addresses*)
	   (jsprop 'numbers t (jsarray (jsnumber)))))



(pprint (synth to-list (car (funcall (compose-filters (get-prop 'addresses) (get-elem) (get-prop 'city)) *user*))))
(pprint (synth to-list (car (funcall (synth to-func (comp (prop 'addresses) (elem) (prop 'city))) *user*))))
(pprint (synth to-list (car (funcall 
			     (synth to-func (parse (parse-filter) 
						   '((prop 'addresses) >>> (elem) >>> (prop 'city)))) *user*))))
