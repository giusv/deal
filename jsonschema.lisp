;;http://cswr.github.io/JsonSchema/spec/grammar/
(defprod jsdoc (jsdoc ((id jid) (defs jdefs) (sch jsch)))
  (to-json () (apply #'jobject 
		     :id id
		     :definitions (apply #'jobject defs)
		     (synth-plist to-json defs))))