(element document-search-form
  (with-doc "Il form di inserimento dati relativi alla ricerca di informazioni presenti sulla piattaforma"
    (vert* (targa (input* (const "Targa")))
           (sinistro (input* (const "Sinistro")))
           (codfisc (input* (const "Codice fiscale")))
           (inizio (input* (const "Data inizio")))
           (fine (input* (const "Data fine")))
           ((button* (value targa) ;; (const "Invio") 
                     :click (target (url `(home / document-search-results 
                                                ? targa =  { ,(value targa ) }
                                                & sinistro =  { ,(value sinistro) }
                                                & codfisc =  { ,(value codfisc) }
                                                & inizio =  { ,(value inizio) }
                                                & fine =  { ,(value fine) }
                                                & pagina =  { ,(const 1) }))))))))

(defun post-document (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / documents)) payload))
             ((fork (+equal+ response (const 201))
                    (target (url `(home / piattaforma-scambio / document-upload-success)))
                    (target (url `(indicator-creation-error))))))))

(element document-upload-form
  (with-doc "Il form di inserimento dati relativi all'invio di informazioni  sulla piattaforma"
    (vert* (pform (obj* 'upload-data document-upload-format 
                        ((targa veicolo (input* (const "Targa")))
                         (sinistro sinistro (input* (const "Sinistro")))
                         (codfisc persona (input* (const "Codice fiscale"))))
                        (vert targa sinistro codfisc)))
           ((button* (const "Invio") :click (post-document (payload pform)))))))



(defun document-search-results (targa sinistro codfisc inizio fine pagina)
  (with-doc "La pagina di risultati della ricerca dati sulla piattaforma"
    (with-data* ((results (remote 'document-search-data document-search-format 
                                  (url `(aia / documents 
                                             ? targa =  { ,(value targa ) }
                                             & sinistro =  { ,(value sinistro) }
                                             & codfisc =  { ,(value codfisc) }
                                             & inizio =  { ,(value inizio) }
                                             & fine =  { ,(value fine) }
                                             & pagina =  { ,(value pagina) })))))
      (panel* (label (cat (const "Ricerca dati piattaforma") (value targa) (value sinistro) (value codfisc) (value inizio) (value fine)))  
              (tabular* results (pform-row) 
                ('sinistro (label (filter (prop 'sinistro) pform-row)))
                ('veicolo (label (filter (prop 'veicolo) pform-row)))
                ('persona (label (filter (prop 'persona) pform-row)))
                ('file (label (filter (prop 'file) pform-row))))))))

(element document-search-section
  (with-doc "La sezione di ricerca sulla piattaforma di interscambio dati tra le compagnie"
    (alt document-search-form
         (static2 :document-search-results (targa sinistro codfisc inizio fine pagina) 
                  (document-search-results targa sinistro codfisc inizio fine pagina)))))

(element document-upload-error 
  (with-description "Pagina visualizzata in presenza di errori nel caricamento dati sulla piattaforma"
    (vert (label (const "Errore nel caricamento dati"))
          (button* (const "Indietro") :click (target (url `(home / piattaforma-scambio)))))))

(element document-upload-success 
  (with-description "Pagina visualizzata in presenza di successo nel caricamento dati sulla piattaforma"
    (vert (label (const "Dati inviati con successo"))
          (button* (const "Indietro") :click (target (url `(home / piattaforma-scambio)))))))


(element document-upload-section
  (with-doc "La sezione di invio informazioni alla piattaforma di  interscambio dati tra le compagnie"
    (alt document-upload-form
         (static2 :document-upload-success nil document-upload-success)
         (static2 :document-upload-error nil document-upload-error))))

(element document-section
  (with-doc "La piattaforma di interscambio dati fra le compagnie. L'utente può inviare dati o effettuare una ricerca"
    (hub-spoke ((ricerca-piattaforma "Ricerca informazioni" document-search-section)
                (invio-piattaforma "Invio dati piattaforma" document-upload-section))
               :home
               (with-doc "Il menu principale di scelta"
                 (horz ricerca-piattaforma invio-piattaforma)))))
