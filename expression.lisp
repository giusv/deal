(defprod exp (const ((exp (or string number))))
  (to-list () `(const (:exp ,exp))))

(defprod exp (attr ((exp string)))
  (to-list () `(attr (:exp ,exp))))

(defprod exp (cat (&rest (exps exp)))
  (to-list () `(cat (:exps ,(synth-all to-list exps)))))

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

