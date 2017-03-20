;;; Indicator section 
;; (crud indicator-format (url `(aia))
;;       (vert (label (cat (const "Indicatore id:") indicator-id))
;;             (label (attr indicator-data 'name))
;;             (label (attr indicator-data 'address))
;;             (button* (const "Elimina") :click (delete-indicator indicator-id))
;;             (button* (const "Modifica") :click (target (url `(indicator-management / modify-indicator ? ,(value indicator-id))))))

;;       )

(defun post-indicator-code (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / indicators)) payload))
             ((fork (+equal+ response (const 201))
                    (target (url `(indicator-creation-success)))
                    (target (url `(indicator-creation-error))))))))
(defun put-indicator-code (indicator-id payload)
  (with-doc* "Effettua l'upload del codice di un indicatore, verificandone la corretta acquisizione dal server"
    (concat* (response (http-put* (url `(aia / indicators / { ,(value indicator-id) })) payload))
             ((fork (+equal+ response (const 200))
                    (target (url `(indicator-code-modification-success)))
                    (target (url `(indicator-code-modification-error))))))))

(defun post-indicator-parameters (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / indicators)) payload))
             ((fork (+equal+ response (const 201))
                    (target (url `(indicator-creation-success)))
                    (target (url `(indicator-creation-error))))))))

(defun put-indicator-parameters (indicator-id payload)
  (with-doc* "Effettua l'upload del codice di un indicatore, verificandone la corretta acquisizione dal server"
    (concat* (response (http-put* (url `(aia / indicators / { ,(value indicator-id) })) payload))
             ((fork (+equal+ response (const 200))
                    (target (url `(indicator-parameters-modification-success)))
                    (target (url `(indicator-parameters-modification-error))))))))

(defun delete-indicator (indicator-id)
  (with-doc* "Effettua la cancellazione dell'indicatore identificato dall'identificativo fornito"
    (concat* (response (http-delete* (url `(aia / indicators / { ,(value indicator-id) }))))
             ((fork (+equal+ response (const 200))
                    (target (url `(indicator-deletion-success)))
                    (target (url `(indicator-deletion-error))))))))

(element indicator-creation-form
  (with-doc "Il form di inserimento del codice di un nuovo indicatore"
    (vert* (ind (obj* 'ind-data indicator-format 
                      ((code code (textarea* (const "Codice indicatore")))
                       (start-date start-date (input* (const "Data inizio validità"))))
                      (vert code start-date)))
           ((button* (const "Invio") :click (post-indicator-code (payload ind)))))))

(element indicator-creation-error 
  (with-doc "Pagina visualizzata in presenza di errori nella creazione di un nuovo indicatore"
    (vert (label (const "Errore nella specifica dell'indicatore"))
          (button* (const "Indietro") :click (target (url `(indicator-management)))))))

(element indicator-creation-success 
  (with-doc "Pagina visualizzata in caso di successo nella creazione di un nuovo indicatore"
    (vert (label (const "Indicatore creato con successo"))
          (button* (const "Indietro") :click (target (url `(indicator-management)))))))

(element create-indicator 
  (with-doc "La sezione in cui l'utente può specificare i dati di un nuovo indicatore"
    (alt indicator-creation-form
         (static2 :indicator-creation-error nil indicator-creation-error)
         (static2 :indicator-creation-success nil indicator-creation-success))))

(element indicator-code-modification-error 
  (with-doc "Pagina visualizzata in presenza di errori nella modifica del codice di un indicatore"
    (vert (label (const "Errore nella specifica dell'indicatore"))
          (button* (const "Indietro") :click (target (url `(indicator-management)))))))

(element indicator-code-modification-success 
  (with-doc "Pagina visualizzata in caso di successo nella modifica del codice di un indicatore"
    (vert (label (const "Indicatore modificato con successo"))
          (button* (const "Indietro") :click (target (url `(indicator-management)))))))

(defun indicator-code-modification-form (indicator-id)
  (with-doc "Il form di modifica del codice di un indicatore esistente, inizializzato con il codice dell'indicatore da modificare"
    (with-data* ((indicator-data (remote 'indicator-data indicator-format (url `(aia / indicators / { ,(value indicator-id) })))))
      (vert* (ind (obj* 'ind-data indicator-format 
                      ((code code (textarea* (const "Codice indicatore") :init (attr indicator-data 'code)))
                       (start-date start-date (input* (const "Data inizio validità") :init (attr indicator-data 'start-date))))
                      (vert code start-date)))
           ((button* (const "Invio") :click (put-indicator-code indicator-id (payload ind))))))))

(element indicator-parameters-modification-error 
  (with-doc "Pagina visualizzata in presenza di errori nella modifica dei parametri di un indicatore"
    (vert (label (const "Errore nella specifica dei parametri dell'indicatore"))
          (button* (const "Indietro") :click (target (url `(indicator-management)))))))

(element indicator-parameters-modification-success 
  (with-doc "Pagina visualizzata in caso di successo nella modifica dei parametri di un indicatore"
    (vert (label (const "Parametri dell'indicatore modificati con successo"))
          (button* (const "Indietro") :click (target (url `(indicator-management)))))))

(defun indicator-parameters-modification-form (indicator-id)
  (with-doc "Il form di modifica del codice di un indicatore esistente, inizializzato con il codice dell'indicatore da modificare"
    (with-data* ((indicator-data (remote 'indicator-data indicator-format (url `(aia / indicators / { ,(value indicator-id) })))))
      (vert* (ind (obj* 'ind-data indicator-format 
                      ((code code (textarea* (const "Codice indicatore") :init (attr indicator-data 'code)))
                       (start-date start-date (input* (const "Data inizio validità") :init (attr indicator-data 'start-date))))
                      (vert code start-date)))
           ((button* (const "Invio") :click (put-indicator-parameters indicator-id (payload ind))))))))

(defun modify-indicator-code (indicator-id)
  (with-doc "La sezione in cui l'utente può modificare i dati di un indicatore esistente"
    (alt (indicator-code-modification-form indicator-id)
         (static2 :indicator-code-modification-error nil indicator-code-modification-error)
         (static2 :indicator-code-modification-success nil indicator-code-modification-success))))

(defun modify-indicator-parameters (indicator-id)
  (with-doc "La sezione in cui l'utente può modificare i parametri di un indicatore esistente"
    (alt (indicator-parameters-modification-form indicator-id)
         (static2 :indicator-modification-error nil indicator-parameters-modification-error)
         (static2 :indicator-modification-success nil indicator-parameters-modification-success))))

(element indicator-list 
  (with-doc "Vista di tutti gli indicatori registrati."
    (tabular* indicator-format
        ('nome name (label it)))))

(defun indicator-details (indicator-id)
  (with-doc "La sezione con i dettagli di una indicatore"
    (with-data* ((indicator-data (remote 'indicator-data indicator-format (url `(aia / indicators / { ,(value indicator-id) })))))
      (vert (label (cat (const "Indicatore id:") indicator-id))
            (label (attr indicator-data 'code))
            (label (attr indicator-data 'start-date))
            (button* (const "Elimina") :click (delete-indicator indicator-id))
            (button* (const "Modifica codice") :click (target (url `(indicator-management / modify-indicator-code ? ,(value indicator-id)))))
            (button* (const "Modifica parametri") :click (target (url `(indicator-management / modify-indicator-parameters ? ,(value indicator-id)))))))))

(element indicator-section
  (with-doc "La sezione di gestione degli indicatori. L'utente può aggiungere, modificare o eliminare indicatori, nonché specificarne i suoi parametri" 
    (alt indicator-list
         (dynamic2 indicator (indicator-details indicator))
         (static2 :create-indicator nil create-indicator)
         (static2 :modify-indicator-code (indicator) (modify-indicator-code indicator))
         (static2 :modify-indicator-parameters (indicator) (modify-indicator-parameters indicator)))))

