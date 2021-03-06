(application aia 
  (rest-application 'aia 
                    news-service
                    company-service
                    document-service
                    indicator-service
                    black-service
                    white-service
                    inquiry-service
                    report-service
                    indcalc-service))

(database aia-db 
  (db 'database indicator-entity parameter-entity company-entity subscription-entity news-entity document-entity 
      dossier-entity accident-entity inquiry-entity black-entity white-entity person-entity vehicle-entity report-entity vehicle-indicator-value-entity accident-indicator-value-entity))

(database aia-interface
  (db 'interfaccia report-format company-id-format dossier-format role-format person-format indicator-value-format 
      vehicle-format accident-format parameter-format indicator-parameter-array-format 
      indicator-format inquiry-format company-address-format company-format subscriber-format news-format document-format black-format white-format))
