(process list-accidents
  (let* ((targa (query-parameter 'targa))
         (soggetto (query-parameter 'soggetto))
         (data-inizio (query-parameter 'data-inizio))
         (data-fine (query-parameter 'data-fine))
         (pagina (query-parameter 'pagina)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento di infornazioni sui sinistri a partire da un insieme di chiavi di ricerca. Esso restituisce in formato JSON i dati relativi ai sinistri trovati."
      (sync-server 
      :name 'lista-sinistri
      :parameters (list targa data-inizio data-fine pagina)
      :command (concat* 
                (log (create-instance2 inquiry-entity
                                       (list (prop 'targa) targa
                                             (prop 'soggetto) soggetto
                                             (prop 'tipo) (const "sinistro")
                                             (prop 'userid) (const "userid")
                                             (prop 'compagnia) (const "compagnia")
                                             (prop 'data-inizio) data-inizio
                                             (prop 'data-fine) data-fine))) 
                (accidents (query2 (restrict (relation 'accident-entity)
                                             (+and+ (+or+ 
                                                     (+equal+ (prop 'targa) targa)
                                                     (+equal+ (prop 'soggetto) soggetto))))))
                (json (rel-to-json2 accidents 
                                    (list 'data-accadimento 'data-denuncia 'data-definizione 
                                          'luogo 'ruolo 'intervento 'danni 
                                          'lesioni 'decessi 'errore))) 
                ((http-response 200 :payload json)))))))

(process list-persons
  (let* ((cognome (query-parameter 'cognome))
         (nome (query-parameter 'nome))
         (ragione-sociale (query-parameter 'ragione-sociale))
         (codice-fiscale (query-parameter 'codice-fiscale))
         (data-nascita (query-parameter 'data-nascita))
         (partita-iva (query-parameter 'partita-iva ))
         (data-inizio (query-parameter 'data-inizio))
         (data-fine (query-parameter 'data-fine)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento di infornazioni sui soggetti a partire da un insieme di chiavi di ricerca. Esso restituisce in formato JSON i dati relativi ai soggetti trovati."
      (sync-server 
      :name 'lista-soggetti
      :parameters (list cognome nome ragione-sociale codice-fiscale data-nascita partita-iva data-inizio data-fine)
      :command (concat* 
                (log (create-instance2 inquiry-entity
                                       (list (prop 'targa) (const "")
                                             (prop 'soggetto) cognome
                                             (prop 'tipo) (const "soggetto")
                                             (prop 'userid) (const "userid")
                                             (prop 'compagnia) (const "compagnia")
                                             (prop 'data-inizio) data-inizio
                                             (prop 'data-fine) data-fine))) 
                (persons (query2 (restrict (relation 'soggetto-entity)
                                           (+and+ (+equal+ (prop 'cognome) cognome)
                                                  (+equal+ (prop 'nome) nome)
                                                  (+or+ (+equal+ (prop 'codice-fiscale) codice-fiscale)
                                                        (+equal+ (prop 'partita-iva) partita-iva))))))
                (json (rel-to-json2 persons 
                                    (list 'nome 'cognome 'codice-fiscale
                                          'partita-iva 'luogo-nascita 'data-nascita))) 
                ((http-response 200 :payload json)))))))

(process list-vehicles
  (let* ((targa (query-parameter 'targa))
         (data-inizio (query-parameter 'data-inizio))
         (data-fine (query-parameter 'data-fine)))
    (with-description* "Endpoint REST utilizzato per l'ottenimento di informazioni sui veicoli a partire da un insieme di chiavi di ricerca. Esso restituisce in formato JSON i dati relativi ai veicoli trovati."
      (sync-server 
      :name 'lista-veicoli
      :parameters (list targa data-inizio data-fine)
      :command (concat* 
                (log (create-instance2 inquiry-entity
                                       (list (prop 'targa) targa
                                             (prop 'soggetto) (const "")
                                             (prop 'tipo) (const "veicolo")
                                             (prop 'userid) (const "userid")
                                             (prop 'compagnia) (const "compagnia")
                                             (prop 'data-inizio) data-inizio
                                             (prop 'data-fine) data-fine))) 
                (vehicles (query2 (restrict
                                   (equijoin (relation 'vehicle-entity) (relation 'vehicle-indicator-value-entity)
                                             :id-veicolo) 
                                   (+and+ (+equal+ (prop 'targa) targa)))))
                (json (rel-to-json2 vehicles 
                                    (list 'targa 'telaio 'ricorrenze)
                                    :group (list 'nome 'valore))) 
                ((http-response 200 :payload json)))))))

(process list-inquiries
  (let* ((targa (query-parameter 'targa))
         (userid (query-parameter 'userid))
         (compagnia (query-parameter 'compagnia))
         (cue (query-parameter 'cue))
         (data-inizio (query-parameter 'data-inizio))
         (data-fine (query-parameter 'data-fine))
         (pagina (query-parameter 'pagina)))
    (sync-server 
     :name 'lista-inquiry
     :parameters (list targa userid compagnia cue data-inizio data-fine pagina)
     :command (concat* 
               (inquiries (query2 (restrict (relation 'inquiry-entity)
                                            (+or+ 
                                             (+equal+ (prop 'targa) targa)
                                             (+equal+ (prop 'userid) userid)
                                             (+equal+ (prop 'compagnia) compagnia)
                                             (+equal+ (prop 'cue) cue))))) 
               (json (rel-to-json2 inquiries 
                                   (list 'targa 'userid 'compagnia 'cue 'data-inizio 'data-fine))) 
               ((http-response 200 :payload json))))))

(service inquiry-service 
  (rest-service 'inquiry-service 
                (url `(aia))
                (rest-get (url `(sinistri)) list-accidents)
                (rest-get (url `(inquiries)) list-inquiries)
                (rest-get (url `(veicoli)) list-vehicles)))
