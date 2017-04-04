(defun post-white (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / white-list)) payload))
             ((fork (+equal+ response (const 201))
                    (target (url `(white-creation-success)))
                    (target (url `(white-creation-error))))))))

(defun post-massive-white (file)
  (with-doc* "Effettua l'upload massivo dei dati estratti dal file, verificandone la corretta acquisizione dal server"
    (concat* (json (csv-to-json2 file)) 
             ((map-command (mu* white 
                                (concat*
                                 (response (http-post* (url `(aia / white-list)) (argument white))) 
                                 ((fork (+not+ (+equal+ response (const 201)))
                                        (target (url `(white-creation-error)))
                                        (void-action)))))
                           json)))))

(defun put-white (white-id payload)
    (with-doc* "Effettua l'upload di un nuovo elemento della white list, verificandone la corretta acquisizione dal server"
      (concat* (response (http-put* (url `(aia / white-list / { ,(value white-id) })) payload))
               ((fork (+equal+ response (const 200))
                      (target (url `(white-modification-success)))
                      (target (url `(white-modification-error))))))))

(defun delete-white (white-id)
  (with-doc* "Effettua la cancellazione di un elemento della white list, identificata dall'identificativo fornito"
    (concat* (response (http-delete* (url `(aia / white-list / { ,(value white-id) }))))
             ((fork (+equal+ response (const 200))
                    (target (url `(white-deletion-success)))
                    (target (url `(white-deletion-error))))))))

(element white-creation-form
  (with-doc "Il form di inserimento di un elemento della white list"
    (vert* (white (obj* 'white-data white-format 
                        ((value value (input* (const "Valore")))
                         (type type (input* (const "Tipo"))))
                        (vert value type)))
           ((button* (const "Invio") :click (post-white (payload white)))))))

(element white-massive-creation-form
  (with-doc "Il form di inserimento massivo di elememti della white list"
    (vert* (file (input* (const "Nome file")))
           ((button* (const "Invio") :click (post-massive-white (value file)))))))

(element white-creation-error 
  (with-doc "Pagina visualizzata in presenza di errori nella creazione di un nuovo elemento della white list"
    (vert (label (const "Errore nella specifica dell'elemento della white list"))
          (button* (const "Indietro") :click (target (url `(white-management)))))))

(element white-creation-success 
  (with-doc "Pagina visualizzata in caso di successo nella creazione di un nuovo elemento della white list"
    (vert (label (const "Elemento di white list creato con successo"))
          (button* (const "Indietro") :click (target (url `(white-management)))))))

(element create-white 
  (with-doc "La sezione in cui l'utente può specificare i dati di un nuovo elemento della white list"
    (alt white-massive-creation-form
         (static2 :white-creation-error nil white-creation-error)
         (static2 :white-creation-success nil white-creation-success))))

(element create-massive-white 
  (with-doc "La sezione in cui l'utente può specificare in modo massivo i dati di nuovi elementi della white list"
    (alt white-creation-form
         (static2 :white-creation-error nil white-creation-error)
         (static2 :white-creation-success nil white-creation-success))))

(element white-modification-error 
  (with-doc "Pagina visualizzata in presenza di errori nella modifica di un elemento della white list"
    (vert (label (const "Errore nella specifica dell'elemento della white list"))
          (button* (const "Indietro") :click (target (url `(white-management)))))))

(element white-modification-success 
  (with-doc "Pagina visualizzata in caso di successo nella modifica di un elemento della white list"
    (vert (label (const "Elemento di white list modificato con successo"))
          (button* (const "Indietro") :click (target (url `(white-management)))))))

(defun white-modification-form (white-id)
  (with-doc "Il form di modifica di un elemento della white list esistente, inizializzato con i dati dell'elemento della white list da modificare"
    (with-data* ((white-data (remote 'white-data white-format (url `(aia / white-list / { ,(value white-id) })))))
      (vert* (white (obj* 'white-data white-format 
                      ((name name (input* (const "Nome") :init (attr white-data 'name)))
                       (address address (input* (const "Indirizzo") :init (attr white-data 'address))))
                      (vert name address)))
           ((button* (const "Invio") :click (put-white white-id (payload white))))))))

(defun modify-white (white-id)
  (with-doc "La sezione in cui l'utente può modificare i dati di un elemento della white list esistente"
    (alt (white-modification-form white-id)
         (static2 :white-modification-error nil white-modification-error)
         (static2 :white-modification-success nil white-modification-success))))

(element white-list 
  (with-doc "Vista della white list"
    (tabular* white-format (white-row)
        ('nome (label (filter (prop 'name) white-row))))))

(element white-section
  (with-doc "La sezione di gestione della white list. Qui l'utente può visualizzare, modificare in inserimento e cancellazione la white list" 
    (alt white-list 
         (static2 :create-white nil create-white)
         (static2 :create-white nil create-massive-white)
         (static2 :modify-white (white) (modify-white white)))))





