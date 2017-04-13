(element inquiry-audit-form
  (with-doc "Il form di inserimento dati relativi alla ricerca sui log degli accessi per inquiry da parte delle compagnie"
    (vert* (targa (input* (const "Targa")))
           (compagnia (input* (const "Compagnia")))
           (userid (input* (const "Utente")))
           (cue (input* (const "Cue")))
           (inizio (input* (const "Data inizio")))
           (fine (input* (const "Data fine")))
           ((button* (const "Invio") 
                     :click (target (url `(home / ricerca-inquiry-audit
                                                ? targa = { ,(value targa) }
                                                & compagnia = { ,(value compagnia) }
                                                & userid = { ,(value userid) }
                                                & cue = { ,(value cue) }
                                                & inizio = { ,(value inizio) }
                                                & fine = { ,(value fine) }
                                                & pagina = { ,(const 1) }))))))))

(defun inquiry-audit-search-results (targa userid compagnia cue inizio fine pagina)
  (with-doc "La pagina di risultati della ricerca sui log degli accessi per inquiry da parte delle compagnie"
    (with-data* ((inquiry-data (remote 'inquiry-data inquiry-format 
                                       (url `(aia / inquiries 
                                                  ? targa = { ,(value targa) }
                                                  & compagnia = { ,(value compagnia) }
                                                  & userid = { ,(value userid) }
                                                  & cue = { ,(value cue) }
                                                  & inizio = { ,(value inizio) }
                                                  & fine = { ,(value fine) }
                                                  & pagina = { ,(const 1) })))))
      (pivot* inquiry-data 'targa 'compagnia))

    ;; (with-data* ((vehicle (remote 'vehicle-data vehicle-generic-format
    ;;                                (url `(aia / veicoli
    ;;                                           ? targa =  { ,(value targa) }))))
    ;;              (accidents (remote 'accident-data accident-format 
    ;;                                 (url `(aia / sinistri
    ;;                                            ? targa =  { ,(value targa) }
    ;;                                            & inizio =  { ,(value inizio) }
    ;;                                            & fine =  { ,(value fine) }
    ;;                                            & pagina =  { ,(value pagina) })))))
    ;;   (panel* (label (cat (const "Ricerca per targa") (value targa) (value inizio) (value fine)))  
    ;;           (vert (chart* vehicle)
    ;;                 (tabular* accidents (acc-row)
    ;;                   ('data-accadimento (label (filter (prop 'data-accadimento) acc-row)))
    ;;                   ('stato (label (value (filter (prop 'stato) acc-row))))
    ;;                   ('luogo (label (value (filter (prop 'luogo) acc-row))))
    ;;                   ('ruolo (label (value (filter (prop 'ruolo) acc-row))))
    ;;                   ('intervento (label (value (filter (prop 'intervento) acc-row))))
    ;;                   ('danni-/-lesioni-/-decessi (label (cat (value (filter (prop 'danni) acc-row)) (const "/")
    ;;                                                           (value (filter (prop 'lesioni) acc-row)) (const "/")
    ;;                                                           (value (filter (prop 'decessi) acc-row)))))
    ;;                   ('dettagli (button* (const "Dettagli") :click (target (url `(home / { ,(value (filter (prop 'id) acc-row)) })))))))))
    ))

(element inquiry-audit-section
  (with-description "La sezione di audit sulle inquiry effettuate dalle compagnie. Qui l'utente pu&ograve; visualizzare i dati relativi agli accessi, aggregati in base a una compagnia, a un singolo utente, a un determinato sinistro e relativamente a un periodo di tempo specificato"
    (alt inquiry-audit-form
         (static2 :ricerca-inquiry-audit (targa compagnia userid cue inizio fine pagina) (inquiry-audit-search-results targa compagnia userid cue inizio fine pagina)))))
