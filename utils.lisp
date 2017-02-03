(defun pairhash (keys vals)
  (let ((table (make-hash-table)))
    (mapcar #'(lambda (key val) (setf (gethash key table) val)) keys vals)
    table))

(defun group (source n)
  (if (endp source) nil
      (let ((rest (nthcdr n source)))
	(cons (if (consp rest) (subseq source 0 n) source)
	      (group rest n)))))

;; (defmacro unless (condition &rest body)
;;   `(if (not ,condition) (progn ,@body)))