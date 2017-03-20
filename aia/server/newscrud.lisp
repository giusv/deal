(process get-subscriber 
         (auxiliary 
          :name 'get-subscriber
          :input subscriber-format
          :command (concat* (subscriber-id (extract2 (prop 'text) news-format)))))
(process create-news 
         (sync-server
          :name 'create-news
          :input news-format
          :command (concat* (news-text (extract2 (prop 'text) news-format))
                            (news-start-date (extract2 (prop 'start-date) news-format))
                            (news-end-date (extract2 (prop 'end-date) news-format))
                            (news-text-valid (validate2 news-text (list (required) (minlen 2) (maxlen 5))))
                            (subscribers (map-process get-subscriber (extract2 (prop 'subscribers) news-format)))
                            (news-start-date-valid (validate2 news-start-date (list (regex "[0..9]+"))))
                            ((fork (+and+ news-text-valid news-start-date-valid) 
                                   (concat* 
                                    (news (create-instance2 news-entity 
                                                               (list (prop 'id) (autokey)
                                                                     (prop 'text) news-text
                                                                     (prop 'start-date) news-start-date
                                                                     (prop 'end-date) news-end-date))) 
                                    ((persist news))
                                    
                                    ((http-response 201 :payload (value news))))
                                   (http-response 403))))))

(process remove-news
         (let* ((comp (path-parameter 'news)))
           (sync-server
            :name 'remove-news
            :parameters (list comp) 
            :command (concat* (comp-valid (validate2 comp (list (regex "[0..9]+"))))
                              ((fork comp-valid
                                     (concat* 
                                      ((erase2 news-entity comp)) 
                                      ((http-response 204)))
                                     (http-response 400)))))))

(process modify-news
         (let* ((comp (path-parameter 'news)))
           (sync-server 
            :name 'modify-news
            :parameters (list comp) 
            :input news-format
            :command (concat* (comp-valid (validate2 comp (list (regex "[0..9]+"))))
                              (news-text (extract2 (prop 'text) news-format))
                              (news-start-date (extract2 (prop 'start-date) news-format))
                              (news-end-date (extract2 (prop 'end-date) news-format))
                              (news-text-valid (validate2 news-text (list (required) (minlen 2) (maxlen 5))))
                              (news-start-date-valid (validate2 news-start-date (list (regex "[0..9]+"))))
                              ((fork (+and+ comp-valid news-text-valid news-start-date-valid) 
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
                       (rest-post (url `(compagnie)) create-news)
                       (rest-delete (url `(compagnie / id)) remove-news)
                       (rest-put (url `(compagnie / id)) modify-news)))

(write-file "d:/giusv/temp/server.html" 
	    (synth to-string 
		   (synth to-doc (html nil 
				       (head nil 
					     (title nil (text "Server"))
					     (meta (list :charset "utf-8"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css")))
				       (body nil
					     (h1 nil (text "Archivio Integrato Antifrode"))
					     (h2 nil (text "Requisiti funzionali processo acquisizione indicatori"))
					     (synth to-html news-service)))) 0))
