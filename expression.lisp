(defprod expression (const ((exp (or string number))))
  (to-list () `(const (:exp ,exp))))

(defprod expression (attr ((exp string)))
  (to-list () `(attr (:exp ,exp))))

(defprod expression (rel (())))

;; (defprods expression 
;;     (const (or string number))
;;   )