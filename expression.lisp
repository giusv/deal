(defprod exp (const ((exp (or string number))))
  (to-list () `(const (:exp ,exp)))
  (to-req () (text "stringa costante: ~a" exp))
  (to-html () (double-quotes (text "~a" exp)))
  (to-url () (text "~a" exp))
  (to-chunk () exp)
  (to-string () (double-quotes (text "~a" exp)))
  (to-ts () (single-quotes (text "~a" exp)))
  (template () (text "~a" exp)))


(defprod exp (argument ((name symbol)))
  (to-list () `(argument (:name ,name)))
  (to-req () (text "~a" name))
  (to-html () (span-color (lower-camel name))))

(defprod exp (attr ((name datasource)
                    (exp symbol)))
  (to-list () `(attr (:name ,name :exp ,exp)))
  (to-req () (text "~a!~a" (lower-camel (synth name name)) (lower-camel exp)))
  (to-html () (multitags (span-color (lower-camel (synth name name))) 
                         (text "!~a"  (lower-camel exp))))
  ;; (to-html () (span (list :class "label label-danger") (text "~a!~a" (lower-camel (synth name name)) (lower-camel exp))))
  (to-string () (text "~a!~a" (lower-camel (synth name name)) (lower-camel exp))))

(defprod exp (variab ((name string)))
  (to-list () `(attr (:name ,name)))
  (to-string () (textify name))
  (to-req () (text "~a" name))
  (to-html () (span-color (lower-camel name))))
  ;; (to-html () (span (list :class "label label-danger") (text "~a" name))))

(defprod exp (value ((elem element)))
  (to-list () `(value (:elem ,elem)))
  ;; (to-req () (text "valore dell'elemento:" (lower-camel (synth name elem))))
  (to-html () (span-color (lower-camel (synth name elem))))
  ;; (to-html () (span (list :class "label label-default") (text "valore dell'elemento: ~a" (synth name elem))))1
  (to-url () (brackets (text "val(~a)" (lower-camel (synth name elem)))))
  (to-chunk () (text "val(~a)" (lower-camel (synth name elem))))
  (to-string () (text "val(~a)" (lower-camel (synth name elem)))))

(defprod exp (payload ((elem element)))
  (to-list () `(payload (:elem ,elem)))
  ;; (to-html () (pre nil (synth to-string (synth to-model elem))))
  (to-html () (synth to-string (synth to-model elem))))

(defprod exp (status ((action action)))
  (to-list () `(status (:action ,action)))
  (to-html () (text "Codice HTTP di risposta")))

(defprod exp (autokey ())
  (to-list () `(autokey))
  (to-html () (text "Chiave generata automaticamente")))

(defprod exp (current-date ())
  (to-list () `(current-date))
  (to-html () (text "Data odierna")))


(defprod exp (cat (&rest (exps exp)))
  (to-list () `(cat (:exps ,(synth-all to-list exps))))
  (to-html () (brackets (hcat 
                         (text "concatenazione delle espressioni:")
                         (apply #'punctuate (comma) t (synth-all to-req exps)))))
  ;; (to-html () (apply #'span (list :class "label label-default") (synth-all to-html exps)))
  (to-string () (text "~{~a~^ ++ ~}" (synth-all to-string exps))))

(defmacro def-bexp (operator &optional (arity 0))
  (let ((name (symb "+" operator "+")))
    `(defprod bexp (,name 
		    ,(if (eq arity 'unbounded)
			 `(&rest (exps bexp))
			 (loop for i from 1 to arity collect `(,(symb "EXP" i) exp))))
       (to-html () (brackets (hcat (text "~a " (lower-camel ',name))
                                   ,@(if (eq arity 'unbounded)
                                         `((parens (apply #'punctuate (comma) nil 
                                                          (synth-all to-doc 
                                                                     (synth-all to-html exps)))))
                                         `((punctuate (comma) nil ,@(loop for i from 1 to arity collect 
                                                                         `(synth to-doc (synth to-html ,(symb "EXP" i))))))))))

       (to-list () (list ',name 
			 ,(if (eq arity 'unbounded)
			      `(list :exps (synth-all to-list exps))
			      `(list ,@(apply #'append (loop for i from 1 to arity collect (list (keyw "EXP" i) `(synth to-list ,(symb "EXP" i)))))))))
       ;; (to-html () (span nil (synth to-req 
       ;; 				    ,(if (eq arity 'unbounded)
       ;; 					 `(apply #',name exps)
       ;; 					 `(,name ,@(loop for i from 1 to arity collect (symb "EXP" i)))))))
       )))
;; (def-bexp and 2)
(defmacro def-bexps (&rest bexps)
  `(progn
     ,@(mapcar #'(lambda (bexp)
		   `(def-bexp ,(car bexp) ,@(cdr bexp)))
	       bexps)))

;;(def-bexp true)
;; (def-bexp equal 2)

(def-bexps (true) (false) (and unbounded) (or unbounded) (not 1) (equal 2) (less-than 2) (greater-than 2) (null 1))

