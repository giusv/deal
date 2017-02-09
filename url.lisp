(defprod pose (void ())
  (to-url () (empty))
  (to-list () `(empty)))

(defprod chunk (static-chunk ((name string)))
  (to-url () (text "~a" (lower name)))
  (to-list () `(static-chunk (:name ,name))))
(defprod chunk (dynamic-chunk ((name string)))
  (to-url () (text ":~a" (lower name)))
  (to-list () `(dynamic-chunk (:name ,name))))
(defprod chunk (expression-chunk ((exp expression)))
  (to-url () (braces (synth to-chunk exp)))
  (to-list () `(expression-chunk (:exp ,exp))))
;; chain holds reversed path
(defprod pose (chain ((segment chunk) (pose pose)))
  (to-url () (if pose 
		 (hcat (synth to-url pose) (text "/") (synth to-url segment))))
  (to-list () `(chain (:segment ,(synth to-list segment) :pose ,(synth to-list pose)))))

(defprod pose (multi (&rest (poses (list pose))))
  (to-url () (parens (apply #'punctuate (text ",") nil (synth-all to-url poses))))
  (to-list () `(multi (:poses ,(synth-all to-list poses)))))

(defprod pose (forward-chain ((segment chunk) (pose pose)))
  (to-url () (hcat (synth to-url segment) (text "/") (synth to-url pose)))
  (to-list () `(forward-chain (:segment ,(synth to-list segment) :pose ,(synth to-list pose)))))

(defun parse-chunk ()
  (choose (do-with (((sym '{))
		    (seg (item))
		    ((sym '}))) 
	    (result (expression-chunk seg)))
	  (do-with ((seg (item)))
	    (result (static-chunk seg)))))

(defun parse-url ()
  (do-with ((segs (sepby (choose (do-with (((sym '<))
					   (poses (sepby (parse-url) (sym '&)))
					   ((sym '>)))
				   (result (apply #'multi poses)))
				 (parse-chunk))
			 (sym '/)))) 
    (result (reduce #'forward-chain segs :from-end t))))


(defmacro url (u)
  `(parse (parse-url) ,u))
;;(synth output (synth to-url (chain 'a (multi (chain 'b) (chain 'c)))) 0)
;; (synth output (synth to-url (multi (chain 'b) (chain 'c))) 0)
;;(parse (parse-url) '(a </> b))

;; (synth output (synth to-url (parse (parse-url) '({ a }))) 0)
;; (parse (parse-url) '({ a }))

 

;; (synth output (synth to-url (reduce #'forward-chain (parse (parse-url) '({ a } / b)) :from-end t :initial-value (void))) 0)

;; (synth output (synth to-url (reduce #'forward-chain (parse (parse-url) '({ a } / < b & c >)) :from-end t :initial-value (void))) 0)

;; (reduce #'forward-chain (parse (parse-url) '({ a } / < b & c >)) :from-end t :initial-value (void))



;; (pprint (synth to-list (parse (parse-url) '(a / < b & c >))))
(synth output (synth to-url (parse (parse-url) '(a / < b & c >))) 0)
