(process create-news 
  (sync-server :name 'create-news :input news-format :command
               (concat* (news-text (extract2 (prop 'text) news-format))
                        (news-text-valid (validate2 news-text (list (required) (minlen 2))))
                        (news-start-date (extract2 (prop 'start-date) news-format))
                        (news-start-date-valid (validate2 news-start-date (list (required) (minlen 2))))
                        (news-end-date (extract2 (prop 'end-date) news-format))
                        (news-end-date-valid (validate2 news-end-date (list (required) (minlen 2))))
                        ((fork
                          (+and+ news-text-valid news-start-date-valid news-end-date-valid)
                          (concat*
                           (news (create-instance2 news-entity
                                                   (list (prop 'id) (autokey)
                                                         (prop 'text) news-text
                                                         (prop 'start-date)
                                                         news-start-date
                                                         (prop 'end-date)
                                                         news-end-date)))
                           ((persist news))
                           ((map-command (mu* subscriber 
                                              (concat*
                                               (subscription (create-instance2 subscription-entity
                                                                  (list (prop 'news-id) (attr news 'id)
                                                                        (prop 'company-id) (argument subscriber))))
                                               ((persist subscription))))
                                         (filter (prop 'subscribers)
                                                 news-format)))
                           ((http-response 201 :payload (value news))))
                          (http-response 403))))))

;; (create* news news-format (prop 'id)
;;            ((text (prop 'text) (prop 'text) ((required) (minlen 2)))
;;             (start-date (prop 'start-date) (prop 'start-date) ((required) (minlen 2)))
;;             (end-date (prop 'end-date) (prop 'end-date) ((required) (minlen 2))))
;;            nil
;;            (map-command (mu* subscriber nil) (filter (prop 'subscribers) news-format)))


(process remove-news
  (let* ((news (path-parameter 'news)))
    (sync-server
     :name 'remove-news
     :parameters (list news) 
     :command (concat* (news-valid (validate2 news (list (regex "[0..9]+"))))
                       ((fork news-valid
                              (concat* 
                               ((erase2 news-entity news))
                               (subscriptions (fetch2 subscription-entity :id news))
                               ((map-command (mu* subscription 
                                                  (erase2 subscription-entity (argument subscription)))
                                             subscriptions))
                               ((http-response 204)))
                              (http-response 400)))))))

(process modify-news
  (let* ((news-id (path-parameter 'news-id)))
    (sync-server 
     :name 'modify-news
     :parameters (list news-id) 
     :input news-format
     :command (concat* (news-valid (validate2 news-id (list (regex "[0..9]+"))))
                       ((fork news-valid
                              (concat* 
                               ((erase2 news-entity news-id))
                               (subscriptions (fetch2 subscription-entity :id news-id))
                               ((map-command (mu* subscription 
                                                  (erase2 subscription-entity (argument subscription)))
                                             subscriptions)))
                              (http-response 400)))
                       (news-text (extract2 (prop 'text) news-format))
                       (news-text-valid (validate2 news-text (list (required) (minlen 2))))
                       (news-start-date (extract2 (prop 'start-date) news-format))
                       (news-start-date-valid (validate2 news-start-date (list (required) (minlen 2))))
                       (news-end-date (extract2 (prop 'end-date) news-format))
                       (news-end-date-valid (validate2 news-end-date (list (required) (minlen 2))))
                       ((fork
                         (+and+ news-text-valid news-start-date-valid news-end-date-valid)
                         (concat*
                          (news (create-instance2 news-entity
                                                  (list (prop 'id) news-id
                                                        (prop 'text) news-text
                                                        (prop 'start-date)
                                                        news-start-date
                                                        (prop 'end-date)
                                                        news-end-date)))
                          ((persist news))
                          ((map-command (mu* subscriber 
                                             (concat*
                                              (subscription (create-instance2 subscription-entity
                                                                              (list (prop 'news-id) (attr news 'id)
                                                                                    (prop 'company-id) (argument subscriber))))
                                              ((persist subscription))))
                                        (filter (prop 'subscribers)
                                                news-format)))
                          ((http-response 201 :payload (value news))))
                         (http-response 403)))))))

(service news-service 
         (rest-service 'news-service 
                       (url `(aia))
                       (rest-post (url `(notizie)) create-news)
                       (rest-delete (url `(notizie / id)) remove-news)
                       (rest-put (url `(notizie / id)) modify-news)))


