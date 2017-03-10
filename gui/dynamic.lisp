(defprod named-element (dynamic ((name string) 
				 (element element)))
  (to-list () `(dynamic (:name ,name :element ,(synth to-list element))))
  (to-brief (path) (let ((newpath (backward-chain (dynamic-chunk name) path)))
		     (div nil (text "Elemento dinamico di nome ~a " (lower name)) 
			  (parens (hcat (text "percorso: ") (synth to-url newpath))))))
  (to-req (path) (let ((newpath (backward-chain (dynamic-chunk name) path)))
		   (vcat (text "Elemento dinamico di nome ~a" 
			       name) 
			 (hcat (text "percorso: ") (synth to-url newpath))
			 (synth to-req element newpath))))
  (to-html (path) (let ((newpath (backward-chain (dynamic-chunk name) path))) 
                    (multitags 
                     (h3 nil 
                         (text "Elemento dinamico ~a (URL: " (lower name)) 
                         (code nil (synth to-url newpath))
                         (text ")"))
                     (synth to-html element newpath))))
  (toplevel () (list (dynamic name element)))
  (req (path) (cons (synth to-html (dynamic name element) path)
                    (synth req element path))))

(defmacro dynamic2 (name element)
  `(dynamic ',name 
	    (let ((,name (path-parameter ',name)))
	      (abst (list ,name) ,element))))
