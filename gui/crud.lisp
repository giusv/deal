(defmacro crud (name format base &key render-summary render-details)
  
;; `(labels ((cs (&rest strings) (apply #'concatenate 'string strings))
  ;;          (post () (symb "POST-" ,name)))
  ;;   (progn (defun (post) (payload)
  ;;             (with-doc* ,(cs "Effettua l'upload dei dati inseriti per l'oggetto" 
  ;;                             (lower-camel name)
  ;;                             ", verificandone la corretta acquisizione dal server")
  ;;               (concat* (response (http-post* (url `(aia / companies)) payload))
  ;;                        ((fork (+equal+ response (const 201))
  ;;                               (target (url `(company-creation-success)))
  ;;                               (target (url `(company-creation-error))))))))))
    )
  
  ;; (macrolet ((cs (&rest strings) `(concatenate 'string ,@strings))
  ;;            (defattr (attr &optional before)
  ;;              (if before 
  ;;                  `(symb ',attr "-" ',name)
  ;;                  `(symb ',name "-" ',attr)))
  ;;            (defattrs (&rest attrs)
  ;;              `(progn
  ;;                 ,@(mapcar #'(lambda (attr)
  ;;                               `(defattr ,@attr))
  ;;                           attrs))))
  ;;   `(progn (defattrs (post)) 
  ;;          (defun ,(post) (payload)
  ;;             (with-doc* ,(cs "Effettua l'upload dei dati inseriti per l'oggetto" 
  ;;                             (lower-camel name)
  ;;                             ", verificandone la corretta acquisizione dal server")
  ;;               (concat* (response (http-post* (url `(aia / companies)) payload))
  ;;                        ((fork (+equal+ response (const 201))
  ;;                               (target (url `(company-creation-success)))
  ;;                               (target (url `(company-creation-error))))))))))
  )

(crud 'company nil nil)
