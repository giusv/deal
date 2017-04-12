(defun post-black (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / black-list)) payload))
             ((fork (+equal+ response (const 201))
                    (show-modal (modal 'successo (const "Elemento di black list creato con successo")))
                    (show-modal (modal 'errore (const "Errore nella specifica dell'elemento della black list"))))))))

(defun post-massive-black (file)
  (with-doc* "Effettua l'upload massivo dei dati estratti dal file, verificandone la corretta acquisizione dal server"
    (concat* (json (csv-to-json2 file)) 
             ((map-command (mu* black 
                                (concat*
                                 (response (http-post* (url `(aia / black-list)) (argument black))) 
                                 ((fork (+equal+ response (const 201))
                                        (void-action)
                                        (show-modal (modal 'errore (const "Errore nella specifica dell'elemento della black list")))))))
                           json))
             ((show-modal (modal 'successo (const "Elementi di black list creati con successo")))))))

(defun put-black (black-id payload)
    (with-doc* "Effettua l'upload di un nuovo elemento della black list, verificandone la corretta acquisizione dal server"
      (concat* (response (http-put* (url `(aia / black-list / { ,(value black-id) })) payload))
               ((fork (+equal+ response (const 200))
                      (show-modal (modal 'successo (const "Elemento di black list modificato con successo")))
                      (show-modal (modal 'errore (const "Errore nella modifica dell'elemento della black list"))))))))

(defun delete-black (black-id)
  (with-doc* "Effettua la cancellazione di un elemento della black list, identificata dall'identificativo fornito"
    (concat* (response (http-delete* (url `(aia / black-list / { ,(value black-id) }))))
             ((fork (+equal+ response (const 200))
                    (show-modal (modal 'successo (const "Elemento di black list cancellato con successo")))
                    (show-modal (modal 'errore (const "Errore nella cancellazione dell'elemento della black list"))))))))

(element black-creation-form
  (with-doc "Il form di inserimento di un elemento della black list"
    (vert* (black (obj* 'black-data black-format 
                        ((value value (gui-input 'valore (const "Valore")))
                         (type type (gui-input 'tipo (const "Tipo"))))
                        (vert value type)))
           ((gui-button 'invio (const "Invio") :click (post-black (payload black)))))))

(element black-massive-creation-form
  (with-doc "Il form di inserimento massivo di elememti della black list"
    (vert* (file (gui-input 'nome-file (const "Nome file")))
           ((gui-button 'invio (const "Invio") :click (post-massive-black (value file)))))))

;; (element black-creation-error 
;;   (with-doc "Pagina visualizzata in presenza di errori nella creazione di un nuovo elemento della black list"
;;     (vert (label (const "Errore nella specifica dell'elemento della black list"))
;;           (gui-button ' (const "Indietro") :click (target (url `(aia / gestione-liste / black-list)))))))

;; (element black-creation-success 
;;   (with-doc "Pagina visualizzata in caso di successo nella creazione di un nuovo elemento della black list"
;;     (vert (label (const "Elemento di black list creato con successo"))
;;           (gui-button ' (const "Indietro") :click (target (url `(aia / gestione-liste / black-list)))))))

(element create-black 
  (with-doc "La sezione in cui l'utente può specificare i dati di un nuovo elemento della black list"
    black-creation-form
         ;; (static2 :black-creation-error nil black-creation-error)
         ;; (static2 :black-creation-success nil black-creation-success)
         ))

;; (element black-massive-creation-error 
;;   (with-doc "Pagina visualizzata in presenza di errori nella creazione massiva di nuovi elementi della black list"
;;     (vert (label (const "Errore nel file con i nuovi elementi della black list"))
;;           (gui-button ' (const "Indietro") :click (target (url `(aia / gestione-liste / black-list)))))))

;; (element black-massive-creation-success 
;;   (with-doc "Pagina visualizzata in caso di successo nella creazione massiva di nuovi elementi della black list"
;;     (vert (label (const "Elementi di black list creati con successo"))
;;           (gui-button ' (const "Indietro") :click (target (url `(aia / gestione-liste / black-list)))))))

(element create-massive-black 
  (with-doc "La sezione in cui l'utente può specificare in modo massivo i dati di nuovi elementi della black list"
    black-massive-creation-form
         ;; (static2 :black-massive-creation-error nil black-massive-creation-error)
         ;; (static2 :black-massive-creation-success nil black-massive-creation-success)
         ))

;; (element black-modification-error 
;;   (with-doc "Pagina visualizzata in presenza di errori nella modifica di un elemento della black list"
;;     (vert (label (const "Errore nella specifica dell'elemento della black list"))
;;           (gui-button ' (const "Indietro") :click (target (url `(aia / gestione-liste / black-list)))))))

;; (element black-modification-success 
;;   (with-doc "Pagina visualizzata in caso di successo nella modifica di un elemento della black list"
;;     (vert (label (const "Elemento di black list modificato con successo"))
;;           (gui-button ' (const "Indietro") :click (target (url `(aia / gestione-liste / black-list)))))))

(defun black-modification-form (black-id)
  (with-doc "Il form di modifica di un elemento della black list esistente, inizializzato con i dati dell'elemento della black list da modificare"
    (with-data* ((black-data (remote 'black-data black-format (url `(aia / black-list / { ,(value black-id) })))))
      (vert* (black (obj* 'black-data black-format 
                        ((value value (gui-input 'valore (const "Valore") :init (attr black-data 'valore)))
                         (type type (gui-input 'tipo (const "Tipo") :init (attr black-data 'tipo))))
                        (vert value type))) 
           ((gui-button 'invio (const "Invio") :click (put-black black-id (payload black))))))))

(defun modify-black (black-id)
  (with-doc "La sezione in cui l'utente può modificare i dati di un elemento della black list esistente"
    (black-modification-form black-id)
         ;; (static2 :black-modification-error nil black-modification-error)
         ;; (static2 :black-modification-success nil black-modification-success)
         ))

(element black-list 
  (with-doc "Vista della black list"
    (tabular* black-format (black-row)
        ('valore (label (attr black-row 'valore)))
        ('tipo (label (attr black-row 'tipo)))
        ('elimina (gui-button 'elimina (const "Elimina") :click (delete-black (filter (prop 'black-id) black-row))))
        ('modifica (gui-button 'modifica (const "Modifica") 
                            :click (target (url `(aia / gestione-liste / black-list / modifica-black 
                                                      ? black = { ,(value (filter (prop 'black-id) black-row)) }))))))))

(element black-section
  (with-doc "La sezione di gestione della black list. Qui l'utente può visualizzare, modificare in inserimento e cancellazione la black list" 
    (alt black-list 
         (static2 :crea-black nil create-black)
         (static2 :crea-black-massiva nil create-massive-black)
         (static2 :modifica-black (black) (modify-black black)))))





