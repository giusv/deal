(defprod exp (const ((exp (or string number))))
  (to-list () `(const (:exp ,exp)))
  (to-req () (text "stringa costante: ~a" exp))
  (to-chunk () exp))

(defprod exp (attr ((exp string)))
  (to-list () `(attr (:exp ,exp)))
  (to-req () (text "attributo: ~a" exp)))

(defprod exp (value ((elem element)))
  (to-list () `(value (:elem ,elem)))
  (to-req () (text "valore dell'elemento: ~a" (synth id elem)))
  (to-chunk () (text "val(~a)" (lower (synth id elem)))))

(defprod exp (path-parameter ((name string)))
  (to-list () `(path-parameter (:name ,name)))
  (to-req () (text "parametro path: ~a" name))
  (to-url () (dynamic-chunk name)))

(defprod exp (cat (&rest (exps exp)))
  (to-list () `(cat (:exps ,(synth-all to-list exps))))
  (to-req () (apply #'vcat 
		    (text "concatenazione delle espressioni:")
		    (synth-all to-req exps))))

(defprod bexp (<true> ())
  (to-list () `(<true>)))
(defprod bexp (<false> ())
  (to-list () `(<false>)))
(defprod bexp (<and> (&rest (exps bexp)))
  (to-list () `(<and> (:exps ,(synth-all to-list exps)))))
(defprod bexp (<or> (&rest (exps bexp)))
  (to-list () `(<or> (:exps ,(synth-all to-list exps)))))
(defprod bexp (<not> ((exp bexp)))
    (to-list () `(<not> (:exp ,(synth to-list exp)))))
(defprod bexp (<equal> ((exp1 exp) (exp2 exp)))
    (to-list () `(<equal> (:exp1 ,(synth to-list exp1) ,(synth to-list exp2)))))
(defprod bexp (<less-than> ((exp1 exp) (exp2 exp)))
    (to-list () `(<less-than> (:exp1 ,(synth to-list exp1) ,(synth to-list exp2)))))
(defprod bexp (<greater-than> ((exp1 exp) (exp2 exp)))
    (to-list () `(<greater-than> (:exp1 ,(synth to-list exp1) ,(synth to-list exp2)))))



;; (defprods exp
;;     (const (or string number))
;;   )

