(defprod named-element (static ((name string) 
                                (element element)))
  (to-list () `(static (:name ,name :element ,(synth to-list element))))
  ;; (to-req (path) (let ((newpath (backward-chain (static-chunk name) path)))
  ;;       	   (vcat (text "Elemento statico di nome ~a" 
  ;;       		       (lower-camel name)) 
  ;;       		 (hcat (text "percorso: ") (synth to-url newpath))
  ;;       		 (synth to-req element newpath))))
  (to-brief (path) (let ((newpath (backward-chain (static-chunk name) path)))
		     (synth output newpath) 
		     (strong nil 
                             (text "~a (URL: " (upper-camel name #\Space)) 
                             (a (list :href (concatenate 'string "#" (synth to-string (synth to-url newpath) 0)))
                                (code nil (synth to-url newpath)))
                             (text ")"))))

  (to-html (path) (let ((newpath (backward-chain (static-chunk name) path)))
		    (multitags 
                     (section nil 
                              (h4 nil (text "~a (URL: " (upper-camel name #\Space)) 
                                  (code (list :id (synth to-string (synth to-url newpath) 0)) (synth to-url newpath))
                                  (text ")"))
                              (p nil (synth to-html element newpath))))))
  (toplevel () (list (static name element)))
  (req (path) 
       (let ((newpath (backward-chain (static-chunk name) path))) 
         (cons (synth to-html (static name element) path)
               (synth req element newpath)))))

(defmacro static2 (name queries element)
  `(static ,name 
	   ,(if queries 
		`(let ,(mapcar #'(lambda (query) 
				   `(,query (query-parameter ',query)))
			       queries)
		   (abst (list ,@queries) ,element))
		element)))
