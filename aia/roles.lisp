(defrole user (role 'user))
(defrole admin (role 'admin admin user))
(defrole root (role 'root admin))

(synth output (synth to-doc (synth to-html admin)) 0)
