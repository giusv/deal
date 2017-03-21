;; (defprod element (tabular ((name symbol)
;;                            (query query)
;;                            (render function)))
;;   (to-list () `(tabular (:name ,name :query ,(synth to-list query) :render ,render)))
;;   ;; (to-req (path)
;;   ;;         (let* ((sch (synth schema query)) 
;;   ;;       	(fields (pairlis sch (synth-all to-req (apply render sch) path))))
;;   ;;           (apply #'vcat 
;;   ;;       	   (text "Tabella con i seguenti campi:") 
;;   ;;       	   (mapcar #'(lambda (pair)
;;   ;;       		       (nest 4 (hcat (text "~a: " (car pair)) (cdr pair))))
;;   ;;       		   fields))))
;;   )

(defprod element (tabular ((name symbol)
                         (schema jsschema)
                         &rest (bindings (list binding))))
  (to-list () `(tabular (:name ,name 
                             :schema ,(synth to-list schema) 
                             :bindings ,(synth-list-merge 2
                                         (lambda (pair) 
                                           (list (first pair) 
                                                 (synth to-list (funcall (second pair) schema))))
                                         bindings))))
  (to-html (path)
	   (div nil 
                (text "Tabella con le seguenti colonne:") 
                (apply #'dl nil 
                       (synth-list-merge 2
                        (lambda (pair) 
                          (let ((header (textify (first pair))) 
                                (element (synth to-html 
                                                (funcall (second pair) schema)
                                                path))) 
                            (multitags (dt nil header) 
                                       (dl nil element))))
                        bindings))))
  (to-brief (path) (synth to-html (apply #'tabular name schema bindings)))
  (toplevel () nil)
  (req (path) nil))

(defmacro tabular* (schema &body bindings)
  `(tabular (gensym "TABULAR") 
          ,schema 
          ,@(apply #'append (mapcar (lambda (binding)
                                     (list (first binding) `(lambda (it) (declare (ignorable it)) ,(second binding))))
                                   bindings))))


;; (tabular* indicator-format
;;        ('codice code (label it))
;;        ('start-date data-inizio (button* it)))
