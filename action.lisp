(defmacro defaction ((name lambda-list) &rest attrs)
  (let* ((new-lambda-list (add-parameters lambda-list 'key '(precond (precond bexp)) '(postcond (postcond bexp))))) 
    `(defprod action (,name ,new-lambda-list) ,@attrs)))

;; (defmacro defaction ((name lambda-list) &rest attrs)
;;   (let* ((args (parse (destruc) lambda-list)))
;;     (setf (gethash 'key args) (append (gethash 'key args) '((precond (precond bexp)) (postcond (postcond bexp)))))
;;     (let* ((new-lambda-list (make-lambda-list args))) 
;;       `(defprod action (,name ,new-lambda-list) ,@attrs))))

(defaction (test ((req1 expression))) 
    (to-list () `(test (:req1 ,(synth to-list req1) :pre ,(synth to-list precond) :post ,(synth to-list postcond)))))

