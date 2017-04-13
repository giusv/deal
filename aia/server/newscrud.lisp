(process create-news 
  (with-description* "Endpoint REST utilizzato per la creazione di una notizia che sar&agrave; visualizzata nella pagina home del portale destinato alle compagnie."
    (sync-server :name 'crea-notizia :input news-format :command
                (with-extraction-and-validation news-format 
                    ((testo (required) (minlen 2))
                     (data-inizio (required))
                     (data-fine (required)))
                  (news (create-instance2 news-entity
                                          (list (prop 'testo) testo
                                                (prop 'data-inizio) data-inizio
                                                (prop 'data-fine)  data-fine)))
                  ((map-command (mu* sottoscrittore 
                                     (concat*
                                      (subscription (create-instance2 subscription-entity
                                                                      (list (prop 'id-notizia) (attr news 'id)
                                                                            (prop 'id-compagnia) (argument sottoscrittore))))))
                                (filter (prop 'sottoscrittori)
                                        news-format)))
                  ((http-response 201))))))

(process remove-news
  (let* ((news-id (path-parameter 'news)))
    (with-description* "Endpoint REST utilizzato per la cancellazione di una notizia visualizzata nella pagina home del portale destinato alle compagnie."
      (sync-server
      :name 'rimuovi-notizia
      :parameters (list news-id) 
      :command (concat* (news-valid (validate2 news-id (list (regex "[0..9]+"))))
                        ((fork news-valid
                               (concat* 
                                ((erase2 news-entity news-id))
                                (subscriptions (query2 (project 
                                                        (restrict (equijoin (relation 'news-entity) 
                                                                            (relation 'subscription-entity) :id-notizia)
                                                                  (+equal+ (prop 'id-notizia) (value news-id)))
                                                        'id-notizia)))
                                ((map-command (mu* sottoscrizione
                                                   (erase2 subscription-entity (argument sottoscrizione)))
                                              subscriptions))
                                ((http-response 204)))
                               (http-response 400))))))))
(process update-news
  (let* ((news-id (path-parameter 'id-notizia)))
    (with-description* "Endpoint REST utilizzato per la modifica di una notizia visualizzata nella pagina home del portale destinato alle compagnie."
      (sync-server 
      :name 'modifica-notizia
      :parameters (list news-id) 
      :input news-format
      :command (concat*
                (news-valid (validate2 news-id (list (regex "[0..9]+"))))
                ((fork news-valid
                       (concat*
                        (subscriptions (query2 (project 
                                                (restrict (equijoin (relation 'news-entity) 
                                                                    (relation 'subscription-entity) :id-notizia)
                                                          (+equal+ (prop 'id-notizia) (value news-id)))
                                                'id-notizia)))
                        ((map-command (mu* sottoscrizione
                                           (erase2 subscription-entity (argument sottoscrizione)))
                                      subscriptions))
                        ((with-extraction-and-validation news-format 
                             ((testo (required) (minlen 2))
                              (data-inizio (required))
                              (data-fine (required))) 
                           (old-news (fetch2 news-entity :id news-id))
                           (new-news (update-instance2 
                                      news-entity 
                                      old-news
                                      (list (prop 'testo) testo
                                            (prop 'data-inizio) data-inizio
                                            (prop 'data-fine) data-fine))) 
                           ((map-command (mu* sottoscrittore 
                                              (concat*
                                               (subscription (create-instance2 
                                                              subscription-entity
                                                              (list (prop 'id-notizia) (attr new-news 'id)
                                                                    (prop 'id-compagnia) (argument sottoscrittore))))))
                                         (filter (prop 'sottoscrittori)
                                                 news-format)))
                           ((http-response 200)))))
                       (http-response 400))))))))

(process read-news
  (let* ((news (path-parameter 'news)))
    (with-description* "Endpoint REST utilizzato per la lettura dei dettagli di una notizia visualizzata nella pagina home del portale destinato alle compagnie."
      (sync-server 
      :name 'leggi-notizia
      :parameters (list news) 
      :command (concat* (news (query2 (equijoin (relation 'news-entity) (relation 'subscription-entity)
                                                :id-notizia)))
                        (json (rel-to-json2 news 
                                            (list 'testo 'data-inizio 'data-fine)
                                            :group (list 'id-compagnia))) 
                        ((http-response 200 :payload json)))))))
(process list-news
  (let* ((compagnia (query-parameter 'compagnia)))
    (with-description* "Endpoint REST utilizzato per ottenere la lista di tutte le notizie destinate a una certa compagnia, a fini di visualizzazione nella pagina home del portale."
      (sync-server 
      :name 'lista-notizie
      :parameters (list compagnia)
      :command (concat* (news (query2 (restrict (equijoin (relation 'news-entity) (relation 'subscription-entity)
                                                          :id-notizia)
                                                (+and+ (+equal+ (prop 'id-compagnia) compagnia)
                                                       (+greater-than+ (current-date) (prop 'data-inizio))
                                                       (+less-than+ (current-date) (prop 'data-fine))))))
                        (json (rel-to-json2 news 
                                            (list 'testo 'data-inizio 'data-fine)
                                            :group (list 'id-compagnia)))
                        ((http-response 200 :payload json)))))))

(service news-service 
  (rest-service 'servizio-news 
                (url `(aia))
                (rest-post (url `(notizie)) create-news)
                (rest-delete (url `(notizie / id)) remove-news)
                (rest-put (url `(notizie / id)) update-news)
                (rest-get (url `(notizie)) list-news)
                (rest-get (url `(notizie / id)) read-news)))


