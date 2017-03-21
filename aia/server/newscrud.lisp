(defun create-subscription (news-id)
  (create* subscription nil nil
         ((subscriber-number (this) (prop 'company-id) ((minlen 2))))
         ((prop 'news-id) news-id)))

(defun remove-subscription (news-id)
  (sync-server
   :name 'create-subscription
   :input subscriber-format
   :command (concat* (subscriber-number (extract2 (this) subscriber-format))
                     (subscriber-number-valid (validate2 subscriber-number (list (minlen 2) (maxlen 5)))) 
                     ((fork (+equal+ subscriber-number-valid (+true+)) 
                            (concat* 
                             (subscription (create-instance2 subscription-entity 
                                                             (list (prop 'news-id) news-id
                                                                   (prop 'company-id) subscriber-number))) 
                             ((persist subscription)))
                            (http-response 403)))))) 

(defun remove-all-subscriptions (news)
  (sync-server
   :name 'remove-all-subscriptions
   :command (concat* (news-valid (validate2 news (list (regex "[0..9]+"))))
                     ((fork news-valid
                            (concat* 
                             ((map-command (erase2 news-entity news))) 
                             ((http-response 204)))
                            (http-response 400))))))

(process create-news 
  (create* news news-format (prop 'id)
           ((text (prop 'text) (prop 'text) ((required) (minlen 2)))
            (start-date (prop 'start-date) (prop 'start-date) ((required) (minlen 2)))
            (end-date (prop 'end-date) (prop 'end-date) ((required) (minlen 2))))
           nil
           (map-command (create-subscription (attr news 'id)) (filter (prop 'subscribers) news-format))))

(process remove-news
  (let* ((news (path-parameter 'news)))
    (sync-server
     :name 'remove-news
     :parameters (list news) 
     :command (concat* (news-valid (validate2 news (list (regex "[0..9]+"))))
                       ((fork news-valid
                              (concat* 
                               ((erase2 news-entity news)) 
                               ((http-response 204)))
                              (http-response 400)))))))

(process modify-news
  (let* ((news (path-parameter 'news)))
    (sync-server 
     :name 'modify-news
     :parameters (list news) 
     :input news-format
     :command (concat* (news-valid (validate2 news (list (regex "[0..9]+"))))
                       (news-text (extract2 (prop 'text) news-format))
                       (news-start-date (extract2 (prop 'start-date) news-format))
                       (news-end-date (extract2 (prop 'end-date) news-format))
                       (news-text-valid (validate2 news-text (list (required) (minlen 2) (maxlen 5))))
                       (news-start-date-valid (validate2 news-start-date (list (regex "[0..9]+"))))
                       ((fork (+and+ news-valid news-text-valid news-start-date-valid) 
                              (concat* 
                               (news (create-instance2 news-entity 
                                                       (list (prop 'id) (autokey) 
                                                             (prop 'text) news-text
                                                             (prop 'start-date) news-start-date
                                                             (prop 'end-date) news-end-date))) 
                               ((persist news)) 
                               ((http-response 201 :payload news)))
                              (http-response 403)))))))

(service news-service 
         (rest-service 'news-service 
                       (url `(aia))
                       (rest-post (url `(notizie)) create-news)
                       (rest-delete (url `(notizie / id)) remove-news)
                       (rest-put (url `(notizie / id)) modify-news)))


