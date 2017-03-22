(data parameter-format
      (jsobject 'formato-parametro
                (jsprop 'name t (jsstring 'nome))
                (jsprop 'value t (jsstring 'valore))))

(data indicator-format 
    (jsobject 'formato-indicatore
              (jsprop 'name t (jsstring 'nome))
              (jsprop 'code t (jsstring 'codice))
              (jsprop 'start-date t (jsstring 'data-inizio))
              (jsprop 'parameters t (jsarray 'formato-parametro parameter-format))))

(data company-address
      (jsstring 'indirizzo))

(data company-format 
    (jsobject 'formato-compagnia
              (jsprop 'name t (jsstring 'nome))
              (jsprop 'addresses t company-address)))

(data subscriber-format
      (jsnumber 'sottoscrittore))

;; (data subscription-format
;;      (jsobject 'formato-sottoscrizione
;;               (jsprop 'news-id t (jsstring 'id-notizia))
;;               ))

(data news-format 
    (jsobject 'formato-notizia
              (jsprop 'text t (jsstring 'testo-notizia))
              (jsprop 'start-date t (jsstring 'data-inizio))
              (jsprop 'end-date t (jsstring 'data-fine))
              (jsprop 'subscribers t (jsarray 'formato-sottoscrittore subscriber-format))))

(data auditing-format
      (jsobject 'formato-auditing
                (jsprop 'name t (jsstring 'nome-compagnia))))


(data indicator-entity (entity 'indicator-entity
			       (primary-key 
				(attribute 'id 'string))
			       (list (attribute 'code 'string)
				     (attribute 'start-date 'string))))

(data parameter-entity (entity 'parameter-entity
			       (primary-key 
				(attribute 'id 'string))
			       (list (attribute 'name 'string)
				     (attribute 'value 'string))
                               (foreign-key 'indicator-entity 
                                            (attribute 'indicator-id 'string))))

(data company-entity (entity 'company-entity
                                  (primary-key
                                   (attribute 'id 'integer))
                                  (list (attribute 'name 'string)
                                        (attribute 'address 'string))))

(data subscription-entity (entity 'subscription-entity
                                  (primary-key
                                   (attribute 'company-id 'integer)
                                   (attribute 'news-id 'integer))
                                  nil))

(data news-entity (entity 'news-entity
                          (primary-key
                           (attribute 'id 'integer))
                          (list (attribute 'text 'string)
                                (attribute 'start-date 'string)
                                (attribute 'end-date 'string))))

