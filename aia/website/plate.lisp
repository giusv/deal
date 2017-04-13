(element plate-form
  (with-doc "Il form di inserimento dati relativi alla ricerca per targa"
    (vert* (targa (gui-input 'targa (const "Targa")))
           (data-inizio (gui-input 'data-inizio (const "Data inizio")))
           (data-fine (gui-input 'data-fine (const "Data fine")))
           ((gui-button 'invio (const "Invio") 
                        :click (target (url `(home / ricerca-per-targa / veicoli
                                                   ? targa =  { ,(value targa ) }
                                                   & data-inizio =  { ,(value data-inizio) }
                                                   & data-fine =  { ,(value data-fine) }
                                                   & pagina =  { ,(const 1) }))))))))

(defun plate-search-results (targa data-inizio data-fine pagina)
  (with-doc "La pagina di risultati della ricerca per targa"
    (with-data* ((vehicle (remote 'vehicle-data vehicle-format
                                   (url `(aia / veicoli
                                              ? targa =  { ,(value targa) }))))
                 (accidents (remote 'accident-data accident-format 
                                    (url `(aia / sinistri
                                               ? targa =  { ,(value targa) }
                                               & data-inizio =  { ,(value data-inizio) }
                                               & data-fine =  { ,(value data-fine) }
                                               & pagina =  { ,(value pagina) })))))
      (panel 'risultati-ricerca-per-targa (label (cat (const "Ricerca per targa") (value targa) (value data-inizio) (value data-fine)))
              (vert (chart 'indicatori-veicolo vehicle)
                    (tabular 'sinistri accidents (acc-row)
                      ('data-accadimento (label (attr acc-row 'data-accadimento)))
                      ('stato (label (attr acc-row 'stato)))
                      ('luogo (label (attr acc-row 'luogo)))
                      ;; ('ruolo (label (attr acc-row 'ruolo)))
                      ('intervento (label (attr acc-row 'intervento)))
                      ('danni-/-lesioni-/-decessi (label (cat (attr acc-row 'danni) (const "/")
                                                              (attr acc-row 'lesioni) (const "/")
                                                              (attr acc-row 'decessi))))
                      ('dettagli (gui-button 'dettagli (const "Dettagli") :click (target (url `(home / { ,(value (filter (prop 'id-sinistro) acc-row)) })))))))))))

(element plate-section
  (with-doc "La sezione di ricerca basata su identificativi relativi a veicoli (targa)"
    (alt plate-form
         (static2 :ricerca (targa data-inizio data-fine pagina) (plate-search-results targa data-inizio data-fine pagina)))))
