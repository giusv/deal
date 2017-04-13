(defaction (create-instance ((entity entity)
                             (result variable)
                             (bindings (plist filter expression))))
  (to-list () `(create-instance :entity ,(synth to-list entity) :result ,(synth to-list result) :bindings ,(synth-all to-list bindings) :pre ,(synth to-list pre) :post ,(synth to-list post)))
  (to-req () (hcat (text "Creazione di un'istanza dell'entit&agrave; ")
                   (synth to-req entity)))
  (to-html () (multitags 
               (text "Sia ") 
               (synth to-html result) 
               (text " il risultato della creazione dell'entit&agrave;
               ~a" (lower-camel (synth name entity)))
               (text " con i seguenti valori:")
               (apply #'multitags (synth-plist-merge 
                                   #'(lambda (binding) (p nil (synth to-req (first binding)) 
                                                          (text " <- ") 
                                                          (synth to-html (second binding)))) 
                                   bindings))
               (dlist pre (text "Precondizione: ") (synth to-html pre)
                      post (text "Postcondizione:") (synth to-html post)))))


(defun create-instance2 (entity bindings &key pre post)
  (let ((result (variab (gensym))))
    (values (create-instance entity result bindings :pre pre :post post) result)))


;; (defmacro create-instance2 (entity (&rest bindings) &key pre post)
;;   (let ((result (variab (gensym))))
;;     `(values (create-instance ,entity 
;;                               ,result 
;;                               (list ,@(apply #'append 
;;                                             (mapcar (lambda (binding)
;;                                                       (list `(prop ',(symb (symbol-name (car binding))))
;;                                                             (cadr binding)))
;;                                                     (group bindings 2)))) 
;;                               :pre ,pre :post ,post) 
;;              ,result)))

;; (create-instance2 document-entity
;;                   (:id (autokey)
;;                    :type type
;;                    :cue cue
;;                    :binary binary))

(defaction (update-instance ((entity entity)
                             (source variable)
                             (result variable)
                             (bindings (plist filter expression))))
  (to-list () `(update-instance :entity ,(synth to-list entity) :source ,(synth to-list source) :result ,(synth to-list result) :bindings ,(synth-all to-list bindings) :pre ,(synth to-list pre) :post ,(synth to-list post)))
  ;; (to-req () (hcat (text "Creazione di un'istanza dell'entit&agrave; ")
  ;;                  (synth to-req entity)))
  (to-html () (multitags 
               (text "Sia ") 
               (synth to-html result) 
               (text " il risultato dell'aggiornamento creazione dell'entit&agrave; ")
               (synth to-html source)
               (text " (~a)" (lower-camel (synth name entity)))
               (text " con i seguenti valori:")
               (apply #'multitags (synth-plist-merge 
                                   #'(lambda (binding) (p nil (synth to-req (first binding)) 
                                                          (text " <- ") 
                                                          (synth to-html (second binding)))) 
                                   bindings))
               (dlist pre (text "Precondizione: ") (synth to-html pre)
                      post (text "Postcondizione:") (synth to-html post)))))


(defun update-instance2 (entity source bindings &key pre post)
  (let ((result (variab (gensym))))
    (values (update-instance entity source result bindings :pre pre :post post) result)))


;; (defaction (persist ((entity entity)
;;                      (content expression)))
;;   (to-list () `(persist :entity ,(synth to-list entity) :content ,(synth to-list content) :pre ,(synth to-list pre) :post ,(synth to-list post)))
;;   (to-req () (hcat (text "Memorizza nel database l'entit&agrave; ")
;;                    (synth to-req entity)))
;;   (to-html () (multitags (text "M nel database l'entit&agrave; ")
;;                          (synth to-html entity)
;;                          (text " con il c")
;;                          (dlist pre (text "Precondizione: ") (synth to-html pre)
;;                                 post (text "Postcondizione:") (synth to-html post)))))


(defaction (query ((query query)
                   (result variable)))
  (to-list () `(query :query ,(synth to-list query) :result ,(synth to-list result) :pre ,(synth to-list pre) :post ,(synth to-list post)))
  (to-req () (hcat (text "Estrae dal database i dati relativi alla query seguente:")
                   (synth to-req query)))
  (to-html () (multitags
               (text "Sia ") 
               (synth to-html result) 
               (text " il risultato dell'esecuzione della seguente query:")
               (synth to-html query)
               (dlist pre (text "Precondizione: ") (synth to-html pre)
                      post (text "Postcondizione:") (synth to-html post)))))


(defun query2 (query &key pre post)
  (let ((result (variab (gensym))))
    (values (query query result :pre pre :post post) result)))

(defaction (fetch ((entity expression)
                   (result variable)
                   &key (id (id expression))))
  (to-list () `(fetch :entity ,(synth to-list entity) :result ,(synth to-list result) :id ,(synth to-list id) :pre ,(synth to-list pre) :post ,(synth to-list post)))
  (to-req () (hcat (text "Estrae dal database i dati relativi all'entit&agrave;")
                   (synth to-req entity)
                   (if id (hcat (text "usando come chiave primaria il valore della seguente espressione:")
                                (synth to-req id)))))
  (to-html () (multitags
               (text "Sia ") 
               (synth to-html result) 
               (text " il risultato della estrazione dell'entit&agrave; ~a" (lower-camel (synth name entity)))
               (if id (multitags (text " usando come chiave primaria il valore della seguente espressione:")
                                 (synth to-html id)))
               (dlist pre (text "Precondizione: ") (synth to-html pre)
                      post (text "Postcondizione:") (synth to-html post)))))


(defun fetch2 (entity &key id pre post)
  (let ((result (variab (gensym))))
    (values (fetch entity result :id id :pre pre :post post) result)))


(defaction (erase ((entity expression)
                   (result variable)
                   (id expression)))
  (to-list () `(erase :entity ,(synth to-list entity) :result ,(synth to-list result) :id ,(synth to-list id) :pre ,(synth to-list pre) :post ,(synth to-list post)))
  (to-req () (hcat (text "Rimuove dal database l'entit&agrave;")
                   (synth to-req entity)
                   (hcat (text "usando come chiave primaria il valore
                   della seguente espressione:")
                         (synth to-req id))))
  (to-html () (multitags 
               (text "Sia ") 
               (synth to-html result) 
               (text " il risultato della rimozione dal database dell'entit&agrave; ~a" (lower-camel (synth name entity)))
               (p nil (text " usando come chiave primaria il valore della seguente espressione:")
                  (synth to-html id))
               (dlist pre (text "Precondizione: ") (synth to-html pre)
                      post (text "Postcondizione:") (synth to-html post)))))


(defun erase2 (entity id &key pre post)
  (let ((result (variab (gensym))))
    (values (erase entity result id :pre pre :post post) result)))

(defaction (update ((entity expression)
                    (id expression)))
  (to-list () `(update :entity ,(synth to-list entity) :id ,(synth to-list id) :pre ,(synth to-list pre) :post ,(synth to-list post)))
  (to-req () (hcat (text "Aggiorna nel database l'entit&agrave; corrispondente alla seguente chiave primaria:" )
                   (synth to-req id)
                   (text "con il contenuto di") 
                   (synth to-req entity)))
  (to-html () (multitags (text "Aggiorna nel database l'entit&agrave; corrispondente alla chiave primaria ")
                         (synth to-html id)
                         (text " con il contenuto di ")
                         (synth to-html entity)
                         (dlist pre (text "Precondizione: ") (synth to-html pre)
                                post (text "Postcondizione:") (synth to-html post)))

           ;; (multitags 
           ;;     (text "Sia ") 
           ;;     (synth to-html result) 
           ;;     (text " il risultato dell'aggiornamento nel database dell'entit&agrave; ~a" (lower-camel (synth name entity)))
           ;;     (p nil (text " corrispondente alla seguente chiave primaria:")
           ;;        (synth to-html id))
           ;;     (dlist pre (text "Precondizione: ") (synth to-html pre)
           ;;            post (text "Postcondizione:") (synth to-html post)))
           ))


;; (defun update2 (entity id &key pre post)
;;   (let ((result (variab (gensym))))
;;     (values (update entity id result :pre pre :post post) result)))
