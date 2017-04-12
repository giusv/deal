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
            (text " associata a ")
            (span-color (lower-camel (synth name source)))
            (text "(istanza del formato dati ") 
            (a (list :href (concatenate 'string "#" (synth to-string (synth to-brief (synth schema source)) 0)))
               (code nil (synth to-brief (synth schema source ))))
            (text "), con i seguenti selettori/aggregatori: ~{~a~^, ~}." 
                   (mapcar #'lower-camel selectors))))

  (to-brief (path) (synth to-html (apply #'pivot name source selectors)))
  (toplevel () nil)
  (req (path) nil))

(defmacro pivot* (source &body selectors)
  `(pivot (gensym "PIVOT") 
          ,source
          ,@selectors))
