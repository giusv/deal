(defprod json (jnull ())
  (to-list () `(jnull))
  (to-string () (text "")))

(defprod json (jbool ((value bool)))
  (to-list () `(jbool (:value ,(synth to-list value))))
  (to-string () (synth to-string value)))

(defprod json (jnumber ((value number)))
  (to-list () `(jnumber (:value ,(synth to-list value))))
  (to-string () (synth to-string value)))


(defprod json (jstring ((value expression)))
  (to-list () `(jstring (:value ,(synth to-list value))))
  (to-string () (synth to-string value)))


(defprod json (jarray (&rest (values (list json))))
  (to-list () `(jarray (:values ,(synth-all to-list values))))
  (to-string () (brackets (apply #'punctuate (comma) t (synth-all to-string values)) :padding 1 :newline nil)))

(defprod json (jobject (&rest (values (plist json))))
  (to-list () `(jobject (:values ,(synth-plist to-list values))))
  (to-string () (braces 
		 (nest 4 (apply #'punctuate (comma) t 
				(synth-plist-merge 
				 #'(lambda (pair) (hcat (text "\"~a\": " (lower-camel (first pair)))
							(synth to-string (second pair)))) 
				 values)))
		 :newline t)))

;; (defprod json (jobject2 (&rest (values (plist json))))
;;   (to-list () `(alt (:elements ,(synth-plist to-list elements)))))

;; (defparameter *json* (jobject :name (jstring (const "john"))
;; 			      :age (jnumber 31)
;; 			      :numbers (jarray (jnumber 98) (jnumber 234))
;; 			      :address (jobject :city (jstring (const "rome"))
;; 						:state (jstring (const "usa")))))

;; (synth to-string *json*)
;; (synth output (synth to-string (jstring (const "ss"))) 0)
;; (synth output (synth to-string *json*) 0)
