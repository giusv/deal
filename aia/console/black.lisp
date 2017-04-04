(defun post-black (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / black-list)) payload))
             ((fork (+equal+ response (const 201))
                    (target (url `(black-creation-success)))
                    (target (url `(black-creation-error))))))))

(defun post-massive-black (file)
  (with-doc* "Effettua l'upload massivo dei dati estratti dal file, verificandone la corretta acquisizione dal server"
    (concat* (json (csv-to-json2 file)) 
             ((map-command (mu* black 
                                (concat*
                                 (response (http-post* (url `(aia / black-list)) (argument black))) 
                                 ((fork (+equal+ response (const 201))
                                        (void-action)
                                        (target (url `(gestione-black-white-list / black-list / create-black / black-creation-error)))))))
                           json))
             ((target (url `(gestione-black-white-list / black-list / create-black / black-creation-success)))))))

(defun put-black (black-id payload)
    (with-doc* "Effettua l'upload di un nuovo elemento della black list, verificandone la corretta acquisizione dal server"
      (concat* (response (http-put* (url `(aia / black-list / { ,(value black-id) })) payload))
               ((fork (+equal+ response (const 200))
                      (target (url `(gestione-black-white-list / black-list / create-black / black-modification-success)))
                      (target (url `(gestione-black-white-list / black-list / create-black / black-modification-error))))))))

(defun delete-black (black-id)
  (with-doc* "Effettua la cancellazione di un elemento della black list, identificata dall'identificativo fornito"
    (concat* (response (http-delete* (url `(aia / black-list / { ,(value black-id) }))))
             ((fork (+equal+ response (const 200))
                    (target (url `(gestione-black-white-list / black-list / create-black / black-deletion-success)))
                    (target (url `(gestione-black-white-list / black-list / create-black / black-deletion-error))))))))

(element black-creation-form
  (with-doc "Il form di inserimento di un elemento della black list"
    (vert* (black (obj* 'black-data black-format 
                        ((value value (input* (const "Valore")))
                         (type type (input* (const "Tipo"))))
                        (vert value type)))
           ((button* (const "Invio") :click (post-black (payload black)))))))

(element black-massive-creation-form
  (with-doc "Il form di inserimento massivo di elememti della black list"
    (vert* (file (input* (const "Nome file")))
           ((button* (const "Invio") :click (post-massive-black (value file)))))))

(element black-creation-error 
  (with-doc "Pagina visualizzata in presenza di errori nella creazione di un nuovo elemento della black list"
    (vert (label (const "Errore nella specifica dell'elemento della black list"))
          (button* (const "Indietro") :click (target (url `(black-management)))))))

(element black-creation-success 
  (with-doc "Pagina visualizzata in caso di successo nella creazione di un nuovo elemento della black list"
    (vert (label (const "Elemento di black list creato con successo"))
          (button* (const "Indietro") :click (target (url `(black-management)))))))

(element create-black 
  (with-doc "La sezione in cui l'utente può specificare i dati di un nuovo elemento della black list"
    (alt black-massive-creation-form
         (static2 :black-creation-error nil black-creation-error)
         (static2 :black-creation-success nil black-creation-success))))

(element create-massive-black 
  (with-doc "La sezione in cui l'utente può specificare in modo massivo i dati di nuovi elementi della black list"
    (alt black-creation-form
         (static2 :black-creation-error nil black-creation-error)
         (static2 :black-creation-success nil black-creation-success))))

(element black-modification-error 
  (with-doc "Pagina visualizzata in presenza di errori nella modifica di un elemento della black list"
    (vert (label (const "Errore nella specifica dell'elemento della black list"))
          (button* (const "Indietro") :click (target (url `(black-management)))))))

(element black-modification-success 
  (with-doc "Pagina visualizzata in caso di successo nella modifica di un elemento della black list"
    (vert (label (const "Elemento di black list modificato con successo"))
          (button* (const "Indietro") :click (target (url `(black-management)))))))

(defun black-modification-form (black-id)
  (with-doc "Il form di modifica di un elemento della black list esistente, inizializzato con i dati dell'elemento della black list da modificare"
    (with-data* ((black-data (remote 'black-data black-format (url `(aia / black-list / { ,(value black-id) })))))
      (vert* (black (obj* 'black-data black-format 
                      ((name name (input* (const "Nome") :init (attr black-data 'name)))
                       (address address (input* (const "Indirizzo") :init (attr black-data 'address))))
                      (vert name address)))
           ((button* (const "Invio") :click (put-black black-id (payload black))))))))

(defun modify-black (black-id)
  (with-doc "La sezione in cui l'utente può modificare i dati di un elemento della black list esistente"
    (alt (black-modification-form black-id)
         (static2 :black-modification-error nil black-modification-error)
         (static2 :black-modification-success nil black-modification-success))))

(element black-list 
  (with-doc "Vista della black list"
    (tabular* black-format (black-row)
        ('valore (label (filter (prop 'value) black-row))))))

(element black-section
  (with-doc "La sezione di gestione della black list. Qui l'utente può visualizzare, modificare in inserimento e cancellazione la black list" 
    (alt black-list 
         (static2 :create-black nil create-black)
         (static2 :create-massive-black nil create-massive-black)
         (static2 :modify-black (black) (modify-black black)))))





