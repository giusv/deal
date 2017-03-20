(element navbar 
  (with-doc "La barra di navigazione principale: essa consente all'utente di navigare tra tutte le funzionalità della console"
    (navbar* (anchor* (const "Amministrazione") :click (target (url `(admin))))
             (anchor* (const "Specifica indicatori") :click (target (url `(ind-spec)))))))

(element admin-section
  (with-doc "La sezione di amministrazione. Qui l'utente può gestire le autorizzazioni verso le compagnie esterne, etc."
    (label (const "Amministrazione"))))

;;; main 
(element main-space 
  (with-doc "La sezione principale della console. Qui l'utente ha a disposizione un menu di possibili scelte da effettuare, ciascuna delle quali lo reindirizza verso la pagina corrispondente"
    (hub-spoke ((administration "Amministrazione" admin-section)
                (indicator-management "Indicatori" indicator-section)
                (company-management "Compagnie" company-section)
                (news-management "Notizie" news-section)
                )
               nil
               (with-doc "Sequenza di pannelli di scelta"
                 (horz administration indicator-management company-management)))))
(element console
  (with-doc "La console di amministrazione consente all'utente
         di gestire le autorizzazioni, specificare nuovi indicatori e
         variarne i parametri."
    (vert navbar main-space)))

(write-file "d:/giusv/temp/console.html" 
	    (synth to-string 
		   (synth to-doc (html nil 
				       (head nil 
					     (title nil (text "console"))
					     (meta (list :charset "utf-8"))
                                             (script (list :src "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.10.0/highlight.min.js") (empty))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css")))
				       (apply #'body nil
                                              (h1 nil (text "archivio integrato antifrode"))
                                              (h2 nil (text "requisiti funzionali console amministrazione"))
                                              (synth to-html console (void-url))
                                              (synth req console (void-url))))) 0))
