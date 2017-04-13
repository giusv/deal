;;; News section 
(defun post-news (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / notizie)) payload))
             ((fork (+equal+ response (const 201))
                    (show-modal (modal 'successo (const "Notizia creata con successo")))
                    (show-modal (modal 'errore (const "Errore nella specifica della notizia"))))))))
(defun put-news (news-id payload)
  (with-doc* "Effettua l'upload dei dati di una notizia, verificandone la corretta acquisizione dal server"
    (concat* (response (http-put* (url `(aia / notizie / { ,(value news-id) })) payload))
             ((fork (+equal+ response (const 200))
                    (show-modal (modal 'successo (const "Notizia modificata con successo")))
                    (show-modal (modal 'errore (const "Errore nella modifica della notizia"))))))))

(defun delete-news (news-id)
  (with-doc* "Effettua la cancellazione dei dati della notizia identificata dall'identificativo fornito"
    (concat* (response (http-delete* (url `(aia / notizie / { ,(value news-id) }))))
             ((fork (+equal+ response (const 200))
                    (show-modal (modal 'successo (const "Notizia cancellata con successo")))
                    (show-modal (modal 'errore (const "Errore nella cancellazione della notizia"))))))))

(element news-creation-form
  (with-doc "Il form di inserimento dei dati di una nuova notizia"
    (vert* (news (obj* 'news-data news-format 
                      ((text text (gui-textarea 'testo (const "Testo notizia")))
                       (start-date start-date (gui-input 'data-inizio (const "Data inizio validit&agrave;")))
                       (end-date end-date (gui-input 'data-fine (const "Data fine validit&agrave;")))
                       (subscribers subscribers (replica 'sottoscrittori subscriber-format (gui-input 'sottoscrittore (const "Sottoscrittore")))))
                      (vert text start-date end-date subscribers)))
           ((gui-button 'invio (const "Invio") :click (post-news (payload news)))))))

;; (element news-creation-error 
;;   (with-doc "Pagina visualizzata in presenza di errori nella creazione di una nuova notizia"
;;     (vert (label (const "Errore nel caricamento della notizia"))
;;           (gui-button ' (const "Indietro") :click (target (url `(gestione-notizie)))))))

;; (element news-creation-success 
;;   (with-doc "Pagina visualizzata in caso di successo nella creazione di una nuova notizia"
;;     (vert (label (const ))
;;           (gui-button ' (const "Indietro") :click (target (url `(gestione-notizie)))))))

(element create-news 
  (with-doc "La sezione in cui l'utente pu&ograve; specificare i dati di una nuova notizia"
    news-creation-form
         ;; (static2 :news-creation-error nil news-creation-error)
         ;; (static2 :news-creation-success nil news-creation-success)
         ))

;; (element news-modification-error 
;;   (with-doc "Pagina visualizzata in presenza di errori nella modifica di una notizia"
;;     (vert (label (const "Errore nella specifica della notizia"))
;;           (gui-button ' (const "Indietro") :click (target (url `(gestione-notizie)))))))

;; (element news-modification-success 
;;   (with-doc "Pagina visualizzata in caso di successo nella modifica di una notizia"
;;     (vert (label (const "Notizia modificata con successo"))
;;           (gui-button ' (const "Indietro") :click (target (url `(gestione-notizie)))))))

(defun news-modification-form (news-id)
  (with-doc "Il form di modifica di una notizia esistente, inizializzato con i dati della notizia da modificare"
    (with-data* ((news-data (remote 'news-data news-format (url `(aia / notizie / { ,(value news-id) })))))
      (vert* (news (obj* 'news-data news-format
                         ((text text (gui-textarea 'testo (const "Testo notizia") :init (attr news-data 'testo)))
                          (start-date end-date (gui-input 'data-inizio (const "Data inizio validit&agrave;") :init (attr news-data 'data-inizio)))
                          (end-date end-date (gui-input 'data-fine (const "Data fine validit&agrave;") :init (attr news-data 'data-fine))))
                         (vert text start-date end-date)))
             ((gui-button 'invio (const "Invio") :click (put-news news-id (payload news))))))))


(defun modify-news (news-id)
  (with-doc "La sezione in cui l'utente pu&ograve; modificare i dati di una notizia esistente"
    (news-modification-form news-id)
         ;; (static2 :news-modification-error nil news-modification-error)
         ;; (static2 :news-modification-success nil news-modification-success)
         ))

(element news-list 
  (with-doc "Vista di tutti le notizie registrate"
    (with-data* ((news-data (remote 'dati-notizie news-format (url `(aia / notizie)))))
      (tabular 'notizie news-data (news-row)
        ;; ('seleziona (checkbox 'seleziona))
        ('testo (label (attr news-row 'testo)))
        ('data-inizio (label (attr news-row 'data-inizio)))
        ('data-fine (label (attr news-row 'data-fine)))
        ('dettagli (gui-button 'dettagli (const "Dettagli") :click (target (url `(gestione-notizie / notizie / { ,(value (filter (prop 'id-notizia) news-row)) })))))))))


(defun news-details (news-id)
  (with-doc "La sezione con i dettagli di una notizia"
    (with-data* ((news-data (remote 'news-data news-format (url `(aia / notizie / { ,(value news-id) })))))
      (vert (label (cat (const "Notizia id:") news-id))
            (label (attr news-data 'testo))
            (label (attr news-data 'data-inizio))
            (label (attr news-data 'data-fine))
            (label (attr news-data 'sottoscrittori))
            (gui-button 'elimina (const "Elimina") :click (delete-news news-id))
            (gui-button 'modifica (const "Modifica") :click (target (url `(gestione-notizie / modifica-notizia 
                                                                              ? news = { ,(value news-id) }))))))))

(element news-section
  (with-doc "La sezione di gestione delle notizie da fornire alle compagnie assicurative tramite il portale. L'utente pu&ograve; aggiungere, modificare o eliminare i dati relativi a una notizia, nonché i destinatari della stessa" 
    (alt news-list
         (dynamic2 news (news-details news))
         (static2 :create-news nil create-news)
         (static2 :modifica-notizia (news) (modify-news news)))))

