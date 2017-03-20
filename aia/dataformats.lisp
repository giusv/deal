(data parameter-format
      (jsobject 'formato-parametro
                (jsprop 'name t (jsstring 'stringa-nome))
                (jsprop 'value t (jsstring 'stringa-valore))))

(data indicator-format 
    (jsobject 'formato-indicatore
              (jsprop 'name t (jsstring 'stringa-nome))
              (jsprop 'code t (jsstring 'stringa-codice))
              (jsprop 'start-date t (jsstring 'data-data-inizio))
              (jsprop 'parameters t (jsarray 'formato-parametro parameter-format))))

(data company-address
      (jsstring 'stringa-indirizzo))

(data company-format 
    (jsobject 'formato-compagnia
              (jsprop 'name t (jsstring 'stringa-nome))
              (jsprop 'addresses t company-address)))

(data subscriber-format
      (jsnumber 'sottoscrittore))

(data news-format 
    (jsobject 'formato-notizia
              (jsprop 'text t (jsstring 'testo-notizia))
              (jsprop 'start-date t (jsstring 'data-inizio) )
              (jsprop 'start-date t (jsstring 'data-fine))
              (jsprop 'subscribers t (jsarray 'formato-sottoscrittore subscriber-format))))

(data auditing-format
      (jsobject 'formato-auditing
                (jsprop 'name t (jsstring 'nome-compagnia))))

(data indicator-entity (entity 'indicator-entity
			       (primary-key 
				(attribute 'id 'string))
			       (list (attribute 'code 'string)
				     (attribute 'start-date 'string))))

(data company-entity (entity 'company-entity
                                  (primary-key
                                   (attribute 'id 'integer))
                                  (list (attribute 'name 'string)
                                        (attribute 'address 'string))))

