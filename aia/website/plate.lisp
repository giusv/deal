(element plate-form
  (with-doc "Il form di inserimento dati relativi alla ricerca per targa"
    (vert* (targa (input* (const "Targa")))
           (inizio (input* (const "Data inizio")))
           (fine (input* (const "Data fine")))
           ((button* (value targa);; (const "Invio") 
                     :click (target (url `(home / ricerca-per-targa 
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
         (static2 :ricerca-per-targa (targa inizio fine pagina) (plate-search-results targa inizio fine pagina)))))