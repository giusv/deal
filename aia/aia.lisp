(element plate-form
  (with-doc "Il form di inserimento dati relativi alla ricerca per targa"
    (vert* (targa (input* (const "Targa")))
           (inizio (input* (const "Data inizio")))
           (fine (input* (const "Data fine")))
           ((button* (const "Invio") 
                     :click (target (url `(home / plate-search-results 
                                                & targa =  { ,(value targa ) }
                                                & inizio =  { ,(value inizio) }
                                                & fine =  { ,(value fine) }))))))))

(defun plate-search-results (targa inizio fine)
  (with-doc "La pagina di risultati della ricerca per targa"
    (with-data* ((vehicle (remote 'vehicle-data vehicle-format
                                  (url `(aia / veicoli
                                             ? targa =  { ,(value targa) }))))
                 (accident (remote 'accident-data accident-format 
                                   (url `(aia / sinistri
                                              ? targa =  { ,(value targa) }
                                              & inizio =  { ,(value inizio) }
                                              & fine =  { ,(value fine) })))))
      (tabular* vehicle
        ('ricorrenze (label (prop 'occurrences)))
        ('indicatori (label (prop 'indicatori)))
        ('dettagli (button* (const "Dettagli") :click (target (url `(home / plate-search-results / sinistri / { ,(value (prop 'id)) })))))))))

(element plate-section
  (with-doc "La sezione di ricerca basata su identificativi relativi a veicoli (targa)"
    (alt plate-form
         (static2 :plate-search-results (targa inizio fine) (plate-search-results targa inizio fine)))))

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
  (with-data* ((results (remote 'accident-data accident-format (url `(aia / sinistri / { ,(value id) })))))
    (tabular* accident-format
      ('id (label (prop 'id)))
      ('data (label (filter (prop 'data) it))))))

(defun person-search-results (cognome nome datanasc ragsoc codfisc partiva inizio fine)
  (with-doc "La pagina di risultati della ricerca per soggetti"
    (with-data* ((results (remote 'person-search-data person-search-format 
                                  (url `(aia / soggetti 
                                             ? cognome =  { ,(value cognome) }
                                             & nome =  { ,(value nome) }
                                             & ragsoc =  { ,(value ragsoc) }
                                             & codfisc =  { ,(value codfisc) }
                                             & partiva =  { ,(value partiva ) }
                                             & inizio =  { ,(value inizio) }
                                             & fine =  { ,(value fine) })))))
      (tabular* person-search-format
        ('nome (label (prop 'name)))
        ('data (label (filter (prop 'data) it)))
        ('dettagli (button* (const "Dettagli") :click (target (url `(home / sinistri / { ,(value (prop 'name)) })))))))))

(element person-section
  (with-doc "La sezione di ricerca basata su identificativi relativi a persone fisiche e/o giuridiche"
    (alt person-form
        (static2 :person-search-results (cognome nome datanasc ragsoc codfisc partiva inizio fine) 
                 (person-search-results cognome nome datanasc ragsoc codfisc partiva inizio fine))
        (dynamic2 id (accident-details id)))))

(defparameter company-id 
  (login-parameter 'company-id))

(element navbar 
  (with-doc "La barra di navigazione principale"
    (navbar* (anchor* (const "Ricerca per veicolo") :click (target (url `(home / search-by-plate))))
             (anchor* (const "Ricerca per persona") :click (target (url `(home / search-by-person)))))))

(element news-table
  (with-doc "La lista delle notizie a destinate alla compagnia"
    (with-data* ((results (remote 'news-data news-format (url `(aia / compagnie / { ,(value company-id) } / news)))))
      (tabular2* results news-row
        ('testo (label (filter (prop 'text) news-row)))
        ('sottoscrittori (tabular2* (filter (comp (prop 'subscribers) (elem)) news-row) subscriber-row
                           ('sottoscrittore (label (filter (this) subscriber-row)))
                           ('test (label (filter (prop 'text) news-row)))))))))

(element hs-main
  (with-doc "La sezione principale da cui l'utente può scegliere la funzione desiderata e visualizzarla nella stessa area di schermo"
    (hub-spoke ((search-by-plate "Ricerca per targa" plate-section)
                (search-by-person "Ricerca per persona" person-section))
               :home
               (with-doc "Il menu principale di scelta"
                 (horz search-by-plate search-by-person)))))

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
                       hs-main)))))


