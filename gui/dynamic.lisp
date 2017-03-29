(defprod named-element (dynamic ((name string) 
				 (element element)))
  (to-list () `(dynamic (:name ,name :element ,(synth to-list element))))
  (to-brief (path) (let ((newpath (backward-chain (dynamic-chunk name) path)))
		     (multitags (strong nil 
                                        (text "Elemento dinamico di nome ~a (URL: " (lower-camel name)) 
                                        (a (list :href (concatenate 'string "#" (synth to-string (synth to-url newpath) 0)))
                                           (code nil (synth to-url newpath)))
                                        (text ")")))))
  (to-req (path) (let ((newpath (backward-chain (dynamic-chunk name) path)))
		   (vcat (text "Elemento dinamico di nome ~a" 
			       name) 
			 (hcat (text "percorso: ") (synth to-url newpath))
			 (synth to-req element newpath))))
  (to-html (path) (let ((newpath (backward-chain (dynamic-chunk name) path))) 
                    (multitags 
                     (section nil 
                              (h3 nil (text "Elemento dinamico ~a (URL: " (lower-camel name)) 
                                  (code (list :id (synth to-string (synth to-url newpath) 0)) (synth to-url newpath))
                                  (text ")"))
                              (p nil (synth to-html element newpath))))))
  (toplevel () (list (dynamic name element)))
  (req (path) (cons (synth to-html (dynamic name element) path)
                    (synth req element path))))

(defmacro dynamic2 (name element)
  `(dynamic ',name 
	    (let ((,name (path-parameter ',name)))
	      (abst (list ,name) ,element))))
