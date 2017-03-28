(defprod query (relation ((name (reference entity))))
  (to-list () `(relation :name ,name))
  (schema () (synth attributes (symbol-value name)))
  (to-html () (text "relazione ~a" (lower-camel name))))

(defprod query (project ((query query)
			 &rest (attributes (list attribute)))) 
  (to-list () `(project :attributes ,@attributes :query ,(synth to-list query)))
  (schema () attributes)
  (to-html () (multitags (p nil (text "proiezione degli attributi ~{~a~^, ~} dalla query seguente:" attributes))
                         (p nil (synth to-html query)))))

(defprod query (restrict ((query query)
                          (expression bexpr))) 
  (to-list () `(restrict :expression ,(synth to-list expression) :query ,(synth to-list query)))
  (schema () (synth schema query))
  (to-html () (multitags (p nil 
                            (text "selezione dei record che soddisfano l'espressione ")
                            (synth to-html expression))
                         (p nil (text "dalla query seguente:"))
                         (p nil (synth to-html query)))))

(defprod query (equijoin ((query1 query)
                          (query2 query)
                          &rest (attributes (list attribute)))) 
  (to-list () `(equijoin (:query1 ,(synth to-list query1) :query2 ,(synth to-list query2) :attributes ,(synth-all to-list attributes))))
  (schema () (let ((union (append (synth schema query1)
                                  (synth schema query2))))
               (reduce #'(lambda (acc attr) (remove attr acc :count 1)) 
                       attributes
                       :initial-value union)))
  (to-html () (multitags (p nil (text "Equijoin con attributi ~{~a~^, ~} delle seguenti query:" attributes))
                         (p nil (synth to-html query1))
                         (p nil (synth to-html query2)))))


(defparameter *query* (restrict (equijoin (relation 'news-entity)
                                          (relation 'subscription-entity) 
                                          'news-id) 
                                (+equal+ (+true+) (+true+))))

(pprint (synth output (synth to-doc (synth to-html *query*)) 0))


;;(synth attributes *people*)

