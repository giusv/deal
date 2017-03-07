(defaction (validate ((expr expression) 
                           (result variable) 
                           (validators (list validator))))
  (to-list () `(validate :expr ,(synth to-list expr) :result (synth to-list result) :validators (synth-all to-list validators) :pre ,(synth to-list pre) :post ,(synth to-list post)))
  (to-req () (hcat (text "TODO ")))
  (to-html () (apply #'div nil 
		   (text "Sia ") 
		   (textify (synth name result)) 
		   (text " il risultato della validazione della seguente espressione:")
		   (div (list :class 'well) (synth to-html expr))
                   (div nil (text "con i seguenti validatori:"))
                   (append (synth-all to-html validators)
                           (list (maybes (list pre (span nil (text "Precondizione:")))
                                    (list post (span nil (text "Postcondizione:")))))))))

(defprod validator (required ())
  (to-list () `(required))
  (to-html () (div nil (text "obbligatorio"))))

(defprod validator (minlen ((n number)))
  (to-list () `(minlen (:n ,n)))
  (to-html () (div nil (text "minima lunghezza pari a ~a" n))))

(defprod validator (maxlen ((n number)))
  (to-list () `(maxlen (:n ,n)))
  (to-html () (div nil (text "massima lunghezza pari a ~a" n))))

(defprod validator (regex ((exp string)))
  (to-list () `(regex (:exp ,exp)))
  (to-html () (div nil (text "confome a espressione regolare ~a" exp))))

(defun validate2 (exp validators &key pre post)
  (let ((result (variab (gensym))))
    (values (validate exp result validators :pre pre :post post) result)))
