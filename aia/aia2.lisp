(data number-format
      (jsarray 'numbers (jsnumber 'number)))
(data test-format 
    (jsobject 'test-format
              (jsprop 'name t (jsstring 'string))
              (jsprop 'numbers t number-format)))
(element number-form 
         (arr 'numbers-form number-format (const 1) (const 2)
              (input* (const "number"))))
(element test-form 
         (obj* 'test-form test-format
               ((name name (input* (const "name")))
                (numbers numbers number-form))
               (vert name numbers)))
;; (pprint (synth to-list test-form))
(write-file "d:/giusv/temp/server.html" 
	    (synth to-string 
		   (synth to-doc (html nil 
				       (head nil 
					     (title nil (text "Server"))
					     (meta (list :charset "utf-8"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"))
					     (link (list :rel "stylesheet" :href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css")))
				       (body nil
					     (h1 nil (text "Archivio Integrato Antifrode"))
					     (h2 nil (text "Requisiti funzionali processo acquisizione indicatori"))
					     (synth to-html test-form (void-url))))) 0))


;; (pprint (synth output (synth to-doc (synth to-html test-form (void-url))) 0))
;; (pprint (synth output (synth to-string (synth to-model test-form)) 0))
;; (synth to-html (input 'name (const 1)) (void-url))
