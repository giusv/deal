(defprod element (listing ((name symbol)
                           (source datasource)
                           (element element)))
  (to-list () `(listing (:name ,name 
                               :source ,(synth to-list source) 
                               :element,(synth to-list (funcall element (synth schema source))))))
  (to-html (path)
	   (div nil 
                (text "Lista associata al formato dati ~a con la seguente espressione:" (lower-camel (synth name (synth schema source)))) 
                (p nil (synth to-html (funcall element (synth schema source)) path))))
  (to-brief (path) (synth to-html (listing name source element)))
  (toplevel () nil)
  (req (path) nil))


(defmacro listing* (source (rowname &optional index) &body element)
  `(listing (gensym "LISTING") 
            ,source
            (lambda (,rowname ,@(csplice index index)) (declare (ignorable ,rowname ,@(csplice index index))) ,@element)))

