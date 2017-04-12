(defprod element (tabular% ((name symbol)
                            (source datasource)
                            &rest (bindings (list binding))))
  (to-list () `(tabular (:name ,name 
                               :source ,(synth to-list source) 
                               :bindings ,(synth-list-merge 2
                                                            (lambda (pair) 
                                                              (list (first pair) 
                                                                    (synth to-list (funcall (second pair) (synth schema source)))))
                                                            bindings))))
  (to-html (path)
	   (div nil 
                (text "Tabella denominata ")
                (span-color (lower-camel name))
                (text " associata a ")
                (span-color (lower-camel (synth name source)))
                (text "(istanza del formato dati ")
                (a (list :href (concatenate 'string "#" (synth to-string (synth to-brief (synth schema source)) 0)))
                   (code nil (synth to-brief (synth schema source ))))
                (text "con le seguenti colonne:" ;; (lower-camel (synth name (synth schema source)))
                      ) 
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
  (to-brief (path) (synth to-html (apply #'tabular name source bindings)))
  (toplevel () nil)
  (req (path) nil))


(defmacro tabular (name source (rowname &optional index) &body bindings)
  `(tabular% ,name
             ,source
             ,@(apply #'append (mapcar (lambda (binding)
                                         (list (first binding) `(lambda (,rowname ,@(csplice index index)) (declare (ignorable ,rowname ,@(csplice index index))) ,(second binding))))
                                       bindings))))

(defmacro tabular* (source (rowname &optional index) &body bindings)
  `(tabular% (gensym "TABULAR") 
          ,source
          ,@(apply #'append (mapcar (lambda (binding)
                                      (list (first binding) `(lambda (,rowname ,@(csplice index index)) (declare (ignorable ,rowname ,@(csplice index index))) ,(second binding))))
                                   bindings))))

