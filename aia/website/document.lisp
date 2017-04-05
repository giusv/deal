(defun dossier-details (dossier-id)
  (with-doc "La pagina che riporta i dettagli di un singolo dossier"
    (with-data* ((dossier (remote 'dossier-data dossier-format (url `(aia / dossier / { ,(value dossier-id) })))))
      (vert (description* dossier (row)
              ('dossier-id (label (value (filter (prop 'dossier-id) row))))
              ('sinistro (label (value (filter (prop 'sinistro) row)))) 
              ('perizia (label (value (filter (prop 'perizia) row)))) 
              ('cid (label (value (filter (prop 'cid) row)))) 
              ('compagnie 
               (tabular* (filter (comp (prop 'compagnie) (elem)) row) (comp-row)
                 ('nome (label (value (filter (this) comp-row)))))))))))

(element dossier-upload-error 
  (with-description "Pagina visualizzata in presenza di errori nell'apertura dossier"
    (vert (label (const "Errore nell'apertura dossier"))
          (button* (const "Indietro") :click (target (url `(home / piattaforma-scambio)))))))

(element dossier-upload-success 
  (with-description "Pagina visualizzata in caso di successo nell'apertura dossier"
    (vert (label (const "Dossier aperto con successo"))
          (button* (const "Indietro") :click (target (url `(home / piattaforma-scambio)))))))

(defun post-dossier (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / dossier)) payload))
             ((fork (+equal+ response (const 201))
                    (target (url `(home / piattaforma-scambio / dossier-upload-success)))
                    (target (url `(home / piattaforma-scambio / dossier-upload-error))))))))

(element dossier-creation-form 
  (with-doc "Il form per la creazione di un nuovo fascicolo"
    (vert* (pform (obj* 'upload-data dossier-upload-format 
                        ((sinistro sinistro (input* (const "Sinistro")))
                         (perizia perizia (checkbox* :label (const "Perizia")))
                         (cid cid (checkbox* :label (const "CID")))
                         (compagnie compagnie (replica 'compagnie company-id-format (input* (const "Compagnia"))))) 
                        (vert sinistro perizia cid compagnie)))
           ((button* (const "Invio") :click (post-dossier (payload pform)))))))

(element dossier-list 
  (with-doc "Vista di tutti i dossier aperti dalla compagnia"
    (vert
     (tabular* dossier-format (dossier-row)
       ('id (label (filter (prop 'id) dossier-row)))
       ('sinistro (label (filter (prop 'sinistro) dossier-row)))
       ('perizia (label (filter (prop 'perizia) dossier-row)))
       ('cid (label (filter (prop 'cid) dossier-row)))
       ('compagnie 
        (listing* (filter (comp (prop 'compagnie) (elem)) dossier-row) (comp-row)
          (label (value (filter (this) comp-row)))))
       ('dettagli (button* (const "Dettagli") :click (target (url `(home / piattaforma-scambio / { ,(value (filter (prop 'id) dossier-row)) }))))))
     (button* (const "Nuovo fascicolo")
              :click (target (url `(home / piattaforma-scambio / creazione-fascicolo / )))))))

(element dossier-creation-section 
  (with-doc "La sezione dei fascicoli aperti dall'impresa. Qui l'utente può visualizzarne la lista, nonché aprirne di nuovi"
    (alt dossier-list
         (static2 :creazione-dossier nil dossier-creation-form))))

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
                    (target (url `(home / piattaforma-scambio / document-upload-error))))))))

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

(element dossier-search-section
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
    (alt (hub-spoke ((creazione-fascicolo "Creazione nuovo fascicolo" dossier-creation-section)
                     (evasione-fascicolo "Evasione fascicolo" document-upload-section) 
                     (ricerca-fascicolo "Ricerca informazioni" dossier-search-section))
                    :home
                    (with-doc "Il menu principale di scelta"
                      (horz creazione-fascicolo evasione-fascicolo ricerca-fascicolo)))
         (dynamic2 dossier-id (dossier-details dossier-id)))))
