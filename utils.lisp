(defun pairhash (keys vals)
  (let ((table (make-hash-table)))
    (mapcar #'(lambda (key val) (setf (gethash key table) val)) keys vals)
    table))

(defun group (source n)
  (if (endp source) nil
      (let ((rest (nthcdr n source)))
	(cons (if (consp rest) (subseq source 0 n) source)
	      (group rest n)))))

(defmacro mac-1 (expr)
  `(pprint (macroexpand-1 ',expr)))

(defmacro mac (expr)
  `(pprint (macroexpand ',expr)))




;; (defmacro define)


;; (setf *print-readably* t)

;; (setf *print-pretty* t)
;; (set-pprint-dispatch 'hash-table
;; 		     (lambda (str ht)
;; 		       (format str "{~{~{~S => ~S~}~^, ~}}"
;; 			       (loop for key being the hash-keys of ht
;; 				  for value being the hash-values of ht
;; 				  collect (list key value)))))

;; (defmacro unless (condition &rest body)
;;   `(if (not ,condition) (progn ,@body)))