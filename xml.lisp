;; (defmacro deftag (name)
;;   `(defun ,name (&optional attrs &rest body)
;;      (labels ((open-tag (as) (format nil "<~(~a~)~{ ~(~a~)=\"~a\"~}>" ,(lower name) as))
;; 	      (close-tag () (format nil "</~(~a~)>" ',name))
;; 	      (open-close-tag (as) (format nil "<~(~a~)~{ ~(~a~)=\"~a\"~}/>" ',name as)))
;;        (if (null body)
;; 	   (text  (open-close-tag attrs))
;; 	   (vcat (text  (open-tag attrs))
;; 		 (nest 4 (apply #'vcat body))
;; 		 (text  (close-tag)))))))

(defprod xml (node ((name string) &optional (attrs attribute) &rest (nodes node)))
  (to-doc () (labels ((open-tag (as) (format nil "<~a~{ ~(~a~)=\"~(~a~)\"~}>" (lower name) as))
		      (close-tag () (format nil "</~a>" (lower name)))
		      (open-close-tag (as) (format nil "<~a~{ ~(~a~)=\"~(~a~)\"~}/>" (lower name) as)))
	       (if (null nodes)
		   (text  (open-close-tag attrs))
		   (vcat (text  (open-tag attrs))
			 (nest 4 (apply #'vcat (synth-all to-doc nodes)))
			 (text  (close-tag)))))))

;;(format t "~a" (synth pretty (synth to-doc (node 'test (list 'name 'myname) (node 'div nil))) 0))

;; (defmacro deftags (&rest names)
;;   `(progn
;;      ,@(mapcar #'(lambda (name)
;; 		   `(deftag ,name))
;; 		 names)))

;; (deformat note (seq (simple to string)
;; 		    (simple from string)
;; 		    (simple heading string)
;; 		    (simple body string)))
;; (deftags |xs:element| |xs:attribute| |xs:complex-type|)
(defprod element (simple ((name string) (type string)))
  (to-xml () (node '|xs:element| (list :name name :type type))))
(defprod element (attrib ((name string) (type string)))
  (to-xml () (node '|xs:attribute| (list :name name :type type))))

(defmacro def-xsd-indicator (tag name)
  `(defprod element (,tag ((name string) &rest (elems element)))
     (to-xml () (node '|xs:element| (list :name name)
		      (node '|xs:complex-type| nil 
			    (apply #'node ',name nil
				   (synth-all to-xml elems)))))))

(def-xsd-indicator seq |xs:sequence|)
(def-xsd-indicator all |xs:all|)
(def-xsd-indicator chx |xs:choice|)

;;; (format t "~a" (synth pretty (synth to-xml (attr 1 2)) 0))
;; (format t "~a" (synth pretty (synth to-xml (seq 'employee (simple 'firstname 'string) (simple 'lastname 'string))) 0))


