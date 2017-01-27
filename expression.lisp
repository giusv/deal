(defprod expression (const ((exp (or string number))))
  (to-list () `(const (:exp ,exp))))

(defprod expression (attr ((exp string)))
  (to-list () `(attr (:exp ,exp))))

(defprod expression (cat (&rest (exps expression)))
  (to-list () `(cat (:exps ,(synth-all to-list exps)))))

(defprod boolean-expression (<true> ())
  (to-list () `(<true>)))
(defprod boolean-expression (<false> ())
  (to-list () `(<false>)))
(defprod boolean-expression (<and> (&rest (exps boolean-expression)))
  (to-list () `(<and> (:exps ,(synth-all to-list exps)))))
(defprod boolean-expression (<or> (&rest (exps boolean-expression)))
  (to-list () `(<or> (:exps ,(synth-all to-list exps)))))
(defprod boolean-expression (<not> ((exp boolean-expression)))
    (to-list () `(<not> (:exp ,(synth to-list exp)))))
(defprod boolean-expression (<equal> ((exp1 expression) (exp2 expression)))
    (to-list () `(<equal> (:exp1 ,(synth to-list exp1) ,(synth to-list exp2)))))
(defprod boolean-expression (<less-than> ((exp1 expression) (exp2 expression)))
    (to-list () `(<less-than> (:exp1 ,(synth to-list exp1) ,(synth to-list exp2)))))
(defprod boolean-expression (<greater-than> ((exp1 expression) (exp2 expression)))
    (to-list () `(<greater-than> (:exp1 ,(synth to-list exp1) ,(synth to-list exp2)))))
;; (defprods expression 
;;     (const (or string number))
;;   )

