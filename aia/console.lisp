(element navbar 
         (with-doc "La barra di navigazione principale: essa consente all'utente di navigare tra tutte le funzionalità della console"
           (navbar* (anchor* (const "Amministrazione") :click (target (url `(admin))))
                    (anchor* (const "Specifica indicatori") :click (target (url `(ind-spec)))))))

(element admin-section ;; "sezione di amministrazione"
         (label (const "Amministrazione")))

(defun post-ind-spec (payload)
  (concat* (response (http-post* (const "www.ivass.it/aia/indspec") payload))
           ((fork (+equal+ response (const 201))
                  (target (url `(ind-list)))
                  (target (url `(ind-error)))))))

(element indicator-form ;; "form per la specifica di un nuovo indicatore dinamico"
         (with-doc "Il form di inserimento della specifica di un nuovo indicatore"(vert* (ind (obj* 'ind-data indicator-format 
                            ((code codice (textarea* (const "Codice indicatore")))
                             (start-date data-inizio (input* (const "Data inizio validità"))))
                            (vert code start-date)))
                 ((button* (const "Invio") :click (post-ind-spec (payload ind)))))))

(element indicator-list ;;"lista di indicatori presenti"
         (label (const "indicator list")))

(element ind-section
         (with-doc "La sezione di gestione indicatori. L'utente può specificarne di nuovi e modificare i parameteri di quelli esistenti" 
           (alt indicator-list
                (static2 :ind-form nil indicator-form)))) 

(element main-space 
         (with-doc "La sezione principale della console. Qui l'utente ha a disposizione un menu di possibili scelte da effettuare, ciascuna delle quali lo reindirizza verso la pagina corrispondente"
           (hub-spoke ((admin "Amministrazione" admin-section)
                       (ind-mgmt "Indicatori" ind-section))
                      nil
                      (with-doc "Sequenza di pannelli di scelta"(horz admin ind-mgmt)))))
(element console ;; "console di amministrazione"
         (with-doc "La console di amministrazione consente all'utente di gestire le autorizzazioni, specificare nuovi indicatori e variarne i parametri."
           (vert navbar main-space)))

(write-file "d:/giusv/temp/console.html" 
	    (synth to-string 
		   (synth to-doc (html nil 
				       (head nil 
					     (title nil (text "console"))
					     (meta (list :charset "utf-8"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css")))
				       (apply #'body nil
                                              (h1 nil (text "archivio integrato antifrode"))
                                              (h2 nil (text "requisiti funzionali console amministrazione"))
                                              (synth to-html console (void-url))
                                              (synth req console (void-url))))) 0))
