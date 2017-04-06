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
        (static2 :ricerca (cognome nome datanasc ragsoc codfisc partiva inizio fine) 
                 (person-search-results cognome nome datanasc ragsoc codfisc partiva inizio fine)))))
