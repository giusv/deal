(defprod element (indexed ()))
(defprod element (tabular2 ((name symbol)
                            (source datasource)
                            &rest (bindings (list binding))))
  (to-list () `(tabular2 (:name ,name 
                                :source ,(synth to-list source) 
                                :bindings ,(synth-list-merge 2
                                                             (lambda (pair) 
                                                               (list (first pair) 
                                                                     (synth to-list (funcall (second pair) (synth schema source)))))
                                                             bindings))))
  (to-html (path)
	   (div nil 
            (text "Tabella associata al formato dati ~a con le seguenti colonne:" (lower (synth name (synth schema source)))) 
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
  (to-brief (path) (synth to-html (apply #'tabular2 name source bindings)))
  (toplevel () nil)
  (req (path) nil))

(defmacro tabular2* (source rowname &body bindings)
  `(tabular2 (gensym "TABULAR2") 
          ,source 
          ,@(apply #'append (mapcar (lambda (binding)
                                     (list (first binding) `(lambda (,rowname) (declare (ignorable ,rowname)) ,(second binding))))
                                   bindings))))

