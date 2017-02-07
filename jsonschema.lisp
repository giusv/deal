;;http://cswr.github.io/JsonSchema/spec/grammar/
(defprod jdoc (jdoc (&optional (id jid) (defs jdefs)
			       &rest (jsch (plist jres))))
  (to-json () (apply #'jobject 
		     :id id
		     :definitions (apply #'jobject defs)
		     (synth-plist to-json defs))))