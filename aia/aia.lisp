(element plate-form
  (with-doc "Il form di inserimento dati relativi alla ricerca per targa"
    (vert* (targa (input* (const "Targa")))
           (inizio (input* (const "Data inizio")))
           (fine (input* (const "Data fine")))
           ((button* (value targa);; (const "Invio") 
                     :click (target (url `(home / plate-search-results 
                                                ? targa =  { ,(value targa ) }
                                                & inizio =  { ,(value inizio) }
                                                & fine =  { ,(value fine) }
                                                & pagina =  { ,(const 1) }
                                                ))))))))

(defun plate-search-results (targa inizio fine pagina)
  (with-doc "La pagina di risultati della ricerca per targa"
    (with-data* ((vehicle (remote 'vehicle-data vehicle-generic-format
                                   (url `(aia / veicoli
                                              ? targa =  { ,(value targa) }))))
                 (accidents (remote 'accident-data accident-format 
                                    (url `(aia / sinistri
                                               ? targa =  { ,(value targa) }
                                               & inizio =  { ,(value inizio) }
                                               & fine =  { ,(value fine) }
                                               & pagina =  { ,(value pagina) })))))
      (panel* (label (cat (const "Ricerca per targa") (value targa) (value inizio) (value fine)))  
              (vert (chart* vehicle)
                    (tabular* accidents (acc-row)
                      ('data-accadimento (label (filter (prop 'data-accadimento) acc-row)))
                      ('stato (label (value (filter (prop 'stato) acc-row))))
                      ('luogo (label (value (filter (prop 'luogo) acc-row))))
                      ('ruolo (label (value (filter (prop 'ruolo) acc-row))))
                      ('intervento (label (value (filter (prop 'intervento) acc-row))))
                      ('danni-/-lesioni-/-decessi (label (cat (value (filter (prop 'danni) acc-row)) (const "/")
                                                              (value (filter (prop 'lesioni) acc-row)) (const "/")
                                                              (value (filter (prop 'decessi) acc-row)))))
                      ('dettagli (button* (const "Dettagli") :click (target (url `(home / { ,(value (filter (prop 'id) acc-row)) })))))))))))

(element plate-section
  (with-doc "La sezione di ricerca basata su identificativi relativi a veicoli (targa)"
    (alt plate-form
         (static2 :plate-search-results (targa inizio fine pagina) (plate-search-results targa inizio fine pagina)))))

(element person-form
  (with-doc "Il form di inserimento dati relativi alla ricerca per soggetti"
    (vert* (cognome (input* (const "Cognome")))
           (nome (input* (const "Nome")))
           (datanasc (input* (const "Data di nascita (gg/mm/aaaa)")))
           (ragsoc (input* (const "Ragione sociale")))
           (codfisc (input* (const "Codice fiscale")))
           (partiva (input* (const "Partita iva")))
           (inizio (input* (const "Data inizio")))
           (fine (input* (const "Data fine")))
           ((button* (const "Invio") :click (target (url `(home / person-search-results))))))))

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


(defun person-search-results (cognome nome datanasc ragsoc codfisc partiva inizio fine)
  (with-doc "La pagina di risultati della ricerca per soggetti"
    (with-data* ((results (remote 'person-search-data person-generic-format 
                                  (url `(aia / soggetti 
                                             ? cognome =  { ,(value cognome) }
                                             & nome =  { ,(value nome) }
                                             & ragsoc =  { ,(value ragsoc) }
                                             & codfisc =  { ,(value codfisc) }
                                             & datanasc =  { ,(value datanasc) }
                                             & partiva =  { ,(value partiva ) }
                                             & inizio =  { ,(value inizio) }
                                             & fine =  { ,(value fine) })))))
      (panel* (label (cat (const "Ricerca per persona") (value cognome) (value nome) (value codfisc) (value inizio) (value fine)))  
              (tabular* results (pers-row) 
                ('nome (label (filter (prop 'name) pers-row)))
                ('data (label (filter (prop 'data) pers-row)))
                ('dettagli (button* (const "Dettagli") :click (target (url `(home / { ,(value (filter (prop 'codice-fiscale) pers-row)) }))))))))))


(element person-section
  (with-doc "La sezione di ricerca basata su identificativi relativi a persone fisiche e/o giuridiche"
    (alt person-form
        (static2 :person-search-results (cognome nome datanasc ragsoc codfisc partiva inizio fine) 
                 (person-search-results cognome nome datanasc ragsoc codfisc partiva inizio fine)))))


(element platform-search-form
  (with-doc "Il form di inserimento dati relativi alla ricerca di informazioni presenti sulla piattaforma"
    (vert* (targa (input* (const "Targa")))
           (sinistro (input* (const "Sinistro")))
           (codfisc (input* (const "Codice fiscale")))
           (inizio (input* (const "Data inizio")))
           (fine (input* (const "Data fine")))
           ((button* (value targa) ;; (const "Invio") 
                     :click (target (url `(home / platform-search-results 
                                                ? targa =  { ,(value targa ) }
                                                & sinistro =  { ,(value sinistro) }
                                                & codfisc =  { ,(value codfisc) }
                                                & inizio =  { ,(value inizio) }
                                                & fine =  { ,(value fine) }
                                                & pagina =  { ,(const 1) }))))))))

(defun post-platform-data (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / platform)) payload))
             ((fork (+equal+ response (const 201))
                    (target (url `(home / piattaforma-scambio / platform-upload-success)))
                    (target (url `(indicator-creation-error))))))))

(element platform-upload-form
  (with-doc "Il form di inserimento dati relativi all'invio di informazioni  sulla piattaforma"
    (vert* (pform (obj* 'upload-data platform-upload-format 
                        ((targa veicolo (input* (const "Targa")))
                         (sinistro sinistro (input* (const "Sinistro")))
                         (codfisc persona (input* (const "Codice fiscale"))))
                        (vert targa sinistro codfisc)))
           ((button* (const "Invio") :click (post-platform-data (payload pform)))))))



(defun platform-search-results (targa sinistro codfisc inizio fine pagina)
  (with-doc "La pagina di risultati della ricerca dati sulla piattaforma"
    (with-data* ((results (remote 'platform-search-data platform-search-format 
                                  (url `(aia / platform 
                                             ? targa =  { ,(value targa ) }
                                             & sinistro =  { ,(value sinistro) }
                                             & codfisc =  { ,(value codfisc) }
                                             & inizio =  { ,(value inizio) }
                                             & fine =  { ,(value fine) }
                                             & pagina =  { ,(value pagina) })))))
      (panel* (label (cat (const "Ricerca dati piattaforma") (value targa) (value sinistro) (value codfisc) (value inizio) (value fine)))  
              (tabular* results (pform-row) 
                ('sinistro (label (filter (prop 'sinistro) pform-row)))
                ('veicolo (label (filter (prop 'veicolo) pform-row)))
                ('persona (label (filter (prop 'persona) pform-row)))
                ('file (label (filter (prop 'file) pform-row))))))))

(element platform-search-section
  (with-doc "La sezione di ricerca sulla piattaforma di interscambio dati tra le compagnie"
    (alt platform-search-form
         (static2 :platform-search-results (targa sinistro codfisc inizio fine pagina) 
                  (platform-search-results targa sinistro codfisc inizio fine pagina)))))

(element platform-upload-error 
  (with-description "Pagina visualizzata in presenza di errori nel caricamento dati sulla piattaforma"
    (vert (label (const "Errore nel caricamento dati"))
          (button* (const "Indietro") :click (target (url `(home / piattaforma-scambio)))))))

(element platform-upload-success 
  (with-description "Pagina visualizzata in presenza di successo nel caricamento dati sulla piattaforma"
    (vert (label (const "Dati inviati con successo"))
          (button* (const "Indietro") :click (target (url `(home / piattaforma-scambio)))))))


(element platform-upload-section
  (with-doc "La sezione di invio informazioni alla piattaforma di  interscambio dati tra le compagnie"
    (alt platform-upload-form
         (static2 :platform-upload-success nil platform-upload-success)
         (static2 :platform-upload-error nil platform-upload-error))))

(element platform-section
  (with-doc "La piattaforma di interscambio dati fra le compagnie. L'utente può inviare dati o effettuare una ricerca"
    (hub-spoke ((ricerca-piattaforma "Ricerca informazioni" platform-search-section)
                (invio-piattaforma "Invio dati piattaforma" platform-upload-section))
               :home
               (with-doc "Il menu principale di scelta"
                 (horz ricerca-piattaforma invio-piattaforma)))))

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
                (piattaforma-scambio "Piattaforma di scambio" platform-section))
               :home
               (with-doc "Il menu principale di scelta"
                 (horz ricerca-per-targa ricerca-per-persona)))))

(element website
  (with-doc "L'applicazione web destinata alla visualizzazione dei dati dei sinistri e dei soggetti/veicoli coinvolti, insieme ai relativi indicatori di rischio"
    (alt nil 
        (static2 :login nil  
                 (vert* (userid (input* (const "User id") :init (const "nome.cognome@mail.com")))
                        (passwd (input* (const "Password")))
                        (ok (button* (const "Login") :click (target (url `(home)))))))
        (static2 :home nil 
                 (vert navbar
                       news-table
                       hs-main
                       (dynamic2 accident-id (accident-details accident-id)))))))


