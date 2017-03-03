(defprod action (create-instance ((entity entity)
                                  (result variable)
                                  &rest (bindings (plist filter expression))))
  (to-list () `(create-instance :entity ,(synth to-list entity) :result (synth to-list result) :values (synth-all to-list values)))
  (to-req () (hcat (text "Creazione di un'istanza dell'entità ")
                   (synth to-req entity)))
  (to-html () (apply #'div nil 
		   (text "Sia ") 
		   (synth to-html result) 
		   (text " il risultato della creazione della seguente entità:")
		   (div (list :class 'well) (synth to-html entity))
                   (div nil (text "con i seguenti valori:"))
                   (synth-plist-merge 
                    #'(lambda (binding) (div nil (synth to-req (first binding)) 
                                             (text " <- ") 
                                             (synth to-html (second binding)))) 
                    bindings))))


(defun create-instance2 (entity &rest values)
  (let ((result (variab (gensym))))
    (values (apply #'create-instance entity result values) result)))

(defprod action (persist ((entity expression)))
  (to-list () `(persist :entity ,(synth to-list entity)))
  (to-req () (hcat (text "Memorizza nel database l'entità ")
                   (synth to-req entity)))
  (to-html () (span nil (synth to-req (persist entity)))))

(defprod action (fetch ((entity expression)
                        (result variable)
                        &optional (id expression)))
  (to-list () `(fetch :entity ,(synth to-list entity) :result ,(synth to-list result) :id ,(synth to-list id)))
  (to-req () (hcat (text "Estrae dal database i dati relativi all'entità")
                   (synth to-req entity)
                   (if id (hcat (text "usando come chiave primaria il valore della seguente espressione:")
                                (synth to-req id)))))
  (to-html () (div nil 
		   (text "Sia ") 
		   (synth to-html result) 
		   (text " il risultato della estrazione seguente entità:")
		   (div (list :class 'well) (synth to-html entity))
                   (if id (div nil (text "usando come chiave primaria il valore della seguente espressione:")
                               (synth to-html id))))))


(defun fetch2 (entity &optional id)
  (let ((result (variab (gensym))))
    (values (fetch entity result id) result)))
