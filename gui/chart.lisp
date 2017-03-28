(defprod element (chart ((name symbol)
                         (source datasource)
                         ))
  (to-list () `(chart (:name ,name :source ,(synth to-list source))))
  (to-html (path)
	   (multitags 
                (text "Grafico associato al formato dati ~a" (lower-camel (synth name (synth schema source))))))
  (to-brief (path) (synth to-html (apply #'chart name source bindings)))
  (toplevel () nil)
  (req (path) nil))

(defmacro chart* (source)
  `(chart (gensym "CHART") ,source))

