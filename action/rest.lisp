(defmacro def-http-action (name &key (payload t))
  (let ((full-name (symb "HTTP-" name)))
    `(defaction (,full-name ((url url)
                             ,@(if payload `((payload payload)))
                             (response variable)))
         (to-list () (list ',full-name (list :url (synth to-list url) 
                                             ,@(if payload (list ':payload '(synth to-list payload))) 
                                             :response response
                                             :pre pre
                                             :post post))) 
       (to-html () (multitags
                    (text "Azione ~a verso l'URL " ',name)
                    (synth to-url url)
                    ,@(if payload (list '(text "con il payload seguente:")
                                        '(code nil (synth to-html payload))))
                    (p nil (text "Sia ") 
                       (synth to-html response) 
                       (text " il risultato di tale azione."))
                    (dlist pre (text "Precondizione: ") (synth to-html pre)
                           post (text "Postcondizione:") (synth to-html post)))))))

(def-http-action get :payload nil)

(def-http-action post)
(defun http-post* (url payload)
  (let ((result (variab (gensym))))
    (values (http-post url payload result) result)))



(def-http-action put)
(defun http-put* (url payload)
  (let ((result (variab (gensym))))
    (values (http-put url payload result) result)))

(def-http-action delete :payload nil)
(defun http-delete* (url)
  (let ((result (variab (gensym))))
    (values (http-delete url result) result)))


(defaction (http-response ((code number)
                           &key (payload (payload expression))))
    (to-list () `(http-response :code ,code :payload ,(synth to-html payload) :pre ,(synth to-list pre) :post ,(synth to-list post)))
  (to-html () (multitags (text "Restituzione risposta HTTP ~a" code)
                         (if payload 
                             (multitags (text " con il seguente payload: ")
                                        ;; (code nil (text "~a" (synth to-string (synth to-string payload) 0)))
                                        (synth to-html payload)
                                        ))
                         (dlist pre (text "Precondizione: ") (synth to-html pre)
                                post (text "Postcondizione:") (synth to-html post)))))
;; (pprint (synth to-list (http-get (void-url) (gensym "GET"))))
