(defprod element (horz (&rest (elements (list element))))
  (to-list () `(horz (:elements ,(synth-all to-list elements))))
  ;; (to-req (path) (funcall #'vcat 
  ;;       		  (text "Concatenazione orizzontale dei seguenti elementi:")
  ;;       		  (nest 4 (apply #'vcat (synth-all to-req elements path)))))
  (to-html (path) (multitags (text "Tale elemento si presenta come concatenazione orizzontale")
                             (if (not  elements) (text "vuota") (text "dei seguenti sottoelementi:"))
                             (apply #'ul nil ;; (list :class 'list-group)
                                    (mapcar #'listify (synth-all to-html elements path)))))
  (to-brief (path) (synth to-html (apply #'horz elements) path))
  (toplevel () (apply #'append (synth-all toplevel elements)))
  (req (path) (apply #'append (synth-all req elements path))))

(defmacro horz* (&rest elements)
  (let ((new-elements (mapcar #'(lambda (element)
			  (cons (gensym) element)) 
			      elements)))
    `(bindall ,new-elements
      (horz ,@(mapcar #'car new-elements)))))

