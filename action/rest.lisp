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
       (to-html () (div nil 
			(text "Azione ~a verso l'URL " ',name)
			(synth to-url url)
			,@(if payload (list '(text "con il payload seguente:")
					    '(synth to-html payload)))
                        (text "Sia ") 
                        (synth to-html response) 
                        (text " il risultato di tale azione.")
                        (maybes (list pre (span nil (text "Precondizione:")))
                                (list post (span nil (text "Postcondizione:")))))))))

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
  (to-html () (div nil (text "Restituzione risposta HTTP ~a" code)
                   (if payload (div nil (text "con il seguente payload:")
                                    (synth to-html payload)))
                   (maybes (list pre (span nil (text "Precondizione:")))
                           (list post (span nil (text "Postcondizione:")))))))
;; (pprint (synth to-list (http-get (void-url) (gensym "GET"))))
