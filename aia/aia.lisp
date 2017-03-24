(element plate-form
  (vert* (targa (input* (const "Targa")))
         (inizio (input* (const "Data inizio")))
         (fine (input* (const "Data fine")))
         ((button* (const "Invio") 
                   :click (target (url `(home / plate-search-results 
                                              & targa =  { ,(value targa ) }
                                              & inizio =  { ,(value inizio) }
                                              & fine =  { ,(value fine) })))))))

(defun plate-search-results (targa inizio fine)
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
      ('dettagli (button* (const "Dettagli") :click (target (url `(home / plate-search-results / sinistri / { ,(value (prop 'id)) }))))))))

(element plate-section
  (alt plate-form
       (static2 :plate-search-results (targa inizio fine) (plate-search-results targa inizio fine))))

(element person-form
  (vert* (cognome (input* (const "Cognome")))
         (nome (input* (const "Nome")))
         (datanasc (input* (const "Data di nascita (gg/mm/aaaa)")))
         (ragsoc (input* (const "Ragione sociale")))
         (codfisc (input* (const "Codice fiscale")))
         (partiva (input* (const "Partita iva")))
         (inizio (input* (const "Data inizio")))
         (fine (input* (const "Data fine")))
         ((button* (const "Invio") :click (target (url `(home / person-search-results)))))))

(defun accident-details (id)
  (with-data* ((results (remote 'accident-data accident-format (url `(aia / sinistri / { ,(value id) })))))
    (tabular* accident-format
      ('id (label (prop 'id)))
      ('data (label (filter (prop 'data) it))))))

(defun person-search-results (cognome nome datanasc ragsoc codfisc partiva inizio fine)
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
      ('dettagli (button* (const "Dettagli") :click (target (url `(home / sinistri / { ,(value (prop 'name)) }))))))))



(element person-section
  (alt person-form
       (static2 :person-search-results (cognome nome datanasc ragsoc codfisc partiva inizio fine) 
                (person-search-results cognome nome datanasc ragsoc codfisc partiva inizio fine))
       (dynamic2 id (accident-details id))))

(element navbar 
  (navbar* (anchor* (const "Ricerca per veicolo") :click (target (url `(home / search-by-plate))))
           (anchor* (const "Ricerca per persona") :click (target (url `(home / search-by-person))))))


(element website
  (alt nil 
       (static2 :login nil  
                (vert* (userid (input* (const "User id") :init (const "nome.cognome@mail.com")))
                       (passwd (input* (const "Password")))
                       (ok (button* (const "Login") :click (target (url `(home)))))))
       (static2 :home nil 
                (vert* (nav navbar) 
                       (main (hub-spoke ((search-by-plate "Ricerca per targa" plate-section)
                                         (search-by-person "Ricerca per persona" person-section))
                                        :home
                                        (horz search-by-plate search-by-person)))))))


