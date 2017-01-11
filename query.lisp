;; (defmacro attribute (name type constraints)
;;   `(attribute ,name ,type ,constraints))

;; (defmacro deftable (name attributes)
;;   `(defparameter ,name (table ,name ,attributes)))

;; (deftable people (attribute id 'string nil))

;; (defmacro deftable (name attributes)
;;   `('table ,name ,attributes))
(defun table (name attributes)
  (list 'table name attributes))

(defun attribute (name type &optional constraint)
  (list 'attribute name type constraint))

(defparameter people (table 'people (list (attribute 'id 'int 'primary)
					  (attribute 'name 'string)
					  (attribute 'city 'string 'foreign))))

(defun primary-key (table)
  (destructuring-bind (table name attributes) table
    (remove-if-not #'is-primary attributes)))
(defun is-primary (attribute)
  (destructuring-bind (attribute name type constraint) attribute
    (eql constraint 'primary)))

(defparameter *indent* 0)
(defun table-name (table)
  (second table))

(defmacro line (stream fmt &rest args)
  `(format ,stream (concatenate 'string 
				(make-string *indent* :initial-element #\Space) 
				,fmt 
				"~%") ,@args))
(defmacro nest (amt &body body)
  `(let ((*indent* (+ *indent* ,amt)))
     ,@body))

(defun test ()
  (with-output-to-string (s nil)
    (nest 4 (line s "hello"))))

(defun table->java (table)
  (with-output-to-string (s nil)
    (line s "public class ~s{" (table-name table))
    (nest 4 
      (line s "public void set;")
      (nest 4 
	(line s "test;")))
    (line s "}")
    s))
(defun query-sql (query)
  (case (car query) 
    (table (apply #'table-sql (cdr query)))
    (restrict (apply #'restrict-sql (cdr query)))
    (project (apply #'project-sql (cdr query)))))

(defun table-sql (table)
  (format nil "~a" table))

(defun restrict-sql (expr query)
  (format nil "(~a) WHERE ~a" (query-sql query) (expr-sql expr)))

(defun project-sql (attrs query)
  (format nil "SELECT ~a FROM ~a" (attrs-sql attrs) (query-sql query)))

(defun attrs-sql (attrs)
  (format nil "~{~a~^, ~}" attrs))
(defun equal-sql (e1 e2)
  (format nil "(~a) = (~a)" (expr-sql e1) (expr-sql e2)))
(defun less-than-sql (e1 e2)
  (format nil "(~a) < (~a)" (expr-sql e1) (expr-sql e2)))
(defun and-sql (e1 e2)
  (format nil "(~a) AND (~a)" (expr-sql e1) (expr-sql e2)))
(defun or-sql (e1 e2)
  (format nil "(~a) OR (~a)" (expr-sql e1) (expr-sql e2)))
(defun not-sql (e)
  (format nil "NOT (~a)" (expr-sql e)))
(defun const-sql (e)
  (format nil "~a" e))
(defun attr-sql (e)
  (format nil "[~a]" e))

(defun expr-sql (expr)
  (case (car expr)
    (equal (apply #'equal-sql (cdr expr)))
    (less-than (apply #'less-than-sql (cdr expr)))
    (and (apply #'and-sql (cdr expr)))
    (or (apply #'or-sql (cdr expr)))
    (not (apply #'not-sql (cdr expr)))
    (const (apply #'const-sql (cdr expr)))
    (attr (apply #'attr-sql (cdr expr)))))

(defparameter *q* '(project ("a" "b") (restrict (equal (attr "a") (const "f")) (table "t"))))