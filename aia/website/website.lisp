(defun accident-details (id)
  (with-doc "La pagina che riporta i dettagli di un singolo sinistro"
    (with-data* ((accident (remote 'accident-data accident-format (url `(aia / sinistri / { ,(value id) })))))
      (vert (description* accident (row)
              ('id (label (value (filter (prop 'id) row))))
              ('data-accadimento (label (value (filter (prop 'data-accadimento) row))))
              ('data-denuncia (label (value (filter (prop 'data-denuncia) row))))
              ('data-definizione (label (value (filter (prop 'data-definizione) row))))
              ('stato (label (value (filter (prop 'stato) row))))
              ('luogo (label (value (filter (prop 'luogo) row))))
              ('ruolo (label (value (filter (prop 'ruolo) row))))
              ('intervento (label (value (filter (prop 'intervento) row))))
              ('danni (label (value (filter (prop 'danni) row))))
              ('lesioni (label (value (filter (prop 'lesioni) row))))
              ('decessi (label (value (filter (prop 'decessi) row))))
              ('persone 
               (tabular* (filter (comp (prop 'persone) (elem)) row) (pers-row)
                 ('nome (label (value (filter (prop 'nome) pers-row))))
                 ('cognome (label (value (filter (prop 'cognome) pers-row))))
                 ('data-di-nascita (label (value (filter (prop 'data-nascita) pers-row))))
                 ('luogo-di-nascita (label (value (filter (prop 'luogo-nascita) pers-row))))
                 ('codice-fiscale (label (value (filter (prop 'codice-fiscale) pers-row))))
                 ('ruoli (listing* (filter (comp (prop 'ruoli) (elem)) pers-row) (role-row)
                           (label (value (filter (this) role-row)))))))
              ('veicoli 
               (tabular* (filter (comp (prop 'veicoli) (elem)) row) (vehic-row)
                 ('targa (label (value (filter (prop 'targa) vehic-row))))
                 ('telaio (label (value (filter (prop 'telaio) vehic-row))))
                 ('conducente (label (value (filter (prop 'conducente) vehic-row))))
                 ('proprietario (label (value (filter (prop 'proprietario) vehic-row))))
                 ('contraente (label (value (filter (prop 'contraente) vehic-row)))))))))))

(defparameter company-id 
  (login-parameter 'company-id))

(element navbar 
  (with-doc "La barra di navigazione principale"
    (navbar* (anchor* (const "Ricerca per veicolo") :click (target (url `(home / ricerca-per-targa))))
             (anchor* (const "Ricerca per persona") :click (target (url `(home / ricerca-per-persona)))))))

(element news-table
  (with-doc "La lista delle notizie destinate alla compagnia"
    (with-data* ((results (remote 'news-data news-format (url `(aia / compagnie / { ,(value company-id) } / news)))))
      (tabular* results (news-row)
        ('testo (label (filter (prop 'text) news-row)))
        ('sottoscrittori (tabular* (filter (comp (prop 'subscribers) (elem)) news-row) (subscriber-row)
                           ('sottoscrittore (label (filter (this) subscriber-row)))
                           ('test (label (filter (prop 'text) news-row)))))))))

(element hs-main
  (with-doc "La sezione principale da cui l'utente può scegliere la funzione desiderata e visualizzarla nella stessa area di schermo"
    (hub-spoke ((ricerca-per-targa "Ricerca per targa" plate-section)
                (ricerca-per-persona "Ricerca per persona" person-section)
                (piattaforma "Piattaforma di scambio" document-section)
                ;; (data-quality "Data quality" quality-section)
                )
               home
               (with-doc "Il menu principale di scelta"
                 (horz ricerca-per-targa ricerca-per-persona)))))

(defun authenticate-user (userid password)
  (concat* (auth-result (authenticate2 userid password))
           ((fork auth-result
                  (target (url `(home)))
                  (target (url `(errore-login)))))))
(element website
  (with-doc "L'applicazione web destinata alla visualizzazione dei dati dei sinistri e dei soggetti/veicoli coinvolti, insieme ai relativi indicatori di rischio"
    (alt (with-doc "Il form di login"
           (vert* (userid (gui-input 'login-userid (const "User id")))
                  (passwd (gui-input 'login-password (const "Password")))
                  (ok (gui-button 'login-submit (const "Login") :click (authenticate-user (value userid) (value passwd))))))
         (static2 :home nil 
                  (with-description "La pagina iniziale a cui l'utente accede dopo aver effettuato il login."
                    (vert navbar
                          news-table
                          hs-main
                          ;; (dynamic2 id-sinistro (accident-details id-sinistro))
                          )))
         (static2 :errore-login nil 
                  (vert (label (const "Errore nei dati di login") )
                        (button 'indietro (const "Indietro") :click (target (void-url))))))))


