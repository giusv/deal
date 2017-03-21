(write-file "d:/giusv/temp/console.html" 
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
                                              (h1 nil (text "archivio integrato antifrode"))
                                              (h2 nil (text "requisiti funzionali console amministrazione"))
                                              (synth to-html console (void-url))
                                              (synth req console (void-url))))) 0))
