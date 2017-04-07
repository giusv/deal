(process create-news 
  (sync-server :name 'create-news :input news-format :command
               (with-extraction-and-validation news-format 
                   ((text (required) (minlen 2))
                    (start-date (required))
                    (end-date (required)))
                 (news (create-instance2 news-entity
                                         (list (prop 'text) text
                                               (prop 'start-date) start-date
                                               (prop 'end-date)  end-date)))
                 ((map-command (mu* subscriber 
                                    (concat*
                                     (subscription (create-instance2 subscription-entity
                                                                     (list (prop 'news-id) (attr news 'id)
                                                                           (prop 'company-id) (argument subscriber))))))
                               (filter (prop 'subscribers)
                                       news-format)))
                 ((http-response 201)))))

(process remove-news
  (let* ((news-id (path-parameter 'news)))
    (sync-server
     :name 'remove-news
     :parameters (list news-id) 
     :command (concat* (news-valid (validate2 news-id (list (regex "[0..9]+"))))
                       ((fork news-valid
                              (concat* 
                               ((erase2 news-entity news-id))
                               (subscriptions (query2 (project 
                                               (restrict (equijoin (relation 'news-entity) 
                                                                   (relation 'subscription-entity) :news-id)
                                                         (+equal+ (prop 'news-id) (value news-id)))
                                               'news-id)))
                               ((map-command (mu* subscription 
                                                  (erase2 subscription-entity (argument subscription)))
                                             subscriptions))
                               ((http-response 204)))
                              (http-response 400)))))))
(process update-news
  (let* ((news-id (path-parameter 'news-id)))
    (sync-server 
     :name 'update-news
     :parameters (list news-id) 
     :input news-format
     :command (concat*
               (news-valid (validate2 news-id (list (regex "[0..9]+"))))
               ((fork news-valid
                      (concat*
                       (subscriptions (query2 (project 
                                               (restrict (equijoin (relation 'news-entity) 
                                                                   (relation 'subscription-entity) :news-id)
                                                         (+equal+ (prop 'news-id) (value news-id)))
                                               'news-id)))
                       ((map-command (mu* subscription 
                                          (erase2 subscription-entity (argument subscription)))
                                     subscriptions))
                       ((with-extraction-and-validation news-format 
                            ((text (required) (minlen 2))
                             (start-date (required))
                             (end-date (required))) 
                          (old-news (fetch2 news-entity :id news-id))
                          (new-news (update-instance2 
                                     news-entity 
                                     old-news
                                     (list (prop 'text) text
                                           (prop 'start-date) start-date
                                           (prop 'end-date) end-date))) 
                          ((map-command (mu* subscriber 
                                             (concat*
                                              (subscription (create-instance2 
                                                             subscription-entity
                                                             (list (prop 'news-id) (attr new-news 'id)
                                                                   (prop 'company-id) (argument subscriber))))))
                                        (filter (prop 'subscribers)
                                                news-format)))
                          ((http-response 200)))))
                      (http-response 400)))))))

(process read-news
  (let* ((news (path-parameter 'news)))
    (sync-server 
     :name 'read-news
     :parameters (list news) 
     :command (concat* (news (query2 (equijoin (relation 'news-entity) (relation 'subscription-entity)
                                               :news-id)))
                       (json (rel-to-json2 news 
                                           (list 'text 'start-date 'end-date)
                                           :group (list 'company-id))) 
                       ((http-response 200 :payload json))))))
(process list-news
  (let* ((start-date (query-parameter 'start-date))
         (end-date (query-parameter 'end-date))
         (company (query-parameter 'company)))
    (sync-server 
     :name 'list-news
     :parameters (list start-date end-date company)
     :command (concat* (news (query2 (restrict (equijoin (relation 'news-entity) (relation 'subscription-entity)
                                                         :news-id)
                                               (+and+ (+equal+ (prop 'company-id) company )
                                                      (+greater-than+ (current-date) (prop 'start-date))
                                                      (+less-than+ (current-date) (prop 'end-date))))))
                       (json (rel-to-json2 news 
                                           (list 'text 'start-date 'end-date)
                                           :group (list 'company-id)))
                       ((http-response 200 :payload json))))))

(service news-service 
         (rest-service 'news-service 
                       (url `(aia))
                       (rest-post (url `(notizie)) create-news)
                       (rest-delete (url `(notizie / id)) remove-news)
                       (rest-put (url `(notizie / id)) update-news)
                       (rest-get (url `(notizie)) list-news)
                       (rest-get (url `(notizie / id)) read-news)))


