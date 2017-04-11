(write-file "d:/giusv/temp/requisiti.html" 
	    (synth to-string (synth to-doc 
                                    (html nil 
                                          (head nil 
                                                (title nil (text "Archivio Integrato Antifrode"))
                                                (meta (list :charset "utf-8"))
                                                (link (list :rel "stylesheet" 
                                                            :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"))
                                                (link (list :rel "stylesheet" :href "style.css")))
                                          (body nil
                                                (section nil 
                                                         (h2 nil (text "Portale")) 
                                                         (apply #'section nil 
                                                                (h3 nil (text "Sito Web"))
                                                                (synth to-html website (void-url))
                                                                (synth req website (void-url)))
                                                         (apply #'section nil 
                                                                (h3 nil (text "Console di gestione"))
                                                                (synth to-html console (void-url))
                                                                (synth req console (void-url)))
                                                         (section nil 
                                                                  (h3 nil (text "Backend"))
                                                                  (synth to-html aia))
                                                         (section nil 
                                                                  (h3 nil (text "Indicatori"))
                                                                  (synth to-production linguaggio))
                                                         (section nil 
                                                                  (h3 nil (text "Dizionario dati"))
                                                                  (synth to-html aia-db)))))) 0))

