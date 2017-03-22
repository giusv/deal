(application aia 
         (rest-application 'aia 
                           news-service
                           company-service
                           indicator-service))

(database aia-db 
  (db indicator-entity parameter-entity company-entity subscription-entity news-entity))
