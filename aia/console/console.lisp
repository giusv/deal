(element navbar 
  (with-doc "La barra di navigazione principale: essa consente all'utente di navigare tra tutte le funzionalità della console"
    (navbar* (anchor* (const "Amministrazione") :click (target (url `(admin))))
             (anchor* (const "Specifica indicatori") :click (target (url `(ind-spec)))))))



;;; main 
(element main-space 
  (with-doc "La sezione principale della console. Qui l'utente ha a disposizione un menu di possibili scelte da effettuare, ciascuna delle quali lo reindirizza verso la pagina corrispondente"
    (hub-spoke ((gestione-indicatori "Gestione Indicatori" indicator-section)
                (gestione-compagnie "Gestione compagnie" company-section)
                (gestione-notizie "Gestione notizie" news-section)
                (gestione-autorizzazioni "Gestione autorizzazioni" authmanage-section)
                (auditing-inquiry "Auditing accessi per inquiry" inquiry-audit-section)
                (auditing-piattaforma "Auditing accessi a piattaforma di scambio" platform-audit-section)
                (gestione-black-white-list "White/Black list" black-white-section)
                (gestione-batch "Gestione batch" batch-section))
               :aia
               (with-doc "Sequenza di pannelli di scelta"
                 (vert (with-doc "Riga 1" (horz gestione-indicatori gestione-compagnie gestione-notizie)) 
                       (with-doc "Riga 2" (horz gestione-autorizzazioni auditing-inquiry auditing-piattaforma)))))))
(element console
  (with-description "La console di amministrazione consente all'utente di specificare nuovi indicatori e variarne i parametri, gestire le autorizzazioni verso le compagnie esterne, visualizzare i dati di auditing degli accessi in ricerca dati e scambio documenti, gestire white list e black list etc."
    (vert navbar main-space)))


