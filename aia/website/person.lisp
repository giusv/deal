(element person-form
  (with-doc "Il form di inserimento dati relativi alla ricerca per soggetti"
    (vert* (cognome (gui-input 'cognome (const "Cognome")))
           (nome (gui-input 'nome (const "Nome")))
           (data-nascita (gui-input 'data-nascita (const "Data di nascita (gg/mm/aaaa)")))
           (ragione-sociale (gui-input 'ragione-sociale (const "Ragione sociale")))
           (codice-fiscale (gui-input 'codice-fiscale (const "Codice fiscale")))
           (partita-iva (gui-input 'partita-iva (const "Partita iva")))
           (data-inizio (gui-input 'data-inizio (const "Data inizio")))
           (data-fine (gui-input 'data-fine (const "Data fine")))
           ((button 'invio (const "Invio") :click (target (url `(home / ricerca-per-persona / ricerca))))))))


(defun person-search-results (cognome nome data-nascita ragione-sociale codice-fiscale partita-iva data-inizio data-fine)
  (with-doc "La pagina di risultati della ricerca per soggetti"
    (with-data* ((results (remote 'person-search-data person-generic-format 
                                  (url `(aia / soggetti 
                                             ? cognome =  { ,(value cognome) }
                                             & nome =  { ,(value nome) }
                                             & ragione-sociale =  { ,(value ragione-sociale) }
                                             & codice-fiscale =  { ,(value codice-fiscale) }
                                             & data-nascita =  { ,(value data-nascita) }
                                             & partita-iva =  { ,(value partita-iva ) }
                                             & data-inizio =  { ,(value data-inizio) }
                                             & data-fine =  { ,(value data-fine) })))))
      (panel 'risultati-ricerca-per-persona (label (cat (const "Ricerca per persona") (value cognome) (value nome) (value codice-fiscale) (value data-inizio) (value data-fine)))  
              (tabular 'persone results (pers-row) 
                ('nome (label (filter (prop 'name) pers-row)))
                ('data (label (filter (prop 'data) pers-row)))
                ('dettagli (button 'dettagli (const "Dettagli") :click (target (url `(home / sinistri / { ,(value (filter (prop 'codice-fiscale) pers-row)) }))))))))))


(element person-section
  (with-doc "La sezione di ricerca basata su identificativi relativi a persone fisiche e/o giuridiche"
    (alt person-form
        (static2 :ricerca (cognome nome data-nascita ragione-sociale codice-fiscale partita-iva data-inizio data-fine) 
                 (person-search-results cognome nome data-nascita ragione-sociale codice-fiscale partita-iva data-inizio data-fine)))))
