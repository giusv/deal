(element navbar 
  (with-doc "La barra di navigazione principale: essa consente all'utente di navigare tra tutte le funzionalità della console"
    (navbar* (anchor* (const "Amministrazione") :click (target (url `(admin))))
             (anchor* (const "Specifica indicatori") :click (target (url `(ind-spec)))))))

(element admin-section
  (with-doc "La sezione di amministrazione. Qui l'utente può gestire le autorizzazioni verso le compagnie esterne, etc."
    (label (const "Amministrazione"))))

(defun post-ind-spec (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (const "www.ivass.it/aia/indspec") payload))
             ((fork (+equal+ response (const 201))
                    (target (url `(indicator-management)))
                    (target (url `(indicator-error))))))))

(element indicator-form
  (with-doc "Il form di inserimento della specifica di un nuovo indicatore"
    (vert* (ind (obj* 'ind-data indicator-format 
                      ((code code (textarea* (const "Codice indicatore")))
                       (start-date start-date (input* (const "Data inizio validità"))))
                      (vert code start-date)))
           ((button* (const "Invio") :click (post-ind-spec (payload ind)))))))

(element indicator-error 
  (with-doc "Pagina visualizzata in presenza di errori nella specifica del nuovo indicatore"
    (vert (label (const "Errore nella specifica dell'indicatore!"))
          (button* (const "Indietro") :click (target (url `(indicator-management)))))))

(element indicator-specification 
  (with-doc "La sezione in cui l'utente può specificare un nuovo indicatore"
    (alt indicator-form
         (static2 :indicator-error nil indicator-error))))

(element indicator-list 
  (with-doc "Vista di tutti gli indicatori specificati dall'utente."
    (table* indicator-format
        ('nome name (label it))
        ('codice code (label it))
        ('data-inizio start-date (label it))
        ('dettagli nil (button* (const "dettagli") :click (target (url `(indicator-management / { ,(value (prop 'name)) }))))))))

(defun indicator-details (indicator)
    (with-doc "La sezione con i dettagli di un indicatore selezionato"
      (label indicator)))
(element indicator-section
  (with-doc "La sezione di gestione indicatori. L'utente può specificarne di nuovi e modificare i parameteri di quelli esistenti" 
    (alt indicator-list
         (dynamic2 indicator (indicator-details indicator))
         (static2 :indicator-specification nil indicator-specification)))) 

(element main-space 
  (with-doc "La sezione principale della console. Qui l'utente ha a disposizione un menu di possibili scelte da effettuare, ciascuna delle quali lo reindirizza verso la pagina corrispondente"
    (hub-spoke ((administration "Amministrazione" admin-section)
                (indicator-management "Indicatori" indicator-section))
               nil
               (with-doc "Sequenza di pannelli di scelta"
                 (horz administration indicator-management)))))
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
