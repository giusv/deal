(defun accident-details (id)
  (with-doc "La pagina che riporta i dettagli di un singolo sinistro"
    (with-data* ((accident (remote 'accident-data accident-format (url `(aia / sinistri / { ,(value id) })))))
      (vert (description 'dettagli-sinistro accident (row)
                         ('id (label (attr row 'id)))
                         ('data-accadimento (label (attr row 'data-accadimento)))
                         ('data-denuncia (label (attr row 'data-denuncia)))
                         ('data-definizione (label (attr row 'data-definizione)))
                         ('stato (label (attr row 'stato)))
                         ('luogo (label (attr row 'luogo)))
                         ('ruolo (label (attr row 'ruolo)))
                         ('intervento (label (attr row 'intervento)))
                         ('danni (label (attr row 'danni)))
                         ('lesioni (label (attr row 'lesioni)))
                         ('decessi (label (attr row 'decessi)))
                         ('persone 
                          (tabular 'dettagli-persona (filter (comp (prop 'persone) (elem)) row) (pers-row)
                            ('nome (label (attr pers-row 'nome)))
                            ('cognome (label (attr pers-row 'cognome)))
                            ('data-di-nascita (label (attr pers-row 'data-nascita)))
                            ('luogo-di-nascita (label (attr pers-row 'luogo-nascita)))
                            ('codice-fiscale (label (attr pers-row 'codice-fiscale)))
                            ('ruoli (listing 'ruoli (filter (comp (prop 'ruoli) (elem)) pers-row) (role-row)
                                      (label role-row)))))
                         ('veicoli 
                          (tabular 'dettagli-veicolo (filter (comp (prop 'veicoli) (elem)) row) (vehic-row)
                            ('targa (label (attr vehic-row 'targa)))
                            ('telaio (label (attr vehic-row 'telaio)))
                            ('conducente (label (attr vehic-row 'conducente)))
                            ('proprietario (label (attr vehic-row 'proprietario)))
                            ('contraente (label (attr vehic-row 'contraente))))))))))

(defparameter company-id 
  (login-parameter 'company-id))

(element navbar 
  (with-doc "La barra di navigazione principale"
    (navbar 'barra-navigazione
            (anchor 'ricerca-veicolo (const "Ricerca per veicolo") :click (target (url `(home / ricerca-per-targa))))
            (anchor'ricerca-persona (const "Ricerca per persona") :click (target (url `(home / ricerca-per-persona)))))))

(element news-table
  (with-doc "La lista delle notizie destinate alla compagnia"
    (with-data* ((results (remote 'news-data news-format (url `(aia / compagnie / { ,(value company-id) } / news)))))
      (tabular 'notizie results (news-row)
        ('testo (label (filter (prop 'text) news-row)))
        ('sottoscrittori (tabular 'sottoscrittori (filter (comp (prop 'subscribers) (elem)) news-row) (subscriber-row)
                           ('sottoscrittore (label (filter (this) subscriber-row)))
                           ('test (label (filter (prop 'text) news-row)))))))))

(element hs-main
  (alt (with-doc "La sezione principale da cui l'utente può scegliere la funzione desiderata e visualizzarla nella stessa area di schermo"
         (hub-spoke ((ricerca-per-targa "Ricerca per targa" plate-section)
                     (ricerca-per-persona "Ricerca per persona" person-section)
                     (piattaforma "Piattaforma di scambio" document-section)
                     ;; (data-quality "Data quality" quality-section)
                     )
                    home
                    (with-doc "Il menu principale di scelta"
                      (horz ricerca-per-targa ricerca-per-persona))))
       (static2 :sinistri nil (alt nil 
                                   (dynamic2 id-sinistro (accident-details id-sinistro))))))

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
                          )))
         (static2 :errore-login nil 
                  (vert (label (const "Errore nei dati di login") )
                        (gui-button 'indietro (const "Indietro") :click (target (url `(login)))))))))


