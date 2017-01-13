(defmacro defprod (name &body args)
  `())

(defprod entity
    ((primary attribute star)
     (simple attribute star)
     (foreign foreign star)))
(defprod foreign
    ((source attribute star)
     (target entity one)))

