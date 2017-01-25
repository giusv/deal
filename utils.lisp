(defun pairhash (keys vals)
  (let ((table (make-hash-table)))
    (mapcar #'(lambda (key val) (setf (gethash key table) val)) keys vals)
    table))