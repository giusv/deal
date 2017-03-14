;; (defprod element (table ((name symbol)
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

(defprod element (table ((name symbol)
                         (schema jsschema)
                         &rest (bindings (list binding))))
  (to-list () `(table (:name ,name 
                             :schema ,(synth to-list schema) 
                             :bindings ,(synth-list-merge 3
                                         (lambda (triple) 
                                           ;; (pprint triple)
                                           (list (first triple) 
                                                 (synth to-list (second triple)) 
                                                 (synth to-list (funcall (third triple) 
                                                                         (car (funcall (synth to-func (second triple))
                                                                                       schema))))))
                                         bindings))))
  (to-html (path)
	   (div nil 
                (text "Tabella con le seguenti colonne:") 
                (apply #'dl nil 
                       (synth-list-merge 3
                        (lambda (triple) 
                          (let ((header (textify (first triple)))
                                ;; (property (synth to-req (second triple)))
                                (element (synth to-html 
                                                (funcall (third triple) 
                                                         (second triple)
                                                         ;; (car (funcall (synth to-func (second triple))
                                                         ;;           schema))
                                                         ) path))) 
                            (multitags (dt nil header) 
                                       (dl nil element))))
                        bindings))))
  (to-brief (path) (synth to-html (apply #'table name schema bindings)))
  (toplevel () nil)
  (req (path) nil))

(defmacro table* (schema &body bindings)
  `(table (gensym "TABLE") 
          ,schema 
          ,@(apply #'append (mapcar (lambda (binding)
                                     (list (first binding) `(prop ',(second binding)) `(lambda (it) (declare (ignorable it)) ,(third binding))))
                                   bindings))))


;; (table* indicator-format
;;        ('codice code (label it))
;;        ('start-date data-inizio (button* it)))
