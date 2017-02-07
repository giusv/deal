(defprod process (target ((pose pose)))
  (to-list () `(target :pose ,pose))
  (to-req () (hcat (text "effettua una transizione verso ") (synth to-url pose))))



;; (defprod transition (transition ((target url) 
;; 				 &optional (action process)))
;;   (to-list () `(transition (:target ,target :action ,(synth to-list action)))))

