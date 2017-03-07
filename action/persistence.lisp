(defaction (create-instance ((entity entity)
                             (result variable)
                             (bindings (plist filter expression))))
    (to-list () `(create-instance :entity ,(synth to-list entity) :result ,(synth to-list result) :bindings ,(synth-all to-list bindings) :pre ,(synth to-list pre) :post ,(synth to-list post)))
  (to-req () (hcat (text "Creazione di un'istanza dell'entità ")
                   (synth to-req entity)))
  (to-html () (apply #'div nil 
                     (text "Sia ") 
                     (synth to-html result) 
                     (text " il risultato della creazione della seguente entità:")
                     (div (list :class 'well) (synth to-html entity))
                     (div nil (text "con i seguenti valori:"))
                     (append (synth-plist-merge 
                              #'(lambda (binding) (div nil (synth to-req (first binding)) 
                                                       (text " <- ") 
                                                       (synth to-html (second binding)))) 
                              bindings)
                             (list (maybes (list pre (span nil (text "Precondizione:")))
                                      (list post (span nil (text "Postcondizione:")))))))))


(defun create-instance2 (entity bindings &key pre post)
  (let ((result (variab (gensym))))
    (values (create-instance entity result bindings :pre pre :post post) result)))

(defaction (persist ((entity expression)))
  (to-list () `(persist :entity ,(synth to-list entity) :pre ,(synth to-list pre) :post ,(synth to-list post)))
  (to-req () (hcat (text "Memorizza nel database l'entità ")
                   (synth to-req entity)))
  (to-html () (span nil (synth to-req (persist entity))
                    (maybes (list pre (span nil (text "Precondizione:")))
                            (list post (span nil (text "Postcondizione:")))))))


(defaction (fetch ((entity expression)
                   (result variable)
                   &key (id (id expression))))
  (to-list () `(fetch :entity ,(synth to-list entity) :result ,(synth to-list result) :id ,(synth to-list id) :pre ,(synth to-list pre) :post ,(synth to-list post)))
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
                               (synth to-html id)))

                   (maybes (list pre (span nil (text "Precondizione:")))
                           (list post (span nil (text "Postcondizione:")))))))


(defun fetch2 (entity &key id pre post)
  (let ((result (variab (gensym))))
    (values (fetch entity result :id id :pre pre :post post) result)))


(defaction (erase ((entity expression)
                   (result variable)
                   (id expression)))
  (to-list () `(erase :entity ,(synth to-list entity) :result ,(synth to-list result) :id ,(synth to-list id) :pre ,(synth to-list pre) :post ,(synth to-list post)))
  (to-req () (hcat (text "Rimuove dal database l'entità")
                   (synth to-req entity)
                   (hcat (text "usando come chiave primaria il valore della seguente espressione:")
                         (synth to-req id))))
  (to-html () (div nil 
		   (text "Sia ") 
		   (synth to-html result) 
		   (text " il risultato della rimozione dal database della seguente entità:")
		   (div (list :class 'well) (synth to-html entity))
                   (div nil (text "usando come chiave primaria il valore della seguente espressione:")
                        (synth to-html id))
                   (maybes (list pre (span nil (text "Precondizione:")))
                           (list post (span nil (text "Postcondizione:")))))))


(defun erase2 (entity id &key pre post)
  (let ((result (variab (gensym))))
    (values (erase entity result id :pre pre :post post) result)))
