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
    (concat* (response (http-post* (url `(aia / indicatori)) payload))
             ((fork (+equal+ response (const 201))
                    (show-modal (modal 'successo (const "Errore nella specifica dell'indicatore")))
                    (show-modal (modal 'errore (const "Indicatore creato con successo"))))))))
(defun put-indicator-code (indicator-id payload)
  (with-doc* "Effettua l'upload del codice di un indicatore, verificandone la corretta acquisizione dal server"
    (concat* (response (http-put* (url `(aia / indicatori / { ,(value indicator-id) })) payload))
             ((fork (+equal+ response (const 200))
                    (show-modal (modal 'successo (const "Errore nella specifica dell'indicatore")))
                    (show-modal (modal 'errore (const "Indicatore modificato con successo"))))))))

;; (defun post-indicator-parameters (payload)
;;   (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
;;     (concat* (response (http-post* (url `(aia / indicatori)) payload))
;;              ((fork (+equal+ response (const 201))
;;                     (target (url `(indicator-creation-success)))
;;                     (target (url `(indicator-creation-error))))))))

(defun put-indicator-parameters (indicator-id payload)
  (with-doc* "Effettua l'upload dei parametri di un indicatore, verificandone la corretta acquisizione dal server"
    (concat* (response (http-put* (url `(aia / indicatori / { ,(value indicator-id) } / parametri)) payload))
             ((fork (+equal+ response (const 200))
                    (show-modal (modal 'successo (const "Errore nella specifica dei parametri dell'indicatore")))
                    (show-modal (modal 'errore (const "Parametri dell'indicatore modificati con successo"))))))))

(defun delete-indicator (indicator-id)
  (with-doc* "Effettua la cancellazione dell'indicatore identificato dall'identificativo fornito"
    (concat* (response (http-delete* (url `(aia / indicatori / { ,(value indicator-id) }))))
             ((fork (+equal+ response (const 200))
                    (show-modal (modal 'successo (const "Errore nella cancellazione dell'indicatore")))
                    (show-modal (modal 'errore (const "Indicatore cancellato con successo"))))))))

(element indicator-creation-form
  (with-doc "Il form di inserimento del codice di un nuovo indicatore"
    (vert* (ind (obj* 'ind-data indicator-format 
                      ((code code (gui-textarea 'codice-indicatore (const "Codice indicatore")))
                       (start-date start-date (gui-input 'data-inizio (const "Data inizio validit&agrave;"))))
                      (vert code start-date)))
           ((gui-button 'invio (const "Invio") :click (post-indicator-code (payload ind)))))))

;; (element indicator-creation-error 
;;   (with-description "Pagina visualizzata in presenza di errori nella creazione di un nuovo indicatore"
;;     (vert (label (const "Errore nella specifica dell'indicatore"))
;;           (gui-button 'indietro (const "Indietro") :click (target (url `(gestione-indicatori)))))))

;; (element indicator-creation-success 
;;   (with-description "Pagina visualizzata in caso di successo nella creazione di un nuovo indicatore"
;;     (vert (label (const "Indicatore creato con successo"))
;;           (button* (const "Indietro") :click (target (url `(gestione-indicatori)))))))

(element create-indicator 
  (with-description "La sezione in cui l'utente pu&ograve; specificare i dati di un nuovo indicatore"
    indicator-creation-form
    ;; (static2 :indicator-creation-error nil indicator-creation-error)
    ;; (static2 :indicator-creation-success nil indicator-creation-success)
    ))

;; (element indicator-code-modification-error 
;;   (with-description "Pagina visualizzata in presenza di errori nella modifica del codice di un indicatore"
;;     (vert (label (const "Errore nella specifica dell'indicatore"))
;;           (button* (const "Indietro") :click (target (url `(gestione-indicatori)))))))

;; (element indicator-code-modification-success 
;;   (with-description "Pagina visualizzata in caso di successo nella modifica del codice di un indicatore"
;;     (vert (label (const "Indicatore modificato con successo"))
;;           (button* (const "Indietro") :click (target (url `(gestione-indicatori)))))))


(defun indicator-code-modification-form (indicator-id)
  (with-doc "Il form di modifica del codice di un indicatore esistente, inizializzato con il codice dell'indicatore da modificare"
    (with-data* ((indicator-data (remote 'indicator-data indicator-format (url `(aia / indicatori / { ,(value indicator-id) })))))
      (vert* (ind (obj* 'ind-data indicator-format 
                      ((code code (gui-textarea 'codice-indicatore (const "Codice indicatore") :init (attr indicator-data 'code)))
                       (start-date start-date (gui-input 'data-inizio (const "Data inizio validit&agrave;") :init (attr indicator-data 'start-date))))
                      (vert code start-date)))
           ((gui-button 'invio (const "Invio") :click (put-indicator-code indicator-id (payload ind))))))))

;; (element indicator-parameters-modification-error 
;;   (with-description "Pagina visualizzata in presenza di errori nella modifica dei parametri di un indicatore"
;;     (vert (label (const "Errore nella specifica dei parametri dell'indicatore"))
;;           (button* (const "Indietro") :click (target (url `(gestione-indicatori)))))))

;; (element indicator-parameters-modification-success 
;;   (with-description "Pagina visualizzata in caso di successo nella modifica dei parametri di un indicatore"
;;     (vert (label (const "Parametri dell'indicatore modificati con successo"))
;;           (button* (const "Indietro") :click (target (url `(gestione-indicatori)))))))

(defun indicator-parameters-modification-form (indicator-id)
  (with-doc "Il form di modifica dei parametri di un indicatore esistente, inizializzato con i valori dei parametri dell'indicatore da modificare"
    (with-data* ((indicator-parameters-data (remote 'indicator-parameters-data indicator-parameter-array-format (url `(aia / indicatori / { ,(value indicator-id) }  / parametri)))))
      (vert* (par-table (tabular 'parametri  parameter-format (par-row) 
                    ('parametro (gui-input 'parametro (attr par-row 'name) :init  (attr par-row 'value)))))
             ((gui-button 'invio (const "Invio") :click (put-indicator-parameters indicator-id (payload par-table))))))))

(defun modify-indicator-code (indicator-id)
  (with-description "La sezione in cui l'utente pu&ograve; modificare i dati di un indicatore esistente"
    (indicator-code-modification-form indicator-id)
    ;; (static2 :indicator-code-modification-error nil indicator-code-modification-error)
    ;; (static2 :indicator-code-modification-success nil indicator-code-modification-success)
    ))

(defun modify-indicator-parameters (indicator-id)
  (with-description "La sezione in cui l'utente pu&ograve; modificare i parametri di un indicatore esistente"
    (indicator-parameters-modification-form indicator-id)
    ;; (static2 :indicator-modification-error nil indicator-parameters-modification-error)
    ;; (static2 :indicator-modification-success nil indicator-parameters-modification-success)
    ))

(element indicator-list 
  (with-doc "Vista di tutti gli indicatori registrati."
    (with-data* ((indicator-data (remote 'indicator-data indicator-format (url `(aia / indicatori)))))
      (tabular 'indicatori indicator-data (ind-row)
        ;; ('seleziona (checkbox 'seleziona))
        ('nome (label (attr ind-row 'nome)))
        ('codice (label (attr ind-row 'codice)))
        ('data-inizio (label (attr ind-row 'data-inizio)))
        ('dettagli (gui-button 'dettagli (const "Dettagli") :click (target (url `(gestione-indicatori / indicatori / { ,(value (filter (prop 'id-indicatore) ind-row)) })))))))))

(defun indicator-details (indicator-id)
  (with-description "La sezione con i dettagli di una indicatore"
    (with-data* ((indicator-data (remote 'indicator-data indicator-format (url `(aia / indicatori / { ,(value indicator-id) })))))
      (vert (label (cat (const "Indicatore id:") indicator-id))
            (label (attr indicator-data 'code))
            (label (attr indicator-data 'start-date))
            (gui-button 'elimina (const "Elimina") :click (delete-indicator indicator-id))
            (gui-button 'modifica (const "Modifica codice") :click (target (url `(gestione-indicatori / modifica-codice-indicatore ? ,(value indicator-id)))))
            (gui-button 'modifica-parametri (const "Modifica parametri") :click (target (url `(gestione-indicatori / modifica-parametri-indicatore ? ,(value indicator-id)))))))))

(element indicator-section
  (with-doc "La sezione di gestione degli indicatori. L'utente pu&ograve; aggiungere, modificare o eliminare indicatori, nonché specificarne i suoi parametri" 
    (alt indicator-list
         (dynamic2 indicatore (indicator-details indicatore))
         (static2 :crea-indicatore nil create-indicator)
         (static2 :modifica-codice-indicatore (indicator) (modify-indicator-code indicator))
         (static2 :modifica-parametri-indicatore (indicator) (modify-indicator-parameters indicator)))))

