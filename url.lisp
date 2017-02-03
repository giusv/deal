(defprod pose (void ())
  (to-url () (empty)))

(defprod chunk (static-chunk ((name string)))
  (to-url () (text "~a" (lower name))))
(defprod chunk (dynamic-chunk ((name string)))
  (to-url () (text ":~a" (lower name))))

;; chain holds reversed path
(defprod pose (chain ((segment chunk) (pose pose)))
  (to-url () (if pose 
		 (hcat (synth to-url pose) (text "/") (synth to-url segment)))))

(defprod pose (multi (&rest (poses (list pose))))
  (to-url () (parens (apply #'punctuate (text ",") (synth-all to-url poses)))))

;;(synth output (synth to-url (chain 'a (multi (chain 'b) (chain 'c)))) 0)
;; (synth output (synth to-url (multi (chain 'b) (chain 'c))) 0)