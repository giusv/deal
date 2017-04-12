(defun post-white (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / white-list)) payload))
             ((fork (+equal+ response (const 201))
                    (show-modal (modal 'successo (const "Elemento di white list creato con successo")))
                    (show-modal (modal 'errore (const "Errore nella specifica dell'elemento della white list"))))))))

(defun post-massive-white (file)
  (with-doc* "Effettua l'upload massivo dei dati estratti dal file, verificandone la corretta acquisizione dal server"
    (concat* (json (csv-to-json2 file)) 
             ((map-command (mu* white 
                                (concat*
                                 (response (http-post* (url `(aia / white-list)) (argument white))) 
                                 ((fork (+equal+ response (const 201))
                                        (void-action)
                                        (show-modal (modal 'errore (const "Errore nella specifica dell'elemento della white list")))))))
                           json))
             ((show-modal (modal 'successo (const "Elementi di white list creati con successo")))))))

(defun put-white (white-id payload)
    (with-doc* "Effettua l'upload di un nuovo elemento della white list, verificandone la corretta acquisizione dal server"
      (concat* (response (http-put* (url `(aia / white-list / { ,(value white-id) })) payload))
               ((fork (+equal+ response (const 200))
                      (show-modal (modal 'successo (const "Elemento di white list modificato con successo")))
                      (show-modal (modal 'errore (const "Errore nella modifica dell'elemento della white list"))))))))

(defun delete-white (white-id)
  (with-doc* "Effettua la cancellazione di un elemento della white list, identificata dall'identificativo fornito"
    (concat* (response (http-delete* (url `(aia / white-list / { ,(value white-id) }))))
             ((fork (+equal+ response (const 200))
                    (show-modal (modal 'successo (const "Elemento di white list cancellato con successo")))
                    (show-modal (modal 'errore (const "Errore nella cancellazione dell'elemento della white list"))))))))

(element white-creation-form
  (with-doc "Il form di inserimento di un elemento della white list"
    (vert* (white (obj* 'white-data white-format 
                        ((value value (gui-input 'valore (const "Valore")))
                         (type type (gui-input 'tipo (const "Tipo"))))
                        (vert value type)))
           ((gui-button 'invio (const "Invio") :click (post-white (payload white)))))))

(element white-massive-creation-form
  (with-doc "Il form di inserimento massivo di elememti della white list"
    (vert* (file (gui-input 'nome-file (const "Nome file")))
           ((gui-button 'invio (const "Invio") :click (post-massive-white (value file)))))))

;; (element white-creation-error 
;;   (with-doc "Pagina visualizzata in presenza di errori nella creazione di un nuovo elemento della white list"
;;     (vert (label (const "Errore nella specifica dell'elemento della white list"))
;;           (gui-button ' (const "Indietro") :click (target (url `(aia / gestione-liste / white-list)))))))

;; (element white-creation-success 
;;   (with-doc "Pagina visualizzata in caso di successo nella creazione di un nuovo elemento della white list"
;;     (vert (label (const "Elemento di white list creato con successo"))
;;           (gui-button ' (const "Indietro") :click (target (url `(aia / gestione-liste / white-list)))))))

(element create-white 
  (with-doc "La sezione in cui l'utente può specificare i dati di un nuovo elemento della white list"
    white-creation-form
         ;; (static2 :white-creation-error nil white-creation-error)
         ;; (static2 :white-creation-success nil white-creation-success)
         ))

;; (element white-massive-creation-error 
;;   (with-doc "Pagina visualizzata in presenza di errori nella creazione massiva di nuovi elementi della white list"
;;     (vert (label (const "Errore nel file con i nuovi elementi della white list"))
;;           (gui-button ' (const "Indietro") :click (target (url `(aia / gestione-liste / white-list)))))))

;; (element white-massive-creation-success 
;;   (with-doc "Pagina visualizzata in caso di successo nella creazione massiva di nuovi elementi della white list"
;;     (vert (label (const "Elementi di white list creati con successo"))
;;           (gui-button ' (const "Indietro") :click (target (url `(aia / gestione-liste / white-list)))))))

(element create-massive-white 
  (with-doc "La sezione in cui l'utente può specificare in modo massivo i dati di nuovi elementi della white list"
    white-massive-creation-form
         ;; (static2 :white-massive-creation-error nil white-massive-creation-error)
         ;; (static2 :white-massive-creation-success nil white-massive-creation-success)
         ))

;; (element white-modification-error 
;;   (with-doc "Pagina visualizzata in presenza di errori nella modifica di un elemento della white list"
;;     (vert (label (const "Errore nella specifica dell'elemento della white list"))
;;           (gui-button ' (const "Indietro") :click (target (url `(aia / gestione-liste / white-list)))))))

;; (element white-modification-success 
;;   (with-doc "Pagina visualizzata in caso di successo nella modifica di un elemento della white list"
;;     (vert (label (const "Elemento di white list modificato con successo"))
;;           (gui-button ' (const "Indietro") :click (target (url `(aia / gestione-liste / white-list)))))))

(defun white-modification-form (white-id)
  (with-doc "Il form di modifica di un elemento della white list esistente, inizializzato con i dati dell'elemento della white list da modificare"
    (with-data* ((white-data (remote 'white-data white-format (url `(aia / white-list / { ,(value white-id) })))))
      (vert* (white (obj* 'white-data white-format 
                        ((value value (gui-input 'valore (const "Valore") :init (attr white-data 'valore)))
                         (type type (gui-input 'tipo (const "Tipo") :init (attr white-data 'tipo))))
                        (vert value type))) 
           ((gui-button 'invio (const "Invio") :click (put-white white-id (payload white))))))))

(defun modify-white (white-id)
  (with-doc "La sezione in cui l'utente può modificare i dati di un elemento della white list esistente"
    (white-modification-form white-id)
         ;; (static2 :white-modification-error nil white-modification-error)
         ;; (static2 :white-modification-success nil white-modification-success)
         ))

(element white-list 
  (with-doc "Vista della white list"
    (tabular* white-format (white-row)
        ('valore (label (attr white-row 'valore)))
        ('tipo (label (attr white-row 'tipo)))
        ('elimina (gui-button 'elimina (const "Elimina") :click (delete-white (filter (prop 'white-id) white-row))))
        ('modifica (gui-button 'modifica (const "Modifica") 
                            :click (target (url `(aia / gestione-liste / white-list / modifica-white 
                                                      ? white = { ,(value (filter (prop 'white-id) white-row)) }))))))))

(element white-section
  (with-doc "La sezione di gestione della white list. Qui l'utente può visualizzare, modificare in inserimento e cancellazione la white list" 
    (alt white-list 
         (static2 :crea-white nil create-white)
         (static2 :crea-white-massiva nil create-massive-white)
         (static2 :modifica-white (white) (modify-white white)))))





