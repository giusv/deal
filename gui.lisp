(defpackage :gui
  (:use :common-lisp))

(defmacro element (name &body elem)
  `(defparameter ,name ,@elem))

(defun option-panel (name label target)
  (panel (symb "PANNELLO-" name) (label (const label))
          (anchor name (const "Vai alla pagina") :click (target target))))

(defmacro hub-spoke (triples base layout)
  `(let* ,(mapcar #'(lambda (triple)
		      (let ((name (first triple))
			    (label (second triple)))
			`(,name (option-panel ',name 
                                              ,label
                                              ,(cond ((null base) (url `(,name)))
                                                     ((atom base) (url `(,base / ,name)))
                                                     ((consp base) (url `(,@base / ,name))))))))
		  triples)
     (alt ,layout ,@(mapcar #'(lambda (triple) 
			(let ((name (first triple))
			      (elem (third triple)))
			  `(static2 ,(keyw name) nil ,elem)))
		    triples))))
