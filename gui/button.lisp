(defprod element (gui-button ((name symbol) (expr expression)
			  &key (click (click process)) (hover (hover process))))
  (to-list () `(gui-button (:name ,name :expr ,(synth to-list expr) 
			    :click ,(synth to-list click)
			    :hover ,(synth to-list hover))))
  ;; (to-req (path) (vcat (hcat (text "Pulsante identificato come ~a e etichettato con la seguente espressione:" (lower-camel name)) 
  ;;       		     (synth to-req expr))
  ;;       	       (nest 4 (hcat (text "Sottoposto a click, effettua la seguente azione:") (synth to-req click)))
  ;;       	       (synth to-req hover)))
  (to-html (path) (multitags 
		       (text "Pulsante identificato come ")
                       (span-color (lower-camel name))
                       (text " e etichettato con la seguente espressione:") 
                       (synth to-html expr)
                       (dlist click (span nil (text "Sottoposto a click: ")) (synth to-html click)
                              hover (span nil (text "Sottoposto a hover: ")) (synth to-html hover))))
  (to-brief (path) (synth to-html (gui-button name expr :click click :hover hover) path)) 
  (req (path) nil)
  (template (&optional father) (button (evnames click hover) (synth template expr))))



(defmacro button* (expr &key click hover)
  `(gui-button (gensym "BUTTON") ,expr :click ,click :hover ,hover))

(synth output (synth to-doc (synth template (button* (const "ok") :click t :hover t))) 0)
