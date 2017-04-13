(element quality-form
  (with-doc "Il form di inserimento dati relativi alla ricerca per date"
    (vert* (data-inizio (gui-input 'data-inizio (const "Data inizio")))
           (data-fine (gui-input 'data-fine (const "Data fine")))
           ((gui-button 'invio (const "Invio") 
                        :click (target (url `(home / data-quality / report
                                                   ? data-inizio =  { ,(value data-inizio) }
                                                   & data-fine =  { ,(value data-fine) }
                                                   & pagina =  { ,(const 1) }))))))))

(defun quality-search-results (data-inizio data-fine pagina)
  (with-doc "La pagina di risultati della ricerca per date"
    (with-data* ((reports (remote 'report-data report-format 
                                  (url `(aia / report
                                             ? data-inizio =  { ,(value data-inizio) }
                                             & data-fine =  { ,(value data-fine) }
                                             & pagina =  { ,(value pagina) })))))
      (panel 'risultati-ricerca-per-date (label (cat (const "Ricerca per date") (value data-inizio) (value data-fine)))
             (vert (tabular 'report reports (rep-row)
                     ('data (label (attr rep-row 'data)))
                     ('descrizione (label (attr rep-row 'descrizione)))
                     ('link (anchor 'scarica (attr rep-row 'link)))))))))

(element quality-section
  (with-doc "La sezione di ricerac e visualizzazione dei report di data quality destinati alle compagnie)"
    (alt quality-form
         (static2 :report (data-inizio data-fine pagina) (quality-search-results data-inizio data-fine pagina)))))
