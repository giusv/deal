;;(load "pretty.lisp")
(defun table (name attributes)
  (list 'table name attributes))

(defun table-name (table)
  (second table))
(defun table-attributes (table)
  (third table))
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

(defun attribute-name (attribute)
  (second attribute))
(defun attribute-type (attribute)
  (third attribute))

;; (defmacro line (fmt &rest args)
;;   `(format t (concatenate 'string 
;; 			    (make-string *indent* :initial-element #\Space) 
;; 			    ,fmt 
;; 			    "~%") ,@args))
;; (defmacro nest (amt &body body)
;;   `(let ((*indent* (+ *indent* ,amt)))
;;      ,@body))


;; (defun primary-key->java (key)
;;   (case (length key)
;;     (1 (field ))))

(defun class (name &rest body)
  (doc (line "public class ~s{" name)
       (apply #'nest 4 body)
       (line "}")))


(defun field (attribute)
  (let ((nm (attribute-name attribute))
	(tp (attribute-type attribute)))
    (line "private ~s ~s;" tp nm)))

(defun setter (attribute)
  (let ((nm (attribute-name attribute))
	(tp (attribute-type attribute)))
    (vcat (line "public void set~s(~s ~s){" nm tp nm)
	  (nest 4 (line "this.~s = ~s;" nm nm))
	  (line "}"))))

(defun getter (attribute)
  (let ((nm (attribute-name attribute))
	(tp (attribute-type attribute)))
    (vcat (line "public ~s get~s(){" tp nm)
	  (nest 4 (line "return ~s;" nm))
	  (line "}"))))
(defmacro vcat-all (fn lst)
  `(apply #'vcat (mapcar #',fn ,lst)))
(defun table->java (table)
  (class (table-name table)
	 (vcat-all field (table-attributes table))
	 (vcat-all getter (table-attributes table))
	 (vcat-all setter (table-attributes table))))

;; (defun table2java (table)
;;   (multiple-value-bind (primary auxiliary) (primary2java (primary-key table))
;;     (values (class (table-name table)
;; 		   primary
;; 		   (plain2java (plain-attributes table))
;; 		   (mapcar #'foreign2java (foreign-keys table)))
;; 	    auxiliary)))

