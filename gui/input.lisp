(defprod element (gui-input ((name symbol)
                             (label expression)
                             &key (init (init expression))
                             (model (model symbol))))
  (to-list () `(gui-input (:name ,name :label ,(synth to-list label) :init ,(synth to-list init) :model ,model)))
  (to-html (path) (multitags (text "Campo di input identificato come")
                             (span-color (lower-camel name))
                             (text " etichettato con ")
                             (synth to-html label) 
                             (if init
                                 (dlist init (span nil (text "Valore iniziale")) (synth to-html init)))))
  (to-brief (path) (synth to-html (gui-input name label :init init :model model) path))
  (to-model () (jstring (value (gui-input name label :init init :model model))))
  ;; (to-model () (jstring (value (gui-input name label :init init :model model))))
  (toplevel () nil)
  (req (path) nil) 
  (template (&optional father) (input (list :type "text" :class "form-control" :id (lower-camel name) 
                                            :|[(ngModel)]| (let ((prefix (if father 
                                                                             (symb father ".")
                                                                             (symb ""))))
                                                             (lower-camel (symb prefix (if model model name))))
                                            :name (lower-camel name)
                                            :placeholder (synth to-string (synth template init) 0)))))
 
(defmacro input* (label &key init model)
  `(gui-input (gensym "INPUT") ,label :init ,init :model ,model))

(synth output (synth to-doc (synth template (input* (const "Name") :init (const "hello") :model 'name))) 0)

;; (input* (const "name") :init (const "a"))
