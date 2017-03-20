;;; Indicator section

(defun post-ind-spec (payload)
  (with-doc* "Effettua l'upload dei dati inseriti, verificandone la corretta acquisizione dal server"
    (concat* (response (http-post* (url `(aia / indicators)) payload))
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

(element indicator-parameters-form
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

