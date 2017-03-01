(defprod exp (const ((exp (or string number))))
  (to-list () `(const (:exp ,exp)))
  (to-req () (text "stringa costante: ~a" exp))
  (to-html () (span (list :class "label label-default") (synth to-req (const exp))))
  (to-url () (textify exp))
  (to-chunk () exp)
  (to-string () (double-quotes (text "~a" exp))))

(defprod exp (attr ((exp string)))
  (to-list () `(attr (:exp ,exp)))
  (to-req () (text "attributo: ~a" exp))
  (to-html () (span (list :class "label label-danger") (synth to-req (attr exp))))
  (to-string () (textify exp)))

(defprod exp (variable ((name string)))
  (to-list () `(attr (:name ,name)))
  (to-string () (textify name)))

(defprod exp (value ((elem element)))
  (to-list () `(value (:elem ,elem)))
  (to-req () (text "valore dell'elemento: ~a" (synth id elem)))
  (to-html () (span (list :class "label label-default") (synth to-req (value elem))))
  (to-url () (brackets (text "val(~a)" (lower (synth id elem)))))
  (to-chunk () (text "val(~a)" (lower (synth id elem))))
  (to-string () (text "val(~a)" (lower (synth id elem)))))


(defprod exp (cat (&rest (exps exp)))
  (to-list () `(cat (:exps ,(synth-all to-list exps))))
  (to-req () (apply #'hcat 
		    (text "concatenazione delle espressioni:")
		    (synth-all to-req exps)))
  (to-html () (span (list :class "label label-default") (synth to-req (cat exps))))
  (to-string () (text "~{~a~^ ++ ~}" (synth-all to-string exps))))

(defmacro def-bexp (operator &optional (arity 0))
  (let ((name (symb "<" operator ">")))
    `(defprod bexp (,name 
		    ,(if (eq arity 'unbounded)
			 `(&rest (exps bexp))
			 (loop for i from 1 to arity collect `(,(symb "EXP" i) exp))))
       (to-req () (hcat (text "espressione booleana: ~a [" (lower ',name))
       			,@(if (eq arity 'unbounded)
       			     `((synth-all to-req exps))
       			     (loop for i from 1 to arity collect `(synth to-req ,(symb "EXP" i))))
       			(text "]")))
       (to-list () (list ',name 
			 ,(if (eq arity 'unbounded)
			      `(list :exps (synth-all to-list exps))
			      `(list ,@(apply #'append (loop for i from 1 to arity collect (list (keyw "EXP" i) `(synth to-list ,(symb "EXP" i)))))))))
       (to-html () (span nil (synth to-req 
       				    ,(if (eq arity 'unbounded)
       					 `(,name exps)
       					 `(,name ,@(loop for i from 1 to arity collect (symb "EXP" i)))))))
       )))
  
(defmacro def-bexps (&rest bexps)
  `(progn
     ,@(mapcar #'(lambda (bexp)
		   `(def-bexp ,(car bexp) ,@(cdr bexp)))
	       bexps)))

;;(def-bexp true)

(def-bexps (true) (false) (and unbounded) (or unbounded) (not 1) (equal 2) (less-than 2) (greater-than 2))

