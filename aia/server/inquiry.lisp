(process list-accidents
  (let* ((plate (query-parameter 'targa))
         (person (query-parameter 'soggetto))
         (start-date (query-parameter 'inizio))
         (end-date (query-parameter 'fine))
         (page (query-parameter 'pagina)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento di infornazioni sui sinistri a partire da un insieme di chiavi di ricerca. Esso restituisce in formato JSON i dati relativi ai sinistri trovati."
      (sync-server 
      :name 'list-accidents
      :parameters (list plate start-date end-date page)
      :command (concat* 
                (log (create-instance2 inquiry-entity
                                       (list (prop 'plate) plate
                                             (prop 'person) person
                                             (prop 'type) (const "sinistro")
                                             (prop 'userid) (const "userid")
                                             (prop 'company) (const "company")
                                             (prop 'start-date) start-date
                                             (prop 'end-date) end-date))) 
                (accidents (query2 (restrict (relation 'accident-entity)
                                             (+and+ (+or+ 
                                                     (+equal+ (prop 'targa) plate)
                                                     (+equal+ (prop 'soggetto) person))))))
                (json (rel-to-json2 accidents 
                                    (list 'data-accadimento 'data-denuncia 'data-definizione 
                                          'luogo 'ruolo 'intervento 'danni 
                                          'lesioni 'decessi 'errore))) 
                ((http-response 200 :payload json)))))))

(process list-persons
  (let* ((cognome (query-parameter 'cognome))
         (nome (query-parameter 'nome))
         (ragsoc (query-parameter 'ragsoc))
         (codfisc (query-parameter 'codfisc))
         (datanasc (query-parameter 'datanasc))
         (partiva (query-parameter 'partiva ))
         (inizio (query-parameter 'inizio))
         (fine (query-parameter 'fine)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento di infornazioni sui soggetti a partire da un insieme di chiavi di ricerca. Esso restituisce in formato JSON i dati relativi ai soggetti trovati."
      (sync-server 
      :name 'list-persons
      :parameters (list cognome nome ragsoc codfisc datanasc partiva inizio fine)
      :command (concat* 
                (log (create-instance2 inquiry-entity
                                       (list (prop 'plate) (const "")
                                             (prop 'person) cognome
                                             (prop 'type) (const "soggetto")
                                             (prop 'userid) (const "userid")
                                             (prop 'company) (const "company")
                                             (prop 'start-date) inizio
                                             (prop 'end-date) fine))) 
                (persons (query2 (restrict (relation 'person-entity)
                                           (+and+ (+equal+ (prop 'cognome) cognome)
                                                  (+equal+ (prop 'nome) nome)
                                                  (+or+ (+equal+ (prop 'codice-fiscale) codfisc)
                                                        (+equal+ (prop 'partita-iva) partiva))))))
                (json (rel-to-json2 persons 
                                    (list 'nome 'cognome 'codice-fiscale
                                          'partita-iva 'luogo-nascita 'data-nascita))) 
                ((http-response 200 :payload json)))))))

(process list-vehicles
  (let* ((targa (query-parameter 'targa))
         (start-date (query-parameter 'inizio))
         (end-date (query-parameter 'fine)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento di infornazioni sui veicoli a partire da un insieme di chiavi di ricerca. Esso restituisce in forato JSON i dati relativi ai veicoli trovati."
      (sync-server 
      :name 'list-vehicles
      :parameters (list targa start-date end-date)
      :command (concat* 
                (log (create-instance2 inquiry-entity
                                       (list (prop 'plate) targa
                                             (prop 'person) (const "")
                                             (prop 'type) (const "veicolo")
                                             (prop 'userid) (const "userid")
                                             (prop 'company) (const "company")
                                             (prop 'start-date) start-date
                                             (prop 'end-date) end-date))) 
                (persons (query2 (restrict (relation 'vehcile-entity)
                                           (+and+ (+equal+ (prop 'targa) targa)))))
                (json (rel-to-json2 persons 
                                    (list 'nome 'cognome 'codice-fiscale
                                          'partita-iva 'luogo-nascita 'data-nascita))) 
                ((http-response 200 :payload json)))))))

(process list-inquiries
  (let* ((plate (query-parameter 'targa))
         (userid (query-parameter 'userid))
         (company (query-parameter 'company))
         (cue (query-parameter 'cue))
         (start-date (query-parameter 'inizio))
         (end-date (query-parameter 'fine))
         (page (query-parameter 'pagina)))
    (sync-server 
     :name 'list-inquiries
     :parameters (list plate userid company cue start-date end-date page)
     :command (concat* 
               (inquiries (query2 (restrict (relation 'inquiry-entity)
                                            (+or+ 
                                             (+equal+ (prop 'plate) plate)
                                             (+equal+ (prop 'userid) userid)
                                             (+equal+ (prop 'company) company)
                                             (+equal+ (prop 'cue) cue))))) 
               (json (rel-to-json2 inquiries 
                                   (list 'plate 'userid 'company 'cue 'start-date 'end-date))) 
               ((http-response 200 :payload json))))))

(service inquiry-service 
  (rest-service 'inquiry-service 
                (url `(aia))
                (rest-get (url `(sinistri)) list-accidents)
                (rest-get (url `(inquiries)) list-inquiries)))
