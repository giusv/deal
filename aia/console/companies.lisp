;;; Company section 
;; (crud company-format (url `(aia))
;;       (vert (label (cat (const "Compagnia id:") company-id))
;;             (label (attr company-data 'name))
;;             (label (attr company-data 'address))
;;             (button* (const "Elimina") :click (delete-company company-id))
;;             (button* (const "Modifica") :click (target (url `(company-management / modify-company ? ,(value company-id))))))

;;       )
(defun post-company (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / companies)) payload))
             ((fork (+equal+ response (const 201))
                    (target (url `(company-creation-success)))
                    (target (url `(company-creation-error))))))))
(defun put-company (company-id payload)
  (with-doc* "Effettua l'upload dei dati di una compagnia, verificandone la corretta acquisizione dal server"
    (concat* (response (http-put* (url `(aia / companies / { ,(value company-id) })) payload))
             ((fork (+equal+ response (const 200))
                    (target (url `(company-modification-success)))
                    (target (url `(company-modification-error))))))))

(defun delete-company (company-id)
  (with-doc* "Effettua la cancellazione dei dati della compagnia identificata dall'identificativo fornito"
    (concat* (response (http-delete* (url `(aia / companies / { ,(value company-id) }))))
             ((fork (+equal+ response (const 200))
                    (target (url `(company-deletion-success)))
                    (target (url `(company-deletion-error))))))))

(element company-creation-form
  (with-doc "Il form di inserimento dei dati di una nuova compagnia"
    (vert* (comp (obj* 'comp-data company-format 
                      ((name name (input* (const "Nome")))
                       (address address (input* (const "Indirizzo"))))
                      (vert name address)))
           ((button* (const "Invio") :click (post-company (payload comp)))))))

(element company-creation-error 
  (with-doc "Pagina visualizzata in presenza di errori nella creazione di una nuova compagnia"
    (vert (label (const "Errore nella specifica della compagnia"))
          (button* (const "Indietro") :click (target (url `(company-management)))))))

(element company-creation-success 
  (with-doc "Pagina visualizzata in caso di successo nella creazione di una nuova compagnia"
    (vert (label (const "Compagnia creata con successo"))
          (button* (const "Indietro") :click (target (url `(company-management)))))))

(element create-company 
  (with-doc "La sezione in cui l'utente può specificare i dati di una nuova compagnia"
    (alt company-creation-form
         (static2 :company-creation-error nil company-creation-error)
         (static2 :company-creation-success nil company-creation-success))))

(element company-modification-error 
  (with-doc "Pagina visualizzata in presenza di errori nella modifica di una compagnia"
    (vert (label (const "Errore nella specifica della compagnia"))
          (button* (const "Indietro") :click (target (url `(company-management)))))))

(element company-modification-success 
  (with-doc "Pagina visualizzata in caso di successo nella modifica di una compagnia"
    (vert (label (const "Compagnia modificata con successo"))
          (button* (const "Indietro") :click (target (url `(company-management)))))))

(defun company-modification-form (company-id)
  (with-doc "Il form di modifica di una compagnia esistente, inizializzato con i dati della compagnia da modificare"
    (with-data* ((company-data (remote 'company-data company-format (url `(aia / companies / { ,(value company-id) })))))
      (vert* (comp (obj* 'comp-data company-format 
                      ((name name (input* (const "Nome") :init (attr company-data 'name)))
                       (address address (input* (const "Indirizzo") :init (attr company-data 'address))))
                      (vert name address)))
           ((button* (const "Invio") :click (put-company company-id (payload comp))))))))

(defun modify-company (company-id)
  (with-doc "La sezione in cui l'utente può modificare i dati di una compagnia esistente"
    (alt (company-modification-form company-id)
         (static2 :company-modification-error nil company-modification-error)
         (static2 :company-modification-success nil company-modification-success))))

(element company-list 
  (with-doc "Vista di tutte le compagnie assicurative registrate."
    (tabular* company-format
        ('nome name (label it)))))


(defun company-details (company-id)
  (with-doc "La sezione con i dettagli di una compagnia"
    (with-data* ((company-data (remote 'company-data company-format (url `(aia / companies / { ,(value company-id) })))))
      (vert (label (cat (const "Compagnia id:") company-id))
            (label (attr company-data 'name))
            (label (attr company-data 'address))
            (button* (const "Elimina") :click (delete-company company-id))
            (button* (const "Modifica") :click (target (url `(company-management / modify-company ? ,(value company-id)))))))))

(element company-section
  (with-doc "La sezione di gestione delle compagnie assicurative. L'utente può aggiungere, modificare o eliminare dati anagrafici relativi a una compagnia" 
    (alt company-list
         (dynamic2 company (company-details company))
         (static2 :create-company nil create-company)
         (static2 :modify-company (company) (modify-company company)))))

