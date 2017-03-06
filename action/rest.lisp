(defmacro def-http-action (name &key (payload t))
  (let ((full-name (symb "HTTP-" name)))
    `(defprod action (,full-name ((url expression)
                             ,@(if payload `((payload payload)))
                             (response variable)))
         (to-list () (list ',full-name (list :url (synth to-list url) 
                                             ,@(if payload (list ':payload '(synth to-list payload))) 
                                             :response response
                                             :precond precond
                                             :postcond postcond)))
       (to-html () (div nil 
			(text "Azione ~a verso l'URL " ',name)
			(synth to-html url)
			,@(if payload (list '(text "con il payload seguente:")
					    '(synth to-html payload)))
                        (maybes (list precond (span nil (text "Precondizione:")))
                                (list postcond (span nil (text "Postcondizione:")))))))))

(def-http-action get :payload nil)
(def-http-action post)
(def-http-action put)
(def-http-action delete :payload nil)

(defaction (http-response ((code number)
                           &key (payload (payload expression))))
  (to-list () `(http-response :code ,code :payload ,(synth to-html payload) :pre ,(synth to-list precond) :post ,(synth to-list postcond)))
  (to-html () (div nil (text "Restituzione risposta HTTP ~a" code)
                   (if payload (div nil (text "con il seguente payload:")
                                    (synth to-html payload)))
                   (maybes (list precond (span nil (text "Precondizione:")))
                           (list postcond (span nil (text "Postcondizione:")))))))
;; (pprint (synth to-list (http-get (void-url) (gensym "GET"))))
