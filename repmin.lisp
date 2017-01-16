(def-typeclass tree min-alg rep-alg to-list)
(def-instance tree (leaf val)
  (rep-alg #'(lambda (m) (leaf m )))
  (min-alg val)
  (to-list `(leaf (:val ,val))))

(def-instance tree (bin left right)
  (rep-alg #'(lambda (m) (bin (funcall (rep-alg left) m) (funcall (rep-alg right) m))))
  (min-alg (min (min-alg left) (min-alg right)))
  (to-list `(bin (:left ,(to-list left) :right ,(to-list right)))))

(defparameter *tree* (bin (leaf 1) (bin (leaf 2) (leaf 3))))
(defparameter *tree-out* (funcall (rep-alg *tree*) (min-alg *tree*)))


;; (defgeneric to-list (t))
;; (defmethod to-list ((tree leaf))
;;   `(leaf (:val ,(val tree))))
;; (defmethod to-list ((tree bin))
;;   `(bin (:left ,(to-list (left tree)) :right ,(to-list (right tree)))))

