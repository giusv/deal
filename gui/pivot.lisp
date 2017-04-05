(defprod element (pivot ((name symbol)
                         (source datasource)
                         &rest (selectors (list symbol))))
  (to-list () `(pivot (:name ,name 
                             :source ,(synth to-list source) 
                             :selectors ,selectors)))
  (to-html (path)
	   (multitags
                (text "Tabella pivot denominata ")
                (span-color (lower-camel name))
                (text " associata al formato dati ~a con i seguenti selettori/aggregatori: ~{~a~^, ~}." 
                      (lower-camel (synth name source)) (mapcar #'lower-camel selectors))))
  (to-brief (path) (synth to-html (apply #'pivot name source selectors)))
  (toplevel () nil)
  (req (path) nil))

(defmacro pivot* (source &body selectors)
  `(pivot (gensym "PIVOT") 
          ,source
          ,@selectors))
