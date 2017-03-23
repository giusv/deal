(defprod element (input ((name symbol)
			 (label expression)
			 &key (init (init expression))))
  (to-list () `(input (:name ,name :label ,(synth to-list label) :init ,(synth to-list init))))
  (to-html (path) (multitags (text "Campo di input identificato come")
                             (span-color (lower name))
                             (text " etichettato con ")
                             (synth to-html label) 
                             (dlist init (span nil (text "Valore iniziale")) (synth to-html init))))
  (to-brief (path) (synth to-html (input name label :init init) path))
  (to-model () (jstring (value (input name label :init init))))
  (toplevel () nil)
  (req (path) nil))

(defmacro input* (label &key init)
  `(input (gensym "INPUT") ,label :init ,init))

;; (input* (const "name") :init (const "a"))
