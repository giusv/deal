(element navbar 
  (with-doc "La barra di navigazione principale: essa consente all'utente di navigare tra tutte le funzionalità della console"
    (navbar* (anchor* (const "Amministrazione") :click (target (url `(admin))))
             (anchor* (const "Specifica indicatori") :click (target (url `(ind-spec)))))))

(element admin-section
  (with-description "La sezione di amministrazione. Qui l'utente può gestire le autorizzazioni verso le compagnie esterne, etc."
    (label (const "Amministrazione"))))

;;; main 
(element main-space 
  (with-doc "La sezione principale della console. Qui l'utente ha a disposizione un menu di possibili scelte da effettuare, ciascuna delle quali lo reindirizza verso la pagina corrispondente"
    (hub-spoke ((administration "Amministrazione" admin-section)
                (indicator-management "Indicatori" indicator-section)
                (company-management "Compagnie" company-section)
                (news-management "Notizie" news-section)
                )
               nil
               (with-doc "Sequenza di pannelli di scelta"
                 (horz administration indicator-management company-management)))))
(element console
  (with-description "La console di amministrazione consente all'utente
         di gestire le autorizzazioni, specificare nuovi indicatori e
         variarne i parametri."
    (vert navbar main-space)))


