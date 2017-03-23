(element plate-form
  (vert* (plate (input* (const "Targa")))
         (start-date (input* (const "Data inizio")))
         (end-date (input* (const "Data fine")))
         ((button* (const "Invio") :click (target (url `(home / plate-search-results)))))))

(element plate-search-results
  (label (const "Results")))

(element plate-section
  (alt plate-form
       (static2 :plate-search-results nil plate-search-results)))

(element person-form
  (vert* (code (input* (const "Codice fiscale")))
         (start-date (input* (const "Data inizio")))
         (end-date (input* (const "Data fine")))
         ((button* (const "Invio") :click (target (url `(home / person-search-results)))))))

(defun accident-details (id)
  (with-data* ((results (remote 'accident-data accident-format (url `(aia / sinistri / { ,(value id) })))))
    (tabular* accident-format
      ('id (label (prop 'id)))
      ('data (label (filter (prop 'data) it))))))

(defun person-search-results (code start-date end-date)
  (with-data* ((results (remote 'person-search-data person-search-format (url `(aia / sinistri ? code =  { ,(value code) })))))
    (tabular* person-search-format
      ('nome (label (prop 'name)))
      ('data (label (filter (prop 'data) it)))
      ('dettagli (button* (const "Dettagli") :click (target (url `(home / sinistri / { ,(value (prop 'name)) }))))))))

(element person-section
  (alt person-form
       (static2 :person-search-results (code start-date end-date) (person-search-results code start-date end-date))
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


