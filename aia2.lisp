(defprod element (obj ((name symbol)
                       (schema jsschema)
                       (bindings (list binding))
                       (element element)))
  (to-list () `(obj (:name ,name :schema ,(synth to-list schema) 
                           :bindings (synth-plist-both to-list to-list bindings) 
                           :element ,(synth to-list element))))
  (to-html (path) (div nil 
  		       (text "Form identificato con ~a collegato al seguente formato dati:" (lower name)) 
  		       (pre nil (synth to-req schema))
  		       (text "Produce")
  		       (pre nil (synth to-string (synth to-model (obj name schema bindings element))))
  		       (text "Costituito da:") 
  		       (synth to-html element path)))
  (to-model () (apply #'jobject (apply #'append 
                                       (synth-plist-merge 
                                        #'(lambda (binding)
                                            (list (keyw (car binding))
                                                  (synth to-model (cadr binding)))) 
                                        bindings)))))
(defmacro obj* (name schema binds elem)
  `(let* ,(mapcar #'(lambda (bind)
		      (destructuring-bind (name key elem) bind
			`(,name (property-form ',name (prop ',key) ,elem))))
		  binds)
     (obj ,name ,schema (list ,@(mapcar #'car binds)) ,elem)))

(defprod element (arr ((name symbol)
                       (schema jsschema)
                       (min expression)
                       (max expression) 
                       (element element)))
  (to-list () `(arr (:name ,name 
                           :schema ,(synth to-list schema) 
                           :min (synth to-list min) 
                           :max (synth to-list max) 
                           :element ,(synth to-list element))))
  (to-html (path) (div nil 
  		       (text "Form identificato con ~a collegato al seguente formato dati:" (lower name)) 
  		       (pre nil (synth to-req schema))
  		       (text "Produce")
  		       (pre nil (synth to-string (synth to-model (arr name schema min max element))))
  		       (text "Costituito da:") 
  		       (synth to-html element path)))
  (to-model () (jarray (synth to-model element))))

(defmacro arr* (name schema elem)
  `(arr ,name ,schema ,elem))

(data number-format
      (jsarray 'numbers (jsnumber 'number)))
(data test-format 
    (jsobject 'test-format
              (jsprop 'name t (jsstring 'string))
              (jsprop 'numbers t number-format)))
(element number-form 
         (arr* 'numbers-form number-format
               (input 'number (const "number"))))
(element test-form 
         (obj* 'test-form test-format
               ((name name (input 'name (const "name")) )
                (numbers numbers (arr 'numbers-form number-form)))
               (vert name numbers)))

