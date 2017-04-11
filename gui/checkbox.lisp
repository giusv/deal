(defprod element (checkbox ((name symbol) 
                            &key
                            (label (label expression))
                            (init (init expression)) 
                            (click (click process))))
  (to-list () `(checkbox (:name ,name :label ,(synth to-list label) 
                                :init ,(synth to-list init) 
                                :click ,(synth to-list click))))
  (to-html (path) (multitags 
                   (text "Checkbox identificata come")
                   (span-color (lower-camel name))
                   (if label 
                       (multitags (text " etichettata con ")
                                  (synth to-html label)))
                   (if (or init click)
                       (dlist init (span nil (text "Valore iniziale")) (synth to-html init)
                              click (span nil (text "Sottoposto a click: ")) (synth to-html click)))))
  (to-brief (path) (synth to-html (checkbox name label expr :init init :click click) path)) 
  (to-model () (jbool (value (checkbox name :label label :init init :click click))))
  (req (path) nil))

(defmacro checkbox* (&key label init click)
  `(checkbox (gensym "CHECKBOX") :label ,label :init ,init :click ,click))
