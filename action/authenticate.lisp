(defaction (authenticate ((userid variable)
                          (password variable)
                          (result variable)))
    (to-list () `(authenticate (:userid  ,(synth to-list userid) :password ,(synth to-list password) :result ,(synth to-list result) :pre ,(synth to-list pre) :post ,(synth to-list post))))
  (to-html () (multitags 
               (text "Sia ") 
               (synth to-html result) 
               (text " il risultato del processo di autenticazione di [")
               (synth to-html userid)
               (comma)
               (synth to-html password)
               (text "]")
               (dlist pre (text "Precondizione: ") (synth to-html pre)
                      post (text "Postcondizione:") (synth to-html post)))))

(defun authenticate2 (userid password &key pre post)
  (let ((result (variab (gensym))))
    (values (authenticate userid password result :pre pre :post post) result)))