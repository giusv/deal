(defprod element (vert (&rest (elements (list element))))
  (to-list () `(vert (:elements ,(synth-all to-list elements))))
  ;; (to-req (path) (funcall #'vcat 
  ;;       	    (text "Tale elemento si presenta come oncatenazione verticale dei seguenti sottoelementi:")
  ;;       	    (nest 4 (apply #'vcat (synth-all to-req elements path)))))
  (to-html (path) (multitags (text "Tale elemento si presenta come concatenazione verticale")
		       (if (not  elements) (text "vuota") (text "dei seguenti sottoelementi:"))
		       (apply #'ul nil ;; (list :class 'list-group)
			      (mapcar #'listify (synth-all to-html elements path)))))
  (to-brief (path) (synth to-html (apply #'vert elements) path))
  (toplevel () (apply #'append (synth-all toplevel elements)))
  (req (path) (apply #'append (synth-all req elements path)))
  (template (&optional father) (apply #'multitags (synth-all template elements father))))

(defmacro vert* (&rest elements)
  (let ((new-elements elements 
          ;; (mapcar #'(lambda (element)
          ;;     (cons (gensym) element)) 
          ;;         elements)
          ))
    `(bindall ,new-elements
      (vert ,@(mapcar #'car new-elements)))))


;; (synth output 
;;        (synth to-doc 
;;               (synth template (obj* 'ind-data indicator-format 
;;                                     ((code code (textarea* (const "Codice indicatore") :model 'code))
;;                                      (start-date start-date (input* (const "Data inizio validit�") :model 'date)))
;;                                     (vert code start-date)))) 0)

;; (vert* (ind (obj* 'ind-data indicator-format 
;;                                                 ((code code (textarea* (const "Codice indicatore") :model 'code))
;;                                                  (start-date start-date (input* (const "Data inizio validit�") :model 'date)))
;;                                                 (vert code start-date)))
;;                                      ((button* (const "Invio") :click (post-indicator-code (payload ind)))))
