(defprod element (navbar ((name symbol) &rest (anchors (list element))))
  (to-list () `(navbar (:name ,name :anchors ,(synth-all to-list anchors))))
  ;; (to-req (path) (funcall #'vcat 
  ;;       		  (text "Barra di navigazione con i seguenti elementi:")
  ;;       		  (nest 4 (apply #'vcat (synth-all to-req anchors path)))))
  (to-html (path) (multitags (text "Barra di navigazione ")
                             (if (not  anchors) 
                                 (text "vuota") 
                                 (text "composta dai seguenti link:"))
                             (apply #'ul nil ;; (list :class 'list-group)
                                    (mapcar #'listify (synth-all to-html anchors path)))))
  (to-brief (path) (synth to-html (apply #'navbar name anchors) path))
  (toplevel () nil)
  (req (path) nil))
(defmacro navbar* (&rest anchors)
  `(navbar (gensym "navbar") ,@anchors))
