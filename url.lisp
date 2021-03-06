(defprod pose (void-url ())
  (to-url () (empty))
  (to-list () `(void-url)))

(defprod chunk (static-chunk ((name string)))
  (to-url () (text "~a" (lower-camel name)))
  (to-list () `(static-chunk (:name ,name))))

(defprod chunk (dynamic-chunk ((name string)))
  (to-url () (braces (text "~a" (lower-camel name))))
  (to-list () `(dynamic-chunk (:name ,name))))

(defprod chunk (expression-chunk ((exp expression)))
  (to-url () (braces (synth to-chunk exp)))
  (to-list () `(expression-chunk (:exp ,exp))))

(defprod parameter (path-parameter ((name string)))
  (to-list () `(path-parameter (:name ,name)))
  (to-req () (text "~a (parametro path)" (lower-camel name)))
  (type () (text "path"))
  ;; (to-html () (synth to-req (path-parameter name)))
  (to-html () (multitags 
               (span-color (lower-camel name))
               (text "(parametro path)")))
  (to-url () (dynamic-chunk name)))

(defprod parameter (query-parameter ((name symbol) &optional (value expression)))
  (to-url () (hcat (text "~a" (lower-camel name)) 
		   (if value 
		       (hcat (equals) (synth to-url value))
		       (empty))))
  ;; (to-html () (synth to-req (query-parameter name value)))
  (to-html () (multitags 
               (span-color (lower-camel name))
               (text "(parametro query)")))
  (to-req () (text "~a (parametro query)" (lower-camel name)))
  (type () (text "query"))
  (to-list () `(query-parameter (:name ,name :value ,(synth to-list value)))))

(defprod parameter (login-parameter ((name symbol)))
  (to-html () (multitags 
               (span-color (lower-camel name))
               (text "(parametro login)")))
  (to-req () (text "~a (login)" (lower-camel name)))
  (type () (text "login"))
  (to-list () `(login-parameter (:name ,name))))

;; backward-chain holds reversed path
(defprod pose (backward-chain ((segment chunk) (pose pose)))
  (to-url () (if pose 
		 (hcat (synth to-url pose) (text "/") (synth to-url segment))))
  (to-list () `(backward-chain (:segment ,(synth to-list segment) :pose ,(synth to-list pose)))))

(defprod pose (multi (&rest (poses (list pose))))
  (to-url () (parens (apply #'punctuate (text ",") nil (synth-all to-url poses))))
  (to-list () `(multi (:poses ,(synth-all to-list poses)))))

(defprod pose (forward-chain ((segment chunk) (pose pose)))
  (to-url () (hcat (synth to-url segment) (text "/") (synth to-url pose)))
  (to-list () `(forward-chain (:segment ,(synth to-list segment) :pose ,(synth to-list pose)))))

(defprod pose (queried ((segment chunk) &rest (parameters (list parameter))))
  (to-url () (hcat (synth to-url segment) (text "?") (apply #'punctuate (text "&") nil (synth-all to-url parameters))))
  (to-list () `(queried (:segment ,(synth to-list segment) :parameters ,(synth-all to-list parameters)))))

(defun parse-query-parameter ()
  (do-with ((name (item))
	    ((sym '=))
	    (value (choose (do-with (((sym '{))
				     (value (item))
				     ((sym '}))) 
			     (result value))
			   (do-with ((value (item))) 
		       (result (const value))))))
    (result (query-parameter name value))))
(defun parse-chunk ()
  (choose (do-with (((sym '{))
		    (seg (item))
		    ((sym '}))) 
	    (result (expression-chunk seg)))
	  (choose (do-with ((seg (item))
			    ((sym '?))
			    (pars (sepby1 (parse-query-parameter) (sym '&))))
		    (result (apply #'queried (static-chunk seg) pars)))
		  (do-with ((seg (item)))
		    (result (static-chunk seg))))))

(defun parse-url ()
  (do-with ((segs (sepby (choose (do-with (((sym '<))
					   (poses (sepby (parse-url) (sym '&)))
					   ((sym '>)))
				   (result (apply #'multi poses)))
				 (parse-chunk))
			 (sym '/)))) 
    ;; (result (reduce #'forward-chain segs :from-end t))
    (result (forward-chain (void-url) (reduce #'forward-chain segs :from-end t)))))

(defmacro merge-urls (head tail)
  ;; (reduce #'forward-chain head :from-end t :initial-value (url tail))
  (labels ((listify (x)
             (if (consp x)
                 x
                 (list x))))
    `(parse (parse-url) `(,@',(listify head)  / ,@',(listify tail)))))

;; (merge-urls (seg1 / seg2) (seg3 / seg4))

(merge-urls :seg1 (seg3 / seg4))
(defmacro url (u)
  `(parse (parse-url) ,u))
;;(synth output (synth to-url (chain 'a (multi (chain 'b) (chain 'c)))) 0)
;; (synth output (synth to-url (multi (chain 'b) (chain 'c))) 0)
;;(parse (parse-url) '(a </> b))

;; (synth output (synth to-url (parse (parse-url) '({ a }))) 0)
;; (synth output (synth to-url (parse (parse-url) `(b ? q = a & r = { ,(value (button 'ok nil)) }))) 0)
;; (pprint (synth to-list (parse (parse-url) `(b ? q = a & r = { ,(value (button 'ok nil)) }))))

 

;; (synth output (synth to-url (reduce #'forward-chain (parse (parse-url) '({ a } / b)) :from-end t :initial-value (void-url))) 0)

;; (synth output (synth to-url (reduce #'forward-chain (parse (parse-url) '({ a } / < b & c >)) :from-end t :initial-value (void-url))) 0)

;; (synth output (synth to-url (reduce #'forward-chain (parse (parse-url) '({ a } / < b & c >)) :from-end t :initial-value (void-url))) 0)

;; (reduce #'forward-chain (parse (parse-url) '({ a } / < b & c >)) :from-end t :initial-value (void-url))



;; (pprint (synth to-list (parse (parse-url) '(a / < b & c >))))
;;(synth output (synth to-url (parse (parse-url) '(a / < b & c >))) 0)

