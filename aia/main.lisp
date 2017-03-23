(write-file "d:/giusv/temp/website.html" 
	    (synth to-string 
		   (synth to-doc (html nil 
				       (head nil 
					     (title nil (text "console"))
					     (meta (list :charset "utf-8"))
                                             ;; (script (list :src "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.10.0/highlight.min.js") (empty))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"))
					     ;; (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css"))
                                             )
				       (apply #'body nil
                                              (h1 nil (text "Archivio Integrato Antifrode"))
                                              ;; (h2 nil (text "requisiti funzionali console amministrazione"))
                                              (synth to-html website (void-url))
                                              (synth req website (void-url))))) 0))

(write-file "d:/giusv/temp/server.html" 
	    (synth to-string 
		   (synth to-doc (html nil 
				       (head nil 
					     (title nil (text "console"))
					     (meta (list :charset "utf-8"))
                                             ;; (script (list :src "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.10.0/highlight.min.js") (empty))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"))
					     ;; (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css"))
                                             )
				       (body nil
                                              (h1 nil (text "Archivio Integrato Antifrode"))
                                              ;; (h2 nil (text "requisiti funzionali console amministrazione"))
                                              (synth to-html aia)))) 0))
