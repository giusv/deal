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
           ((gui-button 'invio (const "Invio")
                        :click (target (url `(home / ricerca-per-persona / soggetti
                                                   ? cognome =  { ,(value cognome) }
                                                   & nome =  { ,(value nome) }
                                                   & ragione-sociale =  { ,(value ragione-sociale) }
                                                   & codice-fiscale =  { ,(value codice-fiscale) }
                                                   & data-nascita =  { ,(value data-nascita) }
                                                   & partita-iva =  { ,(value partita-iva ) }
                                                   & data-inizio =  { ,(value data-inizio) }
                                                   & data-fine =  { ,(value data-fine) }))))))))


(defun person-search-results (cognome nome data-nascita ragione-sociale codice-fiscale partita-iva data-inizio data-fine)
  (with-doc "La pagina di risultati della ricerca soggetti"
    (with-data* ((results (remote 'person-search-data person-format 
                                  (url `(aia / soggetti 
                                             ? cognome =  { ,(value cognome) }
                                             & nome =  { ,(value nome) }
                                             & ragione-sociale =  { ,(value ragione-sociale) }
                                             & codice-fiscale =  { ,(value codice-fiscale) }
                                             & data-nascita =  { ,(value data-nascita) }
                                             & partita-iva =  { ,(value partita-iva ) }
                                             & data-inizio =  { ,(value data-inizio) }
                                             & data-fine =  { ,(value data-fine) })))))
      (panel 'risultati-ricerca-persona (label (cat (const "Ricerca per persona") (value cognome) (value nome) (value codice-fiscale) (value data-inizio) (value data-fine)))  
             (tabular 'persone results (pers-row) 
               ('cognome (label (attr pers-row 'cognome)))
               ('nome (label (attr pers-row 'nome)))
               ('codice-fiscale (label (attr pers-row 'codice-fiscale)))
               ('partita-iva (label (attr pers-row 'partita-iva)))
               ('luogo-nascita (label (attr pers-row 'luogo-nascita)))
               ('data-nascita (label (attr pers-row 'data-nascita))) 
               ('dettagli 
                (gui-button 'dettagli (const "Dettagli") 
                            :click (target 
                                    (url `(home / sinistri-soggetto
                                                ? codice-fiscale = { ,(value (filter (prop 'codice-fiscale) pers-row)) }
                                                & partita-iva = { ,(value (filter (prop 'partita-iva) pers-row)) }))))))))))

(defun accident-search-results (codice-fiscale partita-iva data-inizio data-fine)
  (with-doc "La pagina di risultati della ricerca sinistri per soggetti"
    (with-data* ((accidents (remote 'sinistri-soggetto accident-format 
                                  (url `(aia / sinistri 
                                             ? codice-fiscale =  { ,(value codice-fiscale) }
                                             & partita-iva =  { ,(value partita-iva ) }
                                             & data-inizio =  { ,(value data-inizio) }
                                             & data-fine =  { ,(value data-fine) })))))
      (panel 'risultati-ricerca-per-persona (label (cat (const "Ricerca per persona") (value codice-fiscale) (value partita-iva) (value data-inizio) (value data-fine)))  
             (tabular 'sinistri accidents (acc-row)
               ('data-accadimento (label (attr acc-row 'data-accadimento)))
               ('stato (label (attr acc-row 'stato)))
               ('luogo (label (attr acc-row 'luogo)))
               ;; ('ruolo (label (attr acc-row 'ruolo)))
               ('intervento (label (attr acc-row 'intervento)))
               ('danni-/-lesioni-/-decessi (label (cat (attr acc-row 'danni) (const "/")
                                                       (attr acc-row 'lesioni) (const "/")
                                                       (attr acc-row 'decessi))))
               ('dettagli (gui-button 'dettagli (const "Dettagli") :click (target (url `(home / sinistri-soggetto / { ,(value (filter (prop 'id-sinistro) acc-row)) }))))))))))

(element person-section
  (with-doc "La sezione di ricerca basata su identificativi relativi a persone fisiche e/o giuridiche"
    (alt person-form
        (static2 :soggetti (cognome nome data-nascita ragione-sociale codice-fiscale partita-iva data-inizio data-fine) 
                 (person-search-results cognome nome data-nascita ragione-sociale codice-fiscale partita-iva data-inizio data-fine))
        (static2 :sinistri-soggetto (codice-fiscale partita-iva data-inizio data-fine) 
                 (accident-search-results codice-fiscale partita-iva data-inizio data-fine)))))
