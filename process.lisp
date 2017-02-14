(defprod action (target ((pose pose)))
  (to-list () `(target :pose ,pose))
  (to-req () (hcat (text "effettua una transizione verso ") (synth to-url pose)))
  (to-html () (span nil (text "effettua una transizione verso ") (synth to-url pose))))

(defprod command (skip ())
  (to-list () `(skip)))

(defprod command (prefix ((action action)
			  (command command)))
  (to-list () `(prefix (:action ,(synth to-list action) :command (synth to-list command)))))

(defprod command (choice2 ((action action)
		   (command command)))
  (to-list () `(prefix (:action ,(synth to-list action) :command (synth to-list command)))))


(defprod process (sync-server ((parameters (list expression))
			       (input format)
			       (command command)
			       (output format)))
  (to-list () `(sync-server :parameters ,(synth-all to-list parameters) :input ,(synth to-list input)
			    :command ,(synth to-list command) :output ,(synth to-list output)))
  ())

(defprod process (async-server ((parameters (list expression))
				(input format)
				(command command)
				(output format)))
  (to-list () `(async-server :parameters ,(synth-all to-list parameters) :input ,(synth to-list input)
			     :command ,(synth to-list command) :output ,(synth to-list output)))
  ())

(defparameter *validation* ())
















;; (defprod transition (transition ((target url) 
;; 				 &optional (action process)))
;;   (to-list () `(transition (:target ,target :action ,(synth to-list action)))))

