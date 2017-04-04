(element black-white-section
  (with-doc "La sezione di gestione delle black/white list. Qui l'utente può visualizzare, modificare in inserimento e cancellazione le black list e le white list"
    (hub-spoke ((black-list "Black list" black-section)
                (white-list "White list" white-section))
               :aia
               (with-doc "Sequenza di pannelli di scelta"
                 (horz black-list white-list)))))




