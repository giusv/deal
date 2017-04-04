(defaction (csv-to-json ((source variable) 
                         (result variable)))
    (to-list () `(csv-to-json (:source  ,(synth to-list source) :result ,(synth to-list result) :pre ,(synth to-list pre) :post ,(synth to-list post))))
  (to-html () (multitags 
               (text "Sia ") 
               (synth to-html result) 
               (text " il risultato della traduzione in JSON di")
               (synth to-req source)
               (dlist pre (text "Precondizione: ") (synth to-html pre)
                      post (text "Postcondizione:") (synth to-html post)))))

(defun csv-to-json2 (source &key pre post)
  (let ((result (variab (gensym))))
    (values (csv-to-json source result :pre pre :post post) result)))
