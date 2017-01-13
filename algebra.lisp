(defmacro defsum (name &body args)
  `())

;; (defprod attribute
;;     ((name 'string one)
;;      (type ')))
;; (defprod entity
;;     ((primary attribute star)
;;      (simple attribute star)
;;      (foreign foreign star)))
;; (defprod foreign
;;     ((source attribute star)
;;      (target entity one)))


(defsum doc
    ((empty)
     (text format args)
     (nest amount doc)
     (vcat docs)))

(defclass doc () ())
(defclass empty (doc) ())
(defclass nest (doc) (amount doc))
(defclass vcat (doc) (docs))

(defalgebra doc pretty 
  ((empty (lambda () (format nil "")))
   (text  (lambda (format args) ()))
	 
   ))