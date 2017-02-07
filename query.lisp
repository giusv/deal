(defprod query (table ((name (reference entity))))
  (to-list () `(table :name ,name))
  (schema () (synth attributes (symbol-value name))))

(defprod query (project ((query query)
			 &rest (attributes (list attribute)))) 
  (to-list () `(project :attributes ,@attributes :query ,(synth to-list query)))
  (schema () attributes))

(defprod query (restrict ((query query)
			(expression bexpr))) 
  (to-list () `(restrict :expression ,(synth to-list expression) :query ,(synth to-list query)))
  (schema () (synth attributes query)))

(defparameter *query* (project (restrict (table '*people*) (<equal> (<true>) (<true>))) 'id 'name))

(synth schema *query*)


;;(synth attributes *people*)


;; (defun query-sql (query)
;;   (case (car query) 
;;     (table (apply #'table-sql (cdr query)))
;;     (restrict (apply #'restrict-sql (cdr query)))
;;     (project (apply #'project-sql (cdr query)))))

;; (defun table-sql (table)
;;   (format nil "~a" table))

;; (defun restrict-sql (expr query)
;;   (format nil "(~a) WHERE ~a" (query-sql query) (expr-sql expr)))

;; (defun project-sql (attrs query)
;;   (format nil "SELECT ~a FROM ~a" (attrs-sql attrs) (query-sql query)))

;; (defun attrs-sql (attrs)
;;   (format nil "~{~a~^, ~}" attrs))
;; (defun equal-sql (e1 e2)
;;   (format nil "(~a) = (~a)" (expr-sql e1) (expr-sql e2)))
;; (defun less-than-sql (e1 e2)
;;   (format nil "(~a) < (~a)" (expr-sql e1) (expr-sql e2)))
;; (defun and-sql (e1 e2)
;;   (format nil "(~a) AND (~a)" (expr-sql e1) (expr-sql e2)))
;; (defun or-sql (e1 e2)
;;   (format nil "(~a) OR (~a)" (expr-sql e1) (expr-sql e2)))
;; (defun not-sql (e)
;;   (format nil "NOT (~a)" (expr-sql e)))
;; (defun const-sql (e)
;;   (format nil "~a" e))
;; (defun attr-sql (e)
;;   (format nil "[~a]" e))

;; (defun expr-sql (expr)
;;   (case (car expr)
;;     (equal (apply #'equal-sql (cdr expr)))
;;     (less-than (apply #'less-than-sql (cdr expr)))
;;     (and (apply #'and-sql (cdr expr)))
;;     (or (apply #'or-sql (cdr expr)))
;;     (not (apply #'not-sql (cdr expr)))
;;     (const (apply #'const-sql (cdr expr)))
;;     (attr (apply #'attr-sql (cdr expr)))))

;; (defparameter *q* '(project ("a" "b") (restrict (equal (attr "a") (const "f")) (table "t"))))