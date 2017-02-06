(defprod json (jnull ())
  (to-list () `(jnull))
  (to-string () (text "")))

(defprod json (jbool ((value bool)))
  (to-list () `(jbool (:value ,value)))
  (to-string () (text "\"~a\"" value)))

(defprod json (jnumber ((value number)))
  (to-list () `(jnumber (:value ,value)))
  (to-string () (text "~a" value)))

(defprod json (jstring ((value string)))
  (to-list () `(jstring (:value ,value)))
  (to-string () (text "\"~a\"" value)))

(defprod json (jarray (&rest (values (list json))))
  (to-list () `(jarray (:values ,values)))
  (to-string () (brackets (punctuate (comma) t (synth-all to-string values)))))

(defprod json (jobject (&rest (values (plist json))))
  (to-list () `(jobject (:values ,(synth-plist to-list values))))
  (to-string () (braces (punctuate (comma) t (synth-plist3 #'(lambda (sym) (text "\"~a\":" sym)) to-string values)))))

;; (defprod json (jobject2 (&rest (values (plist json))))
;;   (to-list () `(alt (:elements ,(synth-plist to-list elements)))))

(defparameter *json* (jobject :name (jstring 'john)
			      :age (jnumber 31)
			      :numbers (jarray (jnumber 98) (jnumber 234))
			      :address (jobject :city (jstring 'rome)
						:state (jstring 'usa))))

;; (synth to-string *json*)
(synth output (synth to-string *json*) 0)
