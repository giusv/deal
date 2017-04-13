(process indicator-batch 
  (with-description* "Processo di calcolo degli indicatori, schedulato giornalmente"
    (batch :name 'calcola-indicatori
           :command (concat*
                     (indicators (query2 (project 
                                          (restrict (relation 'indicator-entity) 
                                                    (+greater-than+ (current-date) (prop 'data-inizio)))
                                          'codice-oggetto)))
                     (executable (assemble2 indicators))
                     (result (execute2 executable))))))


(service indcalc-service
  (batch-service 'batch-indicatori
                 (batch-endpoint 'calcolo-indicatori indicator-batch)))
