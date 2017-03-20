;;; News section 
(defun post-news (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / news)) payload))
             ((fork (+equal+ response (const 201))
                    (target (url `(news-creation-success)))
                    (target (url `(news-creation-error))))))))
(defun put-news (news-id payload)
  (with-doc* "Effettua l'upload dei dati di una notizia, verificandone la corretta acquisizione dal server"
    (concat* (response (http-put* (url `(aia / news / { ,(value news-id) })) payload))
             ((fork (+equal+ response (const 200))
                    (target (url `(news-modification-success)))
                    (target (url `(news-modification-error))))))))

(defun delete-news (news-id)
  (with-doc* "Effettua la cancellazione dei dati della notizia identificata dall'identificativo fornito"
    (concat* (response (http-delete* (url `(aia / news / { ,(value news-id) }))))
             ((fork (+equal+ response (const 200))
                    (target (url `(news-deletion-success)))
                    (target (url `(news-deletion-error))))))))

(element news-creation-form
  (with-doc "Il form di inserimento dei dati di una nuova notizia"
    (vert* (news (obj* 'news-data news-format 
                      ((text text (textarea* (const "Testo notizia")))
                       (start-date start-date (input* (const "Data inizio validità")))
                       (end-date end-date (input* (const "Data fine validità")))
                       (subscribers subscribers (arr 'subscribers-data subscriber-format (const 1) (const 4) (input* (const "Sottoscrittore")))))
                      (vert text start-date end-date subscribers)))
           ((button* (const "Invio") :click (post-news (payload news)))))))

(element news-creation-error 
  (with-doc "Pagina visualizzata in presenza di errori nella creazione di una nuova notizia"
    (vert (label (const "Errore nel caricamento della notizia"))
          (button* (const "Indietro") :click (target (url `(news-management)))))))

(element news-creation-success 
  (with-doc "Pagina visualizzata in caso di successo nella creazione di una nuova notizia"
    (vert (label (const "Notizia creata con successo"))
          (button* (const "Indietro") :click (target (url `(news-management)))))))

(element create-news 
  (with-doc "La sezione in cui l'utente può specificare i dati di una nuova notizia"
    (alt news-creation-form
         (static2 :news-creation-error nil news-creation-error)
         (static2 :news-creation-success nil news-creation-success))))

(element news-modification-error 
  (with-doc "Pagina visualizzata in presenza di errori nella modifica di una notizia"
    (vert (label (const "Errore nella specifica della notizia"))
          (button* (const "Indietro") :click (target (url `(news-management)))))))

(element news-modification-success 
  (with-doc "Pagina visualizzata in caso di successo nella modifica di una notizia"
    (vert (label (const "Notizia modificata con successo"))
          (button* (const "Indietro") :click (target (url `(news-management)))))))
;; (element news--form
;;   (with-doc "Il form di inserimento dei dati di una nuova notizia"
;;     (vert* (news (obj* 'news-data news-format 
;;                       ((text text (textarea* (const "Testo notizia")))
;;                        (start-date start-date (input* (const "Data inizio validità")))
;;                        (end-date end-date (input* (const "Data fine validità")))
;;                        ;; (subscribers subscribers (arr 'subscribers-data subscriber-format (const 1) (const 4) (input* (const "Sottoscrittore"))))
;;                        )
;;                       (vert text start-date end-date )))
;;            ((button* (const "Invio") :click (post-news (payload news)))))))

(defun news-modification-form (news-id)
  (with-doc "Il form di modifica di una notizia esistente, inizializzato con i dati della notizia da modificare"
    (with-data* ((news-data (remote 'news-data news-format (url `(aia / news / { ,(value news-id) })))))
      (vert* (news (obj* 'news-data news-format
                         ((text text (textarea* (const "Testo notizia") :init (attr news-data 'text)))
                          (start-date end-date (input* (const "Data inizio validità") :init (attr news-data 'start-date)))
                          (end-date end-date (input* (const "Data fine validità") :init (attr news-data 'end-date))))
                         (vert text start-date end-date)))
             ((button* (const "Invio") :click (put-news news-id (payload news))))))))


(defun modify-news (news-id)
  (with-doc "La sezione in cui l'utente può modificare i dati di una notizia esistente"
    (alt (news-modification-form news-id)
         (static2 :news-modification-error nil news-modification-error)
         (static2 :news-modification-success nil news-modification-success))))

(element news-list 
  (with-doc "Vista di tutte le notizie registrate."
    (table* news-format
        ('testo text (label it)))))


(defun news-details (news-id)
  (with-doc "La sezione con i dettagli di una notizia"
    (with-data* ((news-data (remote 'news-data news-format (url `(aia / news / { ,(value news-id) })))))
      (vert (label (cat (const "Notizia id:") news-id))
            (label (attr news-data 'text))
            (label (attr news-data 'start-date))
            (label (attr news-data 'end-date))
            (label (attr news-data 'subscribers))
            (button* (const "Elimina") :click (delete-news news-id))
            (button* (const "Modifica") :click (target (url `(news-management / modify-news ? ,(value news-id)))))))))

(element news-section
  (with-doc "La sezione di gestione delle notizie da fornire alle compagnie assicurative tramite il portale. L'utente può aggiungere, modificare o eliminare i dati relativi a una notizia, nonché i destinatari della stessa" 
    (alt news-list
         (dynamic2 news (news-details news))
         (static2 :create-news nil create-news)
         (static2 :modify-news (news) (modify-news news)))))

