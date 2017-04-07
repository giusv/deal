(defaction (extract ((filter filter)
                     (source format)
                     (result variable)))
    (to-list () `(translate (:filter  ,(synth to-list filter) :source ,(synth to-list source) :result ,(synth to-list result) :pre ,(synth to-list pre) :post ,(synth to-list post))))

  (to-html () (multitags  
		   (text "Sia ") 
		   (synth to-html result) 
		   (text " il risultato della estrazione da ")
                   (textify (synth name source))
                   (text" con il seguente filtro:")
		   (synth to-req filter)
                   (dlist pre (text "Precondizione: ") (synth to-html pre)
                          post (text "Postcondizione:") (synth to-html post)))))

(defun extract2 (filter source &key pre post)
  (let ((result (variab (gensym))))
    (values (extract filter source result :pre pre :post post) result)))

(defaction (validate ((expr expression) 
                      (result variable) 
                      (validators (list validator))))
    (to-list () `(validate :expr ,(synth to-list expr) :result (synth to-list result) :validators (synth-all to-list validators) :pre ,(synth to-list pre) :post ,(synth to-list post)))
  (to-req () (hcat (text "TODO ")))
  (to-html () (multitags 
               (text "Sia ") 
               (synth to-html result) 
               (text " il risultato della validazione dell'espressione ")
               (synth to-html expr)
               (apply #' multitags (p nil (text "con i seguenti validatori:"))
                         (synth-all to-html validators))
               (dlist pre (text "Precondizione: ") (synth to-html pre)
                      post (text "Postcondizione:") (synth to-html post)))))

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

(defmacro with-extraction-and-validation (format processors &body commands)
  `(concat* ,@(apply #'append (loop for processor in processors
                  collect (let ((selector (car processor))
                                (validators (cdr processor))) 
                            (list `(,selector (extract2 (prop ',selector) ,format))
                                  `(,(symb selector "-VALID") (validate2 ,selector (list ,@validators)))))))
            ((fork (+and+ ,@(loop for processor in processors
                  collect (let ((selector (car processor))) 
                            (symb selector "-VALID"))))
                   (concat*
                    ,@commands)
                   (http-response 403)))))


;; (defprod action (extract ((source format)
;;                           &rest (bindings (plist variable filter))))
;;   (to-list () `(translate (:source ,(synth to-list source) :bindings ,(synth-plist-both to-list to-list bindings))))
;;   (to-html () (div nil 
;; 		   (text "Estrazione da ") 
;; 		   (synth to-html source)
;;                    (text "dei seguenti valori:")
;;                    (apply #'maybes (synth-plist-both to-html to-req bindings)))))

;; (defmacro extract2 (source &rest filters)
;;   (let ((bindings (mapcar #'(lambda (filter)
;;                               (list (gensym) filter)) 
;;                           filters)))
;;     `(extract ,source ,@bindings)))
