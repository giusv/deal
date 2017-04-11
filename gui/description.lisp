(defprod element (description% ((name symbol)
                               (source datasource)
                               &rest (bindings (list binding))))
  (to-list () `(description (:name ,name 
                                   :source ,(synth to-list source) 
                                   :bindings ,(synth-list-merge 2
                                                                (lambda (pair) 
                                                                  (list (first pair) 
                                                                        (synth to-list (funcall (second pair) (synth schema source)))))
                                                                bindings))))
  (to-html (path)
	   (multitags 
            (text "Lista descrittiva collegata al formato dati ~a contenente le seguenti righe:" (lower-camel (synth name (synth schema source)))) 
            (apply #'dl (list :class "row")
                   (synth-list-merge 2
                                     (lambda (pair) 
                                       (let ((header (textify (first pair))) 
                                             (element (synth to-html 
                                                             (funcall (second pair) (synth schema source))
                                                             path))) 
                                         (multitags (dt (list :class "col-sm-2") header) 
                                                    (dl (list :class "col-sm-10") element))))
                                     bindings))))
  (to-brief (path) (synth to-html (apply #'description name source bindings)))
  (toplevel () nil)
  (req (path) nil))


(defmacro description (name source (rowname &optional index) &body bindings)
  `(description% ,name 
          ,source
          ,@(apply #'append (mapcar (lambda (binding)
                                      (list (first binding) `(lambda (,rowname ,@(csplice index index)) (declare (ignorable ,rowname ,@(csplice index index))) ,(second binding))))
                                   bindings))))

(defmacro description* (source (rowname &optional index) &body bindings)
  `(description% (gensym "DESCRIPTION") 
          ,source
          ,@(apply #'append (mapcar (lambda (binding)
                                      (list (first binding) `(lambda (,rowname ,@(csplice index index)) (declare (ignorable ,rowname ,@(csplice index index))) ,(second binding))))
                                   bindings))))

