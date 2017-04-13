(element cue-form
  (with-doc "Il form di inserimento dati relativi alla ricerca per cue"
    (vert* (cue (gui-input 'cue (const "Cue")))
           ((gui-button 'invio (const "Invio") 
                        :click (target (url `(home / ricerca-per-cue / sinistri-cue
                                                   ? cue =  { ,(value cue ) }))))))))

(defun cue-search-results (cue)
  (with-doc "La pagina di risultati della ricerca per cue"
    (with-data* ((accidents (remote 'accident-data accident-format 
                                    (url `(aia / sinistri
                                               ? cue =  { ,(value cue) })))))
      (panel 'risultati-ricerca-per-cue (label (cat (const "Ricerca per cue") (value cue)))
             (vert (tabular 'sinistri accidents (acc-row)
                     ('data-accadimento (label (attr acc-row 'data-accadimento)))
                     ('stato (label (attr acc-row 'stato)))
                     ('luogo (label (attr acc-row 'luogo)))
                     ;; ('ruolo (label (attr acc-row 'ruolo)))
                     ('intervento (label (attr acc-row 'intervento)))
                     ('danni-/-lesioni-/-decessi (label (cat (attr acc-row 'danni) (const "/")
                                                             (attr acc-row 'lesioni) (const "/")
                                                             (attr acc-row 'decessi))))
                     ('dettagli (gui-button 'dettagli (const "Dettagli") :click (target (url `(home / sinistri / { ,(value (filter (prop 'id-sinistro) acc-row)) })))))))))))

(element cue-section
  (with-doc "La sezione di ricerca basata su codice unico evento)"
    (alt cue-form
         (static2 :ricerca-cue (cue) (cue-search-results cue)))))
