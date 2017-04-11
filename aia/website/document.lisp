(defun outbound-details (dossier-id)
  (with-doc "La pagina che riporta i dettagli di un singolo dossier aperto dall'impresa"
    (with-data* ((dossier (remote 'dossier-data dossier-format (url `(aia / dossier / { ,(value dossier-id) })))))
      (vert (description 'dettagli-dossier-outbound dossier (row)
              ('id-dossier (label (value (filter (prop 'id-dossier) row))))
              ('id-sinistro (label (value (filter (prop 'id-sinistro) row)))) 
              ('perizia (label (value (filter (prop 'perizia) row)))) 
              ('cid (label (value (filter (prop 'cid) row)))) 
              ('compagnie 
               (tabular 'compagnie (filter (comp (prop 'compagnie) (elem)) row) (comp-row)
                 ('nome (label (value (filter (this) comp-row)))))))))))

(defun post-document (dossier payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / dossier / { ,dossier } / documents)) payload))
             ((fork (+equal+ response (const 201))
                    (show-modal (modal 'successo (const "Invio documento avvenuto con successo")))
                    (show-modal (modal 'errore (const "Errore nell'Invio del documento")))
                    ;; (target (url `(home / piattaforma / document-upload-success)))
                    ;; (target (url `(home / piattaforma / document-upload-error)))
                    )))))

(defun inbound-details (id-dossier)
  (with-doc "La pagina che riporta i dettagli di un singolo dossier destinato all'impresa"
    (with-data* ((dossier (remote 'dossier-data dossier-format (url `(aia / dossier / { ,(value id-dossier) })))))
      (vert (description 'dettagli-dossier-inbound dossier (row)
              ('id-dossier (value (filter (prop 'id-dossier) row)))
              ('id-sinistro (label (value (filter (prop 'id-sinistro) row)))) 
              ('perizia (horz (label (value (filter (prop 'perizia) row)))
                                 (conditional 'condizionale-perizia (+null+ (value (filter (prop 'perizia) row)))
                                               (horz* (perizia (gui-input 'perizia (const "Perizia")))
                                                      ((gui-button 'invio-perizia (const "Invio") :click (post-document id-dossier (value perizia)))))))) 
              ('cid (horz (label (value (filter (prop 'cid) row)))
                                 (conditional 'condizionale-cid (+null+ (value (filter (prop 'cid) row)))
                                               (horz* (cid (gui-input 'cid (const "CID")))
                                                      ((gui-button 'invio-cid (const "Invio") :click (post-document id-dossier (value cid)))))))) 
              ('compagnie 
               (tabular 'compagnie (filter (comp (prop 'compagnie) (elem)) row) (comp-row)
                 ('nome (label (value (filter (this) comp-row)))))))))))

;; (element dossier-creation-error 
;;   (with-description "Pagina visualizzata in presenza di errori nell'apertura dossier"
;;     (vert (label (const "Errore nell'apertura dossier"))
;;           (gui-button 'indietro (const "Indietro") :click (target (url `(home / piattaforma / outbound)))))))

;; (element dossier-creation-success 
;;   (with-description "Pagina visualizzata in caso di successo nell'apertura dossier"
;;     (vert (label (const "Dossier aperto con successo"))
;;           (gui-button 'indietro (const "Indietro") :click (target (url `(home / piattaforma / outbound)))))))

(defun post-dossier (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / dossier)) payload))
             ((fork (+equal+ response (const 201))
                    (show-modal (modal 'successo (const "Creazione dossier avvenuta con successo")))
                    (show-modal (modal 'errore (const "Errore nella creazione del dossier")))
                    ;; (target (url `(home / piattaforma / outbound / errore-apertura)))
                    ;; (target (url `(home / piattaforma / outbound / successo-apertura)))
                    )))))

(defun put-dossier (id-dossier payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-put* (url `(aia / dossier / { ,(value id-dossier) })) payload))
             ((fork (+equal+ response (const 201))
                    (show-modal (modal 'successo (const "Creazione dossier avvenuta con successo")))
                    (show-modal (modal 'errore (const "Errore nella creazione del dossier")))
                    ;; (target (url `(home / piattaforma / outbound / errore-apertura)))
                    ;; (target (url `(home / piattaforma / outbound / successo-apertura)))
                    )))))

(element outbound-form 
  (with-doc "Il form per la creazione di un nuovo dossier"
    (vert* (pform (obj* 'upload-data dossier-upload-format 
                        ((id-sinistro id-sinistro (gui-input 'id-sinistro (const "Sinistro")))
                         ;; (perizia perizia (checkbox* :label (const "Perizia")))
                         ;; (cid cid (checkbox* :label (const "CID")))
                         (compagnie compagnie (replica 'compagnie company-id-format (gui-input 'compagnia (const "Compagnia"))))) 
                        (vert id-sinistro #|perizia cid|# compagnie)))
           ((gui-button 'invio-dossier (const "Invio") :click (post-dossier (payload pform)))))))

(element outbound-list 
  (with-doc "Vista di tutti i dossier aperti dalla compagnia"
    (vert
     (tabular 'dossier-outbound  dossier-format (dossier-row)
       ('id-dossier (label (filter (prop 'id-dossier) dossier-row)))
       ('id-sinistro (label (filter (prop 'id-sinistro) dossier-row)))
       ('perizia (label (filter (prop 'perizia) dossier-row)))
       ('cid (label (filter (prop 'cid) dossier-row)))
       ('compagnie 
        (listing 'compagnie (filter (comp (prop 'compagnie) (elem)) dossier-row) (comp-row)
          (label (value (filter (this) comp-row)))))
       ('dettagli (gui-button 'dettagli(const "Dettagli") :click (target (url `(home / piattaforma / outbound / { ,(value (filter (prop 'id-dossier) dossier-row)) }))))))
     (gui-button 'nuovo (const "Nuovo dossier")
              :click (target (url `(home / piattaforma / outbound / apertura)))))))

(element outbound-section 
  (with-doc "La sezione dei fascicoli aperti dall'impresa. Qui l'utente può visualizzarne la lista, i dettagli di ciascun dossier aperto, nonché aprirne di nuovi"
    (alt outbound-list
         (static2 :apertura nil outbound-form)
         ;; (static2 :errore-apertura nil dossier-creation-error)
         ;; (static2 :successo-apertura nil dossier-creation-success) 
         (dynamic2 id-dossier (outbound-details id-dossier)))))

;; (element document-search-form
;;   (with-doc "Il form di inserimento dati relativi alla ricerca di informazioni presenti sulla piattaforma"
;;     (vert* (targa (gui-input* (const "Targa")))
;;            (sinistro (gui-input* (const "Sinistro")))
;;            (codfisc (gui-input* (const "Codice fiscale")))
;;            (inizio (gui-input* (const "Data inizio")))
;;            (fine (gui-input* (const "Data fine")))
;;            ((gui-button* (value targa) ;; (const "Invio") 
;;                      :click (target (url `(home / document-search-results 
;;                                                 ? targa =  { ,(value targa ) }
;;                                                 & sinistro =  { ,(value sinistro) }
;;                                                 & codfisc =  { ,(value codfisc) }
;;                                                 & inizio =  { ,(value inizio) }
;;                                                 & fine =  { ,(value fine) }
;;                                                 & pagina =  { ,(const 1) }))))))))

;; (defun post-document (dossier payload)
;;   (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
;;     (concat* (response (http-post* (url `(aia / dossier / { ,dossier } / documents)) payload))
;;              ((fork (+equal+ response (const 201))
;;                     (target (url `(home / piattaforma / document-upload-success)))
;;                     (target (url `(home / piattaforma / document-upload-error))))))))

;; (element document-upload-form
;;   (with-doc "Il form di inserimento dati relativi all'invio di informazioni  sulla piattaforma"
;;     (vert* (pform (obj* 'upload-data document-upload-format 
;;                         ((targa veicolo (gui-input* (const "Targa")))
;;                          (sinistro sinistro (gui-input* (const "Sinistro")))
;;                          (codfisc persona (gui-input* (const "Codice fiscale"))))
;;                         (vert targa sinistro codfisc)))
;;            ((gui-button* (const "Invio") :click (post-document (payload pform)))))))

;; (defun document-search-results (targa sinistro codfisc inizio fine pagina)
;;   (with-doc "La pagina di risultati della ricerca dati sulla piattaforma"
;;     (with-data* ((results (remote 'document-search-data document-search-format 
;;                                   (url `(aia / documents 
;;                                              ? targa =  { ,(value targa ) }
;;                                              & sinistro =  { ,(value sinistro) }
;;                                              & codfisc =  { ,(value codfisc) }
;;                                              & inizio =  { ,(value inizio) }
;;                                              & fine =  { ,(value fine) }
;;                                              & pagina =  { ,(value pagina) })))))
;;       (panel* (label (cat (const "Ricerca dati piattaforma") (value targa) (value sinistro) (value codfisc) (value inizio) (value fine)))  
;;               (tabular* results (pform-row) 
;;                 ('sinistro (label (filter (prop 'sinistro) pform-row)))
;;                 ('veicolo (label (filter (prop 'veicolo) pform-row)))
;;                 ('persona (label (filter (prop 'persona) pform-row)))
;;                 ('file (label (filter (prop 'file) pform-row))))))))

;; (element dossier-search-section
;;   (with-doc "La sezione di ricerca sulla piattaforma di interscambio dati tra le compagnie"
;;     (alt document-search-form
;;          (static2 :document-search-results (targa sinistro codfisc inizio fine pagina) 
;;                   (document-search-results targa sinistro codfisc inizio fine pagina)))))

;; (element dossier-processing-error 
;;   (with-description "Pagina visualizzata in presenza di errori nel caricamento dati sulla piattaforma"
;;     (vert (label (const "Errore nel caricamento documenti"))
;;           (gui-button* (const "Indietro") :click (target (url `(home / piattaforma)))))))

;; (element dossier-processing-success 
;;   (with-description "Pagina visualizzata in presenza di successo nel caricamento dati sulla piattaforma"
;;     (vert (label (const "Documenti inviati con successo"))
;;           (gui-button* (const "Indietro") :click (target (url `(home / piattaforma)))))))

(element inbound-list 
  (with-doc "Vista di tutti i dossier di richieseta informazioni alla compagnia"
    (tabular 'dossier-inbound dossier-format (dossier-row)
      ('id-dossier (label (filter (prop 'id-dossier) dossier-row)))
      ('id-sinistro (label (filter (prop 'id-sinistro) dossier-row)))
      ('perizia (label (filter (prop 'perizia) dossier-row)))
      ('cid (label (filter (prop 'cid) dossier-row)))
      ('dettagli (gui-button 'evasione (const "Dettagli/Evasione") :click (target (url `(home / piattaforma / inbound / evasione ? dossier = { ,(value (filter (prop 'id-dossier) dossier-row)) }))))))))

(defun process-dossier (id-dossier)
  (with-doc "La pagina che riporta i dettagli di un singolo dossier di richiesta informazioni alla compagnia. Qui l'utente può effettuare l'upload dei documenti richiesti" 
    (with-data* ((dossier (remote 'dossier-data dossier-format (url `(aia / dossier / { ,(value id-dossier) })))))
      (vert (description 'dossier-outbound  dossier (row)
              ('id-dossier (label (value (filter (prop 'id-dossier) row))))
              ('id-sinistro (label (value (filter (prop 'id-sinistro) row)))) 
              ('perizia (horz (label (value (filter (prop 'perizia) row)))
                              (conditional 'condizionale-perizia (+null+ (value (filter (prop 'perizia) row)))
                                           (horz* (perizia (gui-input 'perizia (const "Perizia")))
                                                  ((gui-button 'invio-perizia (const "Invio") :click (post-document id-dossier (value perizia)))))))) 
              ('cid (horz (label (value (filter (prop 'cid) row)))
                          (conditional 'condizionale-cid (+null+ (value (filter (prop 'cid) row)))
                                       (horz* (cid (gui-input 'cidcreate-eod (const "CID")))
                                              ((gui-button 'invio-cid (const "Invio") :click (post-document id-dossier (value cid)))))))) 
              ('compagnie 
               (tabular 'compagnie (filter (comp (prop 'compagnie) (elem)) row) (comp-row)
                 ('nome (label (value (filter (this) comp-row)))))))))))


(element inbound-section
  (with-doc "La sezione di invio informazioni alla piattaforma di interscambio dati tra le compagnie"
    (alt inbound-list 
         (static2 :evasione (dossier) (process-dossier dossier))
         ;; (static2 :errore-evasione nil dossier-processing-error)
         ;; (static2 :successo-evasione nil dossier-processing-success)
         )))

(element document-section
  (with-doc "La piattaforma di interscambio dati fra le compagnie. L'utente può inviare dati o effettuare una ricerca"
    (alt (hub-spoke ((outbound "Dossier di richiesta informazioni a altre compagnie" outbound-section)
                     (inbound "Dossier provenienti da altre compagnie " inbound-section) 
                     ;; (ricerca-dossier "Ricerca informazioni" dossier-search-section)
                     )
                    :home
                    (with-doc "Il menu principale di scelta"
                      (horz outbound inbound ))))))
