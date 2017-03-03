(defprod action (translate ((source filter)
                            (target variable)
                            (result variable)))
  (to-list () `(translate (:source  ,(synth to-list source) :target ,(synth to-list target) :result ,(synth to-list result))))
  (to-html () (div nil 
		   (text "Sia ") 
		   (synth to-html result) 
		   (text " il risultato della compilazione del seguente sorgente:")
		   (div (list :class 'well) (synth to-req source)))))

(defun translate2 (source)
  (let ((result (variab (gensym))))
    (values (translate source nil result) result)))
