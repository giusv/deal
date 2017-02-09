(defmacro indicatore (name args params &body body)
  `(defun ,name (,@args ,@params)
    ,@body)) 

;; (indicatore sco1 (soggetto) (durata n-sinistri)
;;   (numero 
;;    ((sinistri soggetto durata))
;;    >>))

;; (processa 
;;  (sinistri soggetto)
;;  (filtra (or (conducente soggetto)
;; 	     (proprietario soggetto)))
;;  (clusterizza durata)
;;  (filtra (> numero n-sinistri))
;;  (conta))
 
(defprod query (table ((name (reference entity))))
  (to-list () `(table :name ,name))
  (schema () (synth attributes (symbol-value name))))

(defprod query (project ((query query)
			 &rest (attributes (list attribute)))) 
  (to-list () `(project :attributes ,@attributes :query ,(synth to-list query)))
  (schema () attributes))

(defprod query (restrict ((query query)
			(expression bexpr))) 
  (to-list () `(restrict :expression ,(synth to-list expression) :query ,(synth to-list query)))
  (schema () (synth attributes query)))

(defprod query (cluster ((query query)
			 (attribute attribute)
			 (duration ))) 
  (to-list () `(restrict :expression ,(synth to-list expression) :query ,(synth to-list query)))
  (schema () (synth attributes query)))
