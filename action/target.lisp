(defprod action (target ((pose pose)))
  (to-list () `(target :pose ,pose))
  (to-req () (hcat (text "effettua una transizione verso ") (synth to-url pose)))
  (to-html () (span nil (text "effettua una transizione verso ") (synth to-url pose))))
