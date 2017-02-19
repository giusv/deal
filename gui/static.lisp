(defprod named-element (static ((name string) 
				;; (queries (list expression))
				(element element)))
  (to-list () `(static (:name ,name #|:queries ,queries |# :element ,(synth to-list element))))
  (to-req (path) (let ((newpath (backward-chain (static-chunk name) path)))
		   (vcat (text "Elemento statico di nome ~a" 
			       (lower name)) 
			 (hcat (text "percorso: ") (synth to-url newpath))
			 (synth to-req element newpath))))
  (to-brief (path) (let ((newpath (backward-chain (static-chunk name) path)))
		     (synth output newpath) 
		     (div nil 
			  (text "Elemento statico di nome ~a " (lower name)) 
			  (parens (hcat (text "percorso: ") (synth to-url newpath))))))
  (to-html (path) (let ((newpath (backward-chain (static-chunk name) path)))
		    (div nil 
			    (h3 nil (text "Vista statica ~a " (lower name)) 
				(parens (hcat (text "percorso: ") (synth to-url newpath))))
			    (synth to-html element newpath)))))

(defmacro static2 (name queries element)
  `(static ,name 
	   (let ,(mapcar #'(lambda (query) 
			     `(,query (query-parameter ',query)))
			 queries)
	     (abst (list ,@queries) ,element))))
