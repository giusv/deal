;;; Company section 
;; (crud company-format (url `(aia))
;;       (vert (label (cat (const "Compagnia id:") company-id))
;;             (label (attr company-data 'name))
;;             (label (attr company-data 'indirizzi))
;;             (button* (const "Elimina") :click (delete-company company-id))
;;             (button* (const "Modifica") :click (target (url `(gestione-compagnie / modify-company ? ,(value company-id))))))

;;       )
(defun post-company (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / compagnie)) payload))
             ((fork (+equal+ response (const 201))
                    (show-modal (modal 'successo (const "Compagnia creata con successo")))
                    (show-modal (modal 'errore (const "Errore nella specifica della compagnia"))))))))
(defun put-company (company-id payload)
  (with-doc* "Effettua l'upload dei dati di una compagnia, verificandone la corretta acquisizione dal server"
    (concat* (response (http-put* (url `(aia / compagnie / { ,(value company-id) })) payload))
             ((fork (+equal+ response (const 200))
                    (show-modal (modal 'successo (const "Compagnia modificata con successo")))
                    (show-modal (modal 'errore (const "Errore nella modifica della compagnia"))))))))

(defun delete-company (company-id)
  (with-doc* "Effettua la cancellazione dei dati della compagnia identificata dall'identificativo fornito"
    (concat* (response (http-delete* (url `(aia / compagnie / { ,(value company-id) }))))
             ((fork (+equal+ response (const 200))
                    (show-modal (modal 'successo (const "Compagnia cancellata con successo")))
                    (show-modal (modal 'errore (const "Errore nella cancellazione della compagnia"))))))))

(element company-creation-form
  (with-doc "Il form di inserimento dei dati di una nuova compagnia"
    (vert* (comp (obj* 'comp-data company-format 
                      ((name name (gui-input 'nome (const "Nome")))
                       (address address (replica 'indirizzi company-address-format (gui-input 'indirizzo (const "Indirizzo")))))
                      (vert name address)))
           ((gui-button 'invio (const "Invio") :click (post-company (payload comp)))))))

;; (element company-creation-error 
;;   (with-doc "Pagina visualizzata in presenza di errori nella creazione di una nuova compagnia"
;;     (vert (label (const "Errore nella specifica della compagnia"))
;;           (button* (const "Indietro") :click (target (url `(gestione-compagnie)))))))

;; (element company-creation-success 
;;   (with-doc "Pagina visualizzata in caso di successo nella creazione di una nuova compagnia"
;;     (vert (label (const "Compagnia creata con successo"))
;;           (button* (const "Indietro") :click (target (url `(gestione-compagnie)))))))

(element create-company 
  (with-doc "La sezione in cui l'utente pu&ograve; specificare i dati di una nuova compagnia"
    company-creation-form
         ;; (static2 :company-creation-error nil company-creation-error)
         ;; (static2 :company-creation-success nil company-creation-success)
         ))

;; (element company-modification-error 
;;   (with-doc "Pagina visualizzata in presenza di errori nella modifica di una compagnia"
;;     (vert (label (const "Errore nella specifica della compagnia"))
;;           (button* (const "Indietro") :click (target (url `(gestione-compagnie)))))))

;; (element company-modification-success 
;;   (with-doc "Pagina visualizzata in caso di successo nella modifica di una compagnia"
;;     (vert (label (const "Compagnia modificata con successo"))
;;           (button* (const "Indietro") :click (target (url `(gestione-compagnie)))))))

(defun company-modification-form (company-id)
  (with-doc "Il form di modifica di una compagnia esistente, inizializzato con i dati della compagnia da modificare"
    (with-data* ((company-data (remote 'company-data company-format (url `(aia / compagnie / { ,(value company-id) })))))
      (vert* (comp (obj* 'comp-data company-format 
                      ((name name (gui-input 'nome (const "Nome")))
                       (address address (replica 'indirizzi company-address-format (gui-input 'indirizzo (const "Indirizzo")))))
                      (vert name address)))
           ((gui-button 'invio (const "Invio") :click (put-company company-id (payload comp))))))))

(defun modify-company (company-id)
  (with-doc "La sezione in cui l'utente pu&ograve; modificare i dati di una compagnia esistente"
    (company-modification-form company-id)
         ;; (static2 :company-modification-error nil company-modification-error)
         ;; (static2 :company-modification-success nil company-modification-success)
         ))

(element company-list 
  (with-doc "Vista di tutte le compagnie assicurative registrate."
    (with-data* ((company-data (remote 'dati-compagnie company-format (url `(aia / compagnie)))))
      (tabular 'compagnie company-data (company-row)
        ;; ('seleziona (checkbox 'seleziona))
        ('nome (label (attr company-row 'testo)))
        ('indirizzi (label (attr company-row 'indirizzi)))
        ('dettagli (gui-button 'dettagli (const "Dettagli") :click (target (url `(gestione-compagnie / compagnie / { ,(value (filter (prop 'id-notizia) company-row)) })))))))))


(defun company-details (company-id)
  (with-doc "La sezione con i dettagli di una compagnia"
    (with-data* ((company-data (remote 'company-data company-format (url `(aia / compagnie / { ,(value company-id) })))))
      (vert (label (cat (const "Compagnia id:") company-id))
            (label (attr company-data 'nome))
            (label (attr company-data 'indirizzi))
            (gui-button 'elimina (const "Elimina") :click (delete-company company-id))
            (gui-button 'modifica (const "Modifica") :click (target (url `(gestione-compagnie / modifica-compagnia ? ,(value company-id)))))))))

(element company-section
  (with-doc "La sezione di gestione delle compagnie assicurative. L'utente pu&ograve; aggiungere, modificare o eliminare dati anagrafici relativi a una compagnia" 
    (alt company-list
         (dynamic2 compagnia (company-details compagnia))
         (static2 :crea-compagnia nil create-company)
         (static2 :modifica-compagnia (company) (modify-company company)))))

