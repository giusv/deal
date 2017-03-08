(data indicator-format 
    (jsobject 'formato-indicatore
              (jsprop 'codice t (jsstring 'stringa-codice))
              (jsprop 'data-inizio t (jsstring 'data-data-inizio))))

(data company-format 
    (jsobject 'formato-compagnia
              (jsprop 'name t (jsstring 'stringa-nome))
              (jsprop 'address t (jsstring 'stringa-indirizzo))))



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
