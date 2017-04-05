(data company-id-format
  (jsstring 'id-compagnia))

(data dossier-upload-format 
  (jsobject 'formato-upload-dossier
            (jsprop 'sinistro t (jsstring 'sinistro))
            (jsprop 'perizia t (jsbool 'perizia))
            (jsprop 'cid t (jsbool 'cid))
            (jsprop 'compagnie t (jsarray 'compagnie company-id-format))))

(data dossier-format 
  (jsobject 'formato-dossier
            (jsprop 'id-dossier t (jsstring 'id-dossier))
            (jsprop 'sinistro t (jsstring 'sinistro))
            (jsprop 'perizia t (jsbool 'perizia))
            (jsprop 'cid t (jsbool 'cid))
            (jsprop 'compagnie t (jsarray 'compagnie company-id-format))))

(data document-search-format
  (jsobject 'formato-ricerca-piattaforma
            (jsprop 'sinistro nil (jsstring 'sinistro))
            (jsprop 'veicolo nil (jsstring 'veicolo))
            (jsprop 'persona nil (jsstring 'persona))
            (jsprop 'file t (jsstring 'file))))

(data document-upload-format
  (jsobject 'formato-invio-piattaforma
            (jsprop 'sinistro nil (jsstring 'sinistro))
            (jsprop 'veicolo nil (jsstring 'veicolo))
            (jsprop 'persona nil (jsstring 'persona))
            (jsprop 'file t (jsstring 'file))))

(data person-search-format 
  (jsobject 'formato-ricerca-persona
            (jsprop 'id t (jsstring 'id))))

(data role-format
  (jsstring 'ruolo))

(data person-specific-format 
  (jsobject 'formato-persona
            (jsprop 'nome t (jsstring 'nome)) 
            (jsprop 'cognome t (jsstring 'cognome)) 
            (jsprop 'codice-fiscale t (jsstring 'codice-fiscale)) 
            (jsprop 'luogo-nascita t (jsstring 'luogo-nascita))
            (jsprop 'data-nascita t (jsstring 'data-nascita))  
            (jsprop 'ruoli t (jsarray 'ruoli role-format))))

(data person-generic-format 
  (jsobject 'formato-persona
            (jsprop 'nome t (jsstring 'nome)) 
            (jsprop 'cognome t (jsstring 'cognome)) 
            (jsprop 'codice-fiscale t (jsstring 'codice-fiscale)) 
            (jsprop 'luogo-nascita t (jsstring 'luogo-nascita))
            (jsprop 'data-nascita t (jsstring 'data-nascita))))

(data vehicle-specific-format 
  (jsobject 'formato-veicolo-specifico
            (jsprop 'targa t (jsstring 'targa))
            (jsprop 'telaio t (jsstring 'telaio))
            (jsprop 'tipo t (jsstring 'tipo))
            (jsprop 'conducente t person-generic-format)
            (jsprop 'proprietario t person-generic-format)
            (jsprop 'contraente t person-generic-format)))

(data vehicle-generic-format 
  (jsobject 'formato-veicolo-generico
            (jsprop 'targa t (jsstring 'targa))
            (jsprop 'telaio t (jsstring 'telaio))
            (jsprop 'tipo t (jsstring 'tipo))
            (jsprop 'ricorrenze t (jsnumber 'ricorrenze))
            (jsprop 'indicatori t (jsstring 'indicatori))))


(data accident-format 
  (jsobject 'formato-sinistro
            (jsprop 'id t (jsstring 'id))
            (jsprop 'data-accadimento t (jsstring 'data-accadimento))
            (jsprop 'data-denuncia t (jsstring 'data-denuncia))
            (jsprop 'data-definizione t (jsstring 'data-definizione))
            (jsprop 'stato t (jsstring 'stato))
            (jsprop 'luogo t (jsstring 'luogo))
            (jsprop 'ruolo t (jsstring 'ruolo))
            (jsprop 'intervento t (jsstring 'intervento))
            (jsprop 'danni t (jsstring 'danni))
            (jsprop 'lesioni t (jsstring 'lesioni))
            (jsprop 'decessi t (jsstring 'decessi))
            (jsprop 'errore t (jsstring 'errore))
            (jsprop 'veicoli t (jsarray 'veicoli vehicle-specific-format))
            (jsprop 'persone t (jsarray 'persone person-specific-format))))

(data parameter-format
  (jsobject 'formato-parametro
            (jsprop 'id t (jsstring 'id))
            (jsprop 'name t (jsstring 'nome))
            (jsprop 'value t (jsstring 'valore))))

(data indicator-parameter-array-format
  (jsarray 'formato-vettore-parametri parameter-format))

(data indicator-format 
  (jsobject 'formato-indicatore
            (jsprop 'name t (jsstring 'nome))
            (jsprop 'code t (jsstring 'codice))
            (jsprop 'start-date t (jsstring 'data-inizio))
            (jsprop 'parameters t (jsarray 'formato-parametro parameter-format))))

(data inquiry-format 
  (jsobject 'formato-inquiry 
            (jsprop 'inquiry-id t (jsstring 'id-inquiry))
            (jsprop 'plate t (jsstring 'targa))
            (jsprop 'userid t (jsstring 'userid))
            (jsprop 'company t (jsstring 'company))
            (jsprop 'cue t (jsstring 'cue))
            (jsprop 'start-date t (jsstring 'data-inizio))
            (jsprop 'end-date t (jsstring 'data-fine))))


(data company-address
  (jsstring 'indirizzo))

(data company-format 
  (jsobject 'formato-compagnia
            (jsprop 'name t (jsstring 'nome))
            (jsprop 'addresses t company-address)))

(data subscriber-format
  (jsnumber 'sottoscrittore))

(data news-format 
  (jsobject 'formato-notizia
            (jsprop 'text t (jsstring 'testo-notizia))
            (jsprop 'start-date t (jsstring 'data-inizio))
            (jsprop 'end-date t (jsstring 'data-fine))
            (jsprop 'subscribers t (jsarray 'formato-sottoscrittore subscriber-format))))

(data document-format 
  (jsobject 'formato-documento
            (jsprop 'type t (jsstring 'tipo))
            (jsprop 'cue t (jsstring 'cue))
            (jsprop 'binary t (jsstring 'binario))))

(data auditing-format
  (jsobject 'formato-auditing
            (jsprop 'name t (jsstring 'nome-compagnia))))

(data black-format
  (jsobject 'formato-black
            (jsprop 'black-id t (jsstring 'id-black))
            (jsprop 'value t (jsstring 'valore-black))
            (jsprop 'type t (jsstring 'tipo-black))))

(data white-format
  (jsobject 'formato-white
            (jsprop 'value t (jsstring 'value-white))
            (jsprop 'type t (jsstring 'type-white))))


(data indicator-entity 
  (entity 'indicator-entity
          (primary-key 
           (attribute 'indicator-id 'string))
          (list (attribute 'code 'string)
                (attribute 'start-date 'string))))

(data parameter-entity
  (entity 'parameter-entity
          (primary-key 
           (attribute 'parameter-id 'string))
          (list (attribute 'name 'string)
                (attribute 'value 'string))
          (foreign-key 'indicator-entity 
                       (attribute 'indicator-id 'string))))

(data company-entity
  (entity 'company-entity
          (primary-key
           (attribute 'company-id 'integer))
          (list (attribute 'name 'string)
                (attribute 'address 'string))))

(data subscription-entity
  (entity 'subscription-entity
          (primary-key
           (attribute 'company-id 'integer)
           (attribute 'news-id 'integer))
          nil))

(data news-entity
  (entity 'news-entity
          (primary-key
           (attribute 'news-id 'integer))
          (list (attribute 'text 'string)
                (attribute 'start-date 'string)
                (attribute 'end-date 'string))))

(data document-entity
  (entity 'document-entity
          (primary-key
           (attribute 'document-id 'integer))
          (list (attribute 'type 'string)
                (attribute 'cue 'string)
                (attribute 'binary 'blob))))



(data accident-entity 
  (entity 'accident-entity
          (primary-key
           (attribute 'id-sini 'integer))
          (list (attribute 'data-accadimento 'string)
                (attribute 'data-denuncia 'string)
                (attribute 'data-definizione 'string)
                (attribute 'stato 'string)
                (attribute 'luogo 'string)
                (attribute 'ruolo 'string)
                (attribute 'intervento 'string)
                (attribute 'danni 'string)
                (attribute 'lesioni 'string)
                (attribute 'decessi 'string)
                (attribute 'errore 'string))))

(data inquiry-entity 
  (entity 'inquiry-entity
          (primary-key
           (attribute 'inquiry-id 'integer))
          (list (attribute 'plate 'string)
                (attribute 'userid 'string)
                (attribute 'company 'string)
                (attribute 'cue 'string)
                (attribute 'start-date 'string)
                (attribute 'end-date 'string))))

