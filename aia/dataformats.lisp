(data report-format 
  (jsobject 'formato-report "Formato JSON del messaggio contenente i dati di un data quality report"
            (jsprop 'id-report nil (jsstring 'id-report "Identificativo univoco del report"))
            (jsprop 'data t (jsstring 'data "Data di produzione del report"))
            (jsprop 'descrizione t (jsstring 'descrizione "Descrizione"))
            (jsprop 'link t (jsstring 'link "link al quale il report pu&ograve; essere scaricato"))))

(data company-id-format
  (jsstring 'id-compagnia "Identificativo univoco di una compagnia"))

(data dossier-format 
  (jsobject 'formato-upload-dossier "Formato JSON del messaggio inviato dal client per la creazione di un nuovo dossier sulla piattaforma interaziendale di scambio dati."
            (jsprop 'id-dossier nil (jsstring 'id-dossier "Identificativo univoco del dossier"))
            (jsprop 'id-sinistro t (jsstring 'id-sinistro "Identificativo univoco del sinistro relativamente al quale il dossier viene creato"))
            (jsprop 'perizia t (jsstring 'perizia "Perizia del sinistro in formato PDF codificato in BASE64"))
            (jsprop 'cid t (jsbool 'cid "CID del sinistro in formato PDF codificato in BASE64"))
            (jsprop 'compagnie t (jsarray 'compagnie "Lista delle compagnie destinatarie della richiesta di evasione del dossier" company-id-format))))

;; (data dossier-format 
;;   (jsobject 'formato-dossier
;;             (jsprop 'id-dossier t (jsstring 'id-dossier))
;;             (jsprop 'sinistro t (jsstring 'sinistro))
;;             (jsprop 'perizia t (jsbool 'perizia))
;;             (jsprop 'cid t (jsbool 'cid))
;;             (jsprop 'compagnie t (jsarray 'compagnie company-id-format))))

;; (data document-search-format
;;   (jsobject 'formato-ricerca-piattaforma
;;             (jsprop 'sinistro nil (jsstring 'sinistro))
;;             (jsprop 'veicolo nil (jsstring 'veicolo))
;;             (jsprop 'personaa nil (jsstring 'personaa))
;;             (jsprop 'file t (jsstring 'file))))

;; (data document-upload-format
;;   (jsobject 'formato-invio-piattaforma
;;             (jsprop 'sinistro nil (jsstring 'sinistro))
;;             (jsprop 'veicolo nil (jsstring 'veicolo))
;;             (jsprop 'personaa nil (jsstring 'personaa))
;;             (jsprop 'file t (jsstring 'file))))

;; (data person-search-format 
;;   (jsobject 'formato-ricerca-persona
;;             (jsprop 'id t (jsstring 'id))))

(data role-format
  (jsstring 'ruolo "Ruolo assunto nel sinistro"))

(data person-format 
  (jsobject 'formato-persona "Formato JSON dei dati relativi a una persona"
            (jsprop 'id-persona nil (jsstring 'id-persona "Identificativo univoco della persona")) 
            (jsprop 'nome t (jsstring 'nome "Nome")) 
            (jsprop 'cognome t (jsstring 'cognome "Cognome")) 
            (jsprop 'codice-fiscale nil (jsstring 'codice-fiscale "Codice fiscale")) 
            (jsprop 'partita-iva nil (jsstring 'partita-iva "Partita IVA")) 
            (jsprop 'luogo-nascita t (jsstring 'luogo-nascita "Luogo di nascita"))
            (jsprop 'data-nascita t (jsstring 'data-nascita "Data di nascita"))  
            (jsprop 'ruoli nil (jsarray 'ruoli "Lista di ruoli assunti nel sinistro" role-format))))

;; (data person-generic-format 
;;   (jsobject 'formato-persona
;;             (jsprop 'nome t (jsstring 'nome)) 
;;             (jsprop 'cognome t (jsstring 'cognome)) 
;;             (jsprop 'codice-fiscale t (jsstring 'codice-fiscale)) 
;;             (jsprop 'luogo-nascita t (jsstring 'luogo-nascita))
;;             (jsprop 'data-nascita t (jsstring 'data-nascita))))

(data indicator-value-format 
  (jsobject 'formato-valore-indicatore "Formato JSON del valore di un indicatore"
           (jsprop 'nome t (jsstring 'nome "Nome indicatore"))
           (jsprop 'valore t (jsstring 'valore "Valore indicatore"))))

(data vehicle-format
  (jsobject 'formato-veicolo "Formato JSON dei dati relativi a un veicolo"
            (jsprop 'targa t (jsstring 'targa "Targa"))
            (jsprop 'telaio t (jsstring 'telaio "Telaio"))
            ;; (jsprop 'tipo t (jsstring 'tipo ""))
            (jsprop 'conducente nil person-format)
            (jsprop 'proprietario nil person-format)
            (jsprop 'contraente nil person-format)
            (jsprop 'ricorrenze nil (jsnumber 'ricorrenze "Numero di ricorrenze"))
            (jsprop 'indicatori nil (jsarray 'indicatori "Lista degli indicatori associati al veicolo" indicator-value-format))))

;; (data vehicle-generic-format 
;;   (jsobject 'formato-veicolo-generico
;;             (jsprop 'targa t (jsstring 'targa))
;;             (jsprop 'telaio t (jsstring 'telaio))
;;             (jsprop 'tipo t (jsstring 'tipo))
;;             (jsprop 'ricorrenze t (jsnumber 'ricorrenze))
;;             (jsprop 'indicatori t (jsstring 'indicatori))))


(data accident-format 
  (jsobject 'formato-sinistro "Formato JSON dei dati relativi a un sinistro"
            (jsprop 'id-sinistro t (jsstring 'id-sinistro "Identificativo univoco del sinistro"))
            (jsprop 'data-accadimento t (jsstring 'data-accadimento "Data di accadimento del sinistro"))
            (jsprop 'data-denuncia t (jsstring 'data-denuncia "Data di denuncia del sinistro"))
            (jsprop 'data-definizione t (jsstring 'data-definizione "Data di definizione del sinistro"))
            (jsprop 'stato t (jsstring 'stato "Stato del sinistro"))
            (jsprop 'luogo t (jsstring 'luogo "Luogo di accadimento del sinistro"))
            ;; (jsprop 'ruolo t (jsstring 'ruolo) "")
            (jsprop 'intervento t (jsbool 'intervento "Intervento autorit&agrave;"))
            (jsprop 'danni t (jsbool 'danni "Danni a cose"))
            (jsprop 'lesioni t (jsbool 'lesioni "Lesioni a persone"))
            (jsprop 'decessi t (jsbool 'decessi "Decessi"))
            (jsprop 'errore t (jsstring 'errore "Errore"))
            (jsprop 'veicoli t (jsarray 'veicoli "Lista di veicoli coinvolti nel sinistro" vehicle-format))
            (jsprop 'persone t (jsarray 'persone "Lista di soggetti coinvolti nel sinistro" person-format))))

(data parameter-format
  (jsobject 'formato-parametro "Formato JSON del valore di un parametro relativo a un indicatore"
            (jsprop 'id-parametro nil (jsstring 'id-parametro "Identificativo univoco del parametro"))
            (jsprop 'nome t (jsstring 'nome "Nome"))
            (jsprop 'valore t (jsstring 'valore "Valore"))))

(data indicator-parameter-array-format
  (jsarray 'formato-vettore-parametri "Lista dei parametri associati a un indicatore" parameter-format))

(data indicator-format 
  (jsobject 'formato-indicatore "Formato JSON di un indicatore dinamico"
            (jsprop 'nome t (jsstring 'nome "Nome indicatore"))
            (jsprop 'codice t (jsstring 'codice "Codice sorgente"))
            (jsprop 'data-inizio t (jsstring 'data-inizio "Data inizio validit&agrave;"))
            (jsprop 'parametri t indicator-parameter-array-format)))

(data inquiry-format 
  (jsobject 'formato-inquiry "Formato JSON dei dati relativi a un inquiry verso AIA effettuatata delle compagnie"
            (jsprop 'id-inquiry t (jsstring 'id-inquiry "Identificativo univoco dell'inquiry"))
            (jsprop 'targa t (jsstring 'targa "Chiave di ricerca targa"))
            (jsprop 'persona t (jsstring 'persona "Chiave di ricerca persona"))
            (jsprop 'userid t (jsstring 'userid "Userid dell'utente che ha effettuato l'inquiry"))
            (jsprop 'compagnia t (jsstring 'compagnia "Compagnia dell'utente che ha effettuato l'inquiry"))
            (jsprop 'cue t (jsstring 'cue "Chiave di ricerca CUE"))
            (jsprop 'data-inizio t (jsstring 'data-inizio "Chiave di ricerca data inizio"))
            (jsprop 'data-fine t (jsstring 'data-fine "Chiave di ricerca data fine"))))


(data company-address-format
  (jsstring 'indirizzo "Indirizzo"))

(data company-format 
  (jsobject 'formato-compagnia "Formato JSON dei dati di una compagnia"
            (jsprop 'nome t (jsstring 'nome "Nome"))
            (jsprop 'indirizzi t (jsarray 'indirizzi "Lista di indirizzi di una compagnia" company-address-format))))

(data subscriber-format
  (jsnumber 'sottoscrittore "Identificativo univoco del sottoscrittore"))

(data news-format 
  (jsobject 'formato-notizia "Formato JSON della notizia destinata a una determinata compagnia"
            (jsprop 'testo t (jsstring 'testo-notizia "Testo notizia"))
            (jsprop 'data-inizio t (jsstring 'data-inizio "Data inizio della pubblicazione"))
            (jsprop 'data-fine t (jsstring 'data-fine "Termine della pubblicazione"))
            (jsprop 'subscribers t (jsarray 'formato-sottoscrittore "Lista dei sottoscrittori selezionati per la ricezione della notizia" subscriber-format))))

(data document-format 
  (jsobject 'formato-documento "Formato JSON di un documento scambiato sulla piattaforma interaziendale"
            (jsprop 'id-documento nil (jsstring 'id-documento "Identificativo univoco del documento"))
            (jsprop 'tipo t (jsstring 'tipo "Tipologia del documento"))
            (jsprop 'cue t (jsstring 'cue "CUE del sinistro a cui il documento fa riferimento"))
            (jsprop 'binario t (jsstring 'binario "Contenuto del documento in formato PDF codificato in BASE64"))))

;; (data auditing-format
;;   (jsobject 'formato-auditing "Formato"
;;             (jsprop 'nome t (jsstring 'nome-compagnia))))

(data black-format
  (jsobject 'formato-black "Formato JSON di un elemento della black-list"
            (jsprop 'id-black t (jsstring 'id-black "Identificativo univoco di un elemento della black list"))
            (jsprop 'valore t (jsstring 'valore-black "Valore di un elemento della black list"))
            (jsprop 'tipo t (jsstring 'tipo-black "Tipo di un elemento della black list"))))

(data white-format
  (jsobject 'formato-white "Formato JSON di un elemento della white-list"
            (jsprop 'id-white t (jsstring 'id-white "Identificativo univoco di un elemento della white list"))
            (jsprop 'valore t (jsstring 'valore-white "Valore di un elemento della white list"))
            (jsprop 'tipo t (jsstring 'tipo-white "Tipo di un elemento della white list"))))


(data indicator-entity
  (entity 'indicatore "Entit&agrave; relativa a un indicatore dinamico"
          (primary-key 
           (attribute 'id-indicatore 'string "Identificativo univoco dell'indicatore"))
          (list (attribute 'nome 'string "Nome dell'indicatore")
                (attribute 'codice-sorgente 'string "Codice sorgente scritto dall'utente")
                (attribute 'codice-oggetto 'string "Codice oggetto prodotto dal compilatore")
                (attribute 'data-inizio 'string "Data inizio validit&agrave;"))))

(data parameter-entity 
  (entity 'parametro "Entit&agrave; relativa a un parametro di un indicatore dinamico"
          (primary-key 
           (attribute 'id-parametro 'string "Identificativo univoco del parametro"))
          (list (attribute 'id-indicatore 'string "Identificativo univoco dell'indicatore a cui il parametro si riferisce")
                (attribute 'nome 'string "Nome del parametro")
                (attribute 'valore 'string "Valore del parametro"))
          (foreign-key 'indicatore 
                       'id-indicatore)))

(data company-entity
  (entity 'compagnia "Entit&agrave; relativa a una compagnia"
          (primary-key
           (attribute 'id-compagnia 'integer "Identificativo univoco di una compagnia"))
          (list (attribute 'nome 'string "Nome compagnia")
                (attribute 'address 'string "Indirizzo"))))

(data subscription-entity 
  (entity 'sottoscrizione "Entit&agrave; relativa alla sottoscrizione di una notizia da parte di una compagnia"
          (primary-key
           (attribute 'id-compagnia 'integer "Compagnia sottoscrittrice")
           (attribute 'id-notizia 'integer "Notizia sottoscritta"))
          nil))

(data news-entity
  (entity 'notizia "Entit&agrave; relativa a una notizia"
          (primary-key
           (attribute 'id-notizia 'integer "Identificativo univoco della notizia"))
          (list (attribute 'testo 'string "Testo della notizia")
                (attribute 'data-inizio 'string "Data inizio pubblicazione")
                (attribute 'data-fine 'string "Data fine pubblicazione"))))

(data document-entity
  (entity 'documento "Entit&agrave; relativa a un documento scambiato sulla piattaforma interaziendale"
          (primary-key
           (attribute 'id-documento 'integer "Identificativo univoco del documento"))
          (list (attribute 'id-dossier 'string "Identificativo univoco del dossier a cui il documento afferisce")
                (attribute 'tipo 'string "Tipologia del documento")
                (attribute 'binario 'blob "File in formato pdf")
                (attribute 'stato 'string "Stato del documento"))
          (foreign-key 'dossier-entity
                       'id-dossier)))

(data dossier-entity
  (entity 'dossier "Entit&agrave; relativa a un dossier"
          (primary-key
           (attribute 'id-dossier 'integer "Identificativo univoco di un dossier"))
          (list (attribute 'cue 'string "CUE del sinistro a cui il dossier fa riferimento") 
                (attribute 'perizia 'integer "Identificativo univoco del documento corrispondente alla perizia")
                (attribute 'cid 'integer "Identificativo univoco del documento corrispondente al CID")
                (attribute 'proprietario 'integer "Identificativo univoco dell'operatore che ha creato/modificato il documento"))
          (foreign-key 'operator-entity
                       'proprietario)
          (foreign-key 'documento
                       'perizia)
          (foreign-key 'documento
                       'cid)))

;; (data dossier-processor-entity
;;   (entity 'dossier-processor-entity
;;           (primary-key
;;            (attribute 'id-dossier 'integer)
;;            (attribute 'id-compagnia 'integer))
;;           nil))

(data accident-entity 
  (entity 'sinistro "Entit&agrave; relativa a un sinistro"
          (primary-key
           (attribute 'id-sinistro 'integer "Identificativo univoco del sinistro"))
          (list (attribute 'data-accadimento 'string "Data di accadimento del sinistro")
                (attribute 'data-denuncia 'string "Data di denuncia del sinistro")
                (attribute 'data-definizione 'string "Data di definizione del sinistro")
                (attribute 'stato 'string "Stato del sinistro")
                (attribute 'luogo 'string "Luogo di accadimento del sinistro")
                ;; (attribute 'ruolo 'string)
                (attribute 'intervento 'string "Intervento autorit&agrave;")
                (attribute 'danni 'string "Danni a cose")
                (attribute 'lesioni 'string "Lesioni a persone")
                (attribute 'decessi 'string "Decessi")
                (attribute 'errore 'string "Errore"))))

(data inquiry-entity 
  (entity 'inquiry "Entit&agrave; relativa a un inquiry effettuata dalle compagnie"
          (primary-key
           (attribute 'id-inquiry 'integer "Identificativo univoco dell'inquiry"))
          (list (attribute 'tipo 'string "Tipologia dell'inquiry (veicolo, soggetto)")
                (attribute 'targa 'string "Chiave di ricerca targa")
                (attribute 'persona 'string "Chiave di ricerca persona")
                (attribute 'userid 'string "Userid dell'utente che ha effettuato l'inquiry")
                (attribute 'compagnia 'string "Compagnia dell'utente che ha effettuato l'inquiry")
                (attribute 'cue 'string "Chiave di ricerca CUE")
                (attribute 'data-inizio 'string "Chiave di ricerca data inizio")
                (attribute 'data-fine 'string "Chiave di ricerca data fine"))))

(data black-entity 
  (entity 'black "Entit&agrave; relativa a un elemento della black-list"
          (primary-key
           (attribute 'black-id 'string "Identificativo univoco di un elemento della black list"))
          (list (attribute 'valore 'string "Valore di un elemento della black list")
                (attribute 'tipo 'string "Tipo di un elemento della black list"))))

(data white-entity 
  (entity 'white "Entit&agrave; relativa a un elemento della white-list"
          (primary-key
           (attribute 'white-id 'string "Identificativo univoco di un elemento della white list"))
          (list (attribute 'valore 'string "Valore di un elemento della white list")
                (attribute 'tipo 'string "Tipo di un elemento della white list"))))

(data person-entity 
  (entity 'persona "Entit&agrave; relativa a una persona"
          (primary-key 
           (attribute 'id-persona 'string "Identificativo univoco della persona"))
          (list (attribute 'nome 'string "Nome") 
                (attribute 'cognome 'string "Cognome") 
                (attribute 'codice-fiscale 'string "Codice fiscale") 
                (attribute 'partitva-iva 'string "Partita IVA") 
                (attribute 'luogo-nascita 'string "Luogo di nascita")
                (attribute 'data-nascita 'string "Data di nascita"))))

(data vehicle-entity
  (jsobject 'veicolo "Entit&agrave; relativa a un veicolo"
            (primary-key
             (attribute 'id-veicolo 'string "Identificativo univoco del veicolo"))
            (attribute 'targa 'string "Targa")
            (attribute 'telaio 'string "Telaio")
            (attribute 'ricorrenze 'number "Ricorrenze")
            (attribute 'indicatori 'string "")))

(data report-entity
  (entity 'report "Entit&agrave; relativa a un report di data quality"
          (primary-key
           (attribute 'id-report 'number "Identificativo univoco del report"))
          (list (attribute 'data 'date "Data di produzione del report")
                (attribute 'descrizione 'string  "Descrizione")
                (attribute 'pdf 'string "contenuto del report in formato pdf")
                (attribute 'id-compagnia 'number "Identificativo della compagnia a cui il report &egrave; destinato"))
          (foreign-key 'compagnia
                       'id-compagnia)))

(data vehicle-indicator-value-entity 
  (entity 'indicatore-veicolo "Entit&agrave; dei valori calcolati dei diversi indicatori relativi a veicoli"
           (primary-key
            (attribute 'id-valore-indicatore 'number "Identificativo univoco del valore"))
           (list (attribute 'nome 'string "Nome dell'indicatore")
                 (attribute 'valore 'string "Valore dell'indicatore")
                 (attribute 'id-veicolo 'number "Identificativo del veicolo a cui il valore dell'indicatore &egrave; riferito"))
           (foreign-key 'vehicle-entity 'id-veicolo)))

(data accident-indicator-value-entity 
  (entity 'indicatore-sinistro "Entit&agrave; dei valori calcolati dei diversi indicatori relativi a sinistri"
           (primary-key
            (attribute 'id-valore-indicatore 'number "Identificativo univoco del valore"))
           (list (attribute 'nome 'string "Nome dell'indicatore")
                 (attribute 'valore 'string "Valore dell'indicatore")
                 (attribute 'id-sinistro 'number "Identificativo del sinistro a cui il valore dell'indicatore &egrave; riferito"))
           (foreign-key 'accident-entity 'id-sinistro)))
