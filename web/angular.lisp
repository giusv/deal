;; (defpackage :angular
;;   (:use :common-lisp :common-lisp-user))

;; (in-package :angular)

(defmacro within-braces (before inside)
  `(vcat (hcat ,before (text "{"))
         (nest 2 ,inside)
         (text "}")))
(defmacro within-parens (before inside)
  `(vcat (hcat ,before (text "("))
         (nest 2 ,inside)
         (text ")")))
;; (within-braces (text "@Component") (vcat (text "selector: ~a" selector)))
(defprod primitive (ng-pair ((name symbol)
                             (type symbol)
                             &key (init (init expression))
                             (const (const symbol))))
  (to-list () `(ng-pair (:name ,name :type ,type :init ,(synth to-list init))))
  (to-ts () (hcat (if const (text "const ") (empty))
                  (text "~a: ~a" (lower name) (lower type))
                  (if init 
                      (hcat (text " = ") (synth to-ts init))
                      (empty)))))

(defprod primitive (ng-array (&rest (elems (list primitive))))
  (to-list () `(ng-array (:elems ,(synth-all to-list elems))))
  (to-ts () (brackets (apply #'punctuate (comma) t (synth-all to-ts elems)) :padding 1 :newline nil)))

(defprod primitive (ng-primitive ((name symbol)
                                  &rest (props (plist primitive))))
  (to-list () `(ng-primitive (name ,name :props ,(synth-plist to-list props))))
  (to-ts () (vcat (text "@~a" (upper-camel name)) 
                  (parens
                   (braces 
                    (nest 4 (apply #'punctuate (comma) t 
                                   (synth-plist-merge 
                                    #'(lambda (pair) (hcat (text "~a: " (lower (first pair)))
                                                           (synth to-ts (second pair)))) 
                                    props)))
                    :newline t)))

         ;; (within-parens (text "@Component")
         ;;                (within-braces (empty)
         ;;                               (vcat (synth to-ts (descriptor 'selector selector))
         ;;                                     (synth to-ts (descriptor 'template-url template-url))
         ;;                                     (synth to-ts (descriptor 'style-urls (vector ))))))
         ))

(defprod primitive (ng-class ((name symbol)
                              &key (interfaces (interfaces (list symbol)))
                              (fields (fields (list ng-pair)))
                              (constructor (constructor constructor))
                              (methods (methods (list method)))))
  (to-list () `(ng-class (:name ,name :interfaces (,@interfaces) 
                                :fields ,(synth-all to-list fields) 
                                :constructor ,(synth to-list constructor)
                                :methods ,(synth-all to-list methods))))
  (to-ts () (vcat (text "export class ~a" (lower name)) 
                  (braces 
                   (nest 4 (apply #'vcat (apply #'postpend (semi) t 
                                                (synth-all to-ts fields))
                                  (synth to-ts constructor)
                                  (synth-all to-ts methods)))
                   :newline t))))



(defprod primitive (ng-method ((name symbol)
                               (parameters (list ng-pair))
                               (rtype symbol)
                               &rest (statements (list ng-statement))))
  (to-list () `(ng-method (:name ,name 
                                  :parameters ,(synth-all to-list parameters) 
                                  :rtype ,rtype
                                  :statements ,(synth-all to-list statements))))
  (to-ts () (vcat (hcat (textify name) 
                        (parens (apply #'punctuate (comma) nil (synth-all to-ts parameters)))
                        (text ": ~a" (lower rtype))) 
                  (braces 
                   (nest 4 (apply #'postpend (semi) t 
                                  (synth-all to-ts statements)))
                   :newline t))))

(defprod primitive (ng-import ((name expression)
                               &rest (elements (list symbol))))
  (to-list () `(ng-new (:name ,(synth to-list name) 
                              :elements ,elements)))
  (to-ts () (hcat (text "import ")
                  (if elements (hcat (braces (apply #'punctuate (comma) nil (mapcar #'text (mapcar #'upper-camel elements))) :padding 1)
                                     (text " from ")
                                     (synth to-ts name))))))

(defprod primitive (ng-new ((name symbol)
                            &rest (parameters (list expression))))
  (to-list () `(ng-new (:name ,name 
                              :parameters ,(synth-all to-list parameters))))
  (to-ts () (hcat (text "new ~a" (upper name)) 
                  (parens (apply #'punctuate (comma) nil (synth-all to-ts parameters))))))

(defprod primitive (ng-call ((name symbol)
                             &rest (parameters (list expression))))
  (to-list () `(ng-call (:name ,name 
                               :parameters ,(synth-all to-list parameters))))
  (to-ts () (hcat (textify name) 
                  (parens (apply #'punctuate (comma) nil (synth-all to-ts parameters))))))

(defprod statement (ng-chain (&rest (calls (list ng-call))))
  (to-list () `(ng-chain (:calls ,(synth to-list calls))))
  (to-ts () (let ((calls (synth-all to-ts calls)))
              (hcat (car calls)
                    (apply #'prepend (dot) t (cdr calls))))))

(defprod primitive (ng-constructor ((parameters (list ng-pair))
                                    &rest (statements (list ng-statement))))
  (to-list () `(ng-constructor (:parameters ,(synth-all to-list parameters) 
                                            :statements ,(synth-all to-list statements))))
  (to-ts () (vcat (hcat (text "constructor") 
                        (parens (apply #'punctuate (comma) nil (synth-all to-ts parameters)))) 
                  (braces 
                   (nest 4 (apply #'postpend (semi) t 
                                  (synth-all to-ts statements)))
                   :newline t))))

(defprod primitive (ng-arrow ((parameters (list ng-pair))
                              &rest (statements (list ng-statement))))
  (to-list () `(ng-arrow (:parameters ,(synth-all to-list parameters) 
                                      :statements ,(synth-all to-list statements))))
  (to-ts () (hcat (parens (apply #'punctuate (comma) nil (synth-all to-ts parameters)))
                  (text " => ") 
                  (braces 
                   (nest 4 (apply #'postpend (semi) t 
                                  (synth-all to-ts statements)))
                   :newline t))))


(defprod primitive (ng-unit (&rest (elements (list primitive))))
  (to-list () `(ng-unit (:elements ,(synth to-list elements))))
  (to-ts () (apply #'vcat (synth-all to-ts elements))))


(pprint (synth to-string (synth to-ts (ng-primitive 'ng-module 
                                                    :selector (const "my-heroes") 
                                                    :template-url  (const "test") 
                                                    :style-urls (ng-array (const "test")))) 0))

(synth output (synth to-ts (ng-unit
                            (ng-import (const "@angular/core") 'component 'onInit)
                            (ng-primitive 'component 
                                          :selector (const "my-heroes") 
                                          :template-url  (const "test") 
                                          :style-urls (ng-array (const "test")))
                            (ng-class 'hero-search 
                                      :fields (list (ng-pair 'heroes0 'string :init (ng-new 'heroes))
                                                    (ng-pair 'heroes 'string :init (ng-array (const "aaa")))
                                                    (ng-pair 'heroes2 'string :init (ng-call 'get (const "aaa")))
                                                    (ng-pair 'heroes3 'string :init (ng-chain (ng-call 'get (const "aaa"))
                                                                                        (ng-call 'set (const "aaa"))
                                                                                        (ng-call 'set (const "bbb"))))
                                                    (ng-pair 'heroes4 'string :init (ng-call 'catch (ng-arrow (list (ng-pair 'e 'error)) (ng-call 'test (const 'e)))) :const t))
                                      :constructor (ng-constructor (list (ng-pair 'heroes 'string)))
                                      :methods (list (ng-method 'on-init 
                                                                (list (ng-pair 'heroes 'string))
                                                                'void))))) 0)

