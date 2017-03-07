(defmacro defaction ((name lambda-list) &rest attrs)
  (let* ((new-lambda-list (add-parameters lambda-list 'key '(pre (pre bexp)) '(post (post bexp))))) 
    `(defprod action (,name ,new-lambda-list) ,@attrs)))

;; (defmacro defaction ((name lambda-list) &rest attrs)
;;   (let* ((args (parse (destruc) lambda-list)))
;;     (setf (gethash 'key args) (append (gethash 'key args) '((pre (pre bexp)) (post (post bexp)))))
;;     (let* ((new-lambda-list (make-lambda-list args))) 
;;       `(defprod action (,name ,new-lambda-list) ,@attrs))))

(defaction (test ((req1 expression))) 
    (to-list () `(test (:req1 ,(synth to-list req1) :pre ,(synth to-list pre) :post ,(synth to-list post)))))

