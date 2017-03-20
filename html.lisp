(defmacro deftag-old (name)
  `(defun ,name (&optional attrs &rest body)
     (labels ((open-tag (as) (format nil "<~(~a~)~{ ~(~a~)=\"~a\"~}>" ,(lower name) as))
	      (close-tag () (format nil "</~(~a~)>" ',name))
	      (open-close-tag (as) (format nil "<~(~a~)~{ ~(~a~)=\"~a\"~}/>" ',name as)))
       (if (null body)
	   (text  (open-close-tag attrs))
	   (vcat (text  (open-tag attrs))
		 (nest 4 (apply #'vcat body))
		 (text  (close-tag)))))))

(defmacro deftags (&rest names)
  `(progn
     ,@(mapcar #'(lambda (name)
		   `(deftag ,name))
	       names)))


(defmacro divm (attributes &body body)
  `(apply #'div (list ,@attributes) ,body))

(defprod html (multitags (&rest (tags html)))
  (to-list () `(multitags (:tags ,(synth-all to-list tags))))
  (to-doc () (apply #'vcat (synth-all to-doc tags))))

(defmacro deftag (name)
  `(defprod html (,name ((attributes (list string))
			 &rest (body (list html))))
     (to-list () (list ',name (list :attributes attributes :body (synth-all to-list body))))
     (to-doc () (labels ((open-tag (as) (text "<~(~a~)~{ ~(~a~)=\"~(~a~)\"~}>" (lower ',name) as))
			 (close-tag () (text "</~(~a~)>" ',name))
			 (open-close-tag (as) (text "<~(~a~)~{ ~(~a~)=\"~a\"~}/>" ',name as)))
		  (if (null body)
		      (open-close-tag attributes)
		      (vcat (open-tag attributes)
			    (nest 4 (apply #'vcat (synth-all to-doc body)))
			    (close-tag)))))))
(deftags html head title meta link body h1 h2 h3 div span li dl dt dd ul ol pre i strong code script
         table tr th td
         section article aside p)

;;(mapcar #'(lambda (pair) (format t "~a: ~a~%" (car pair) (cdr pair))) (pairlis '(a b) '(1 2)))
(defun listify (elem)
  (li #|(list :class "list-group-item")|# nil elem))
(defun maybes (&rest pairs)
  (apply #'dl nil
	 (remove nil (apply #'append 
                            (mapcar #'(lambda (pair) 
                                        (if (car pair)
                                            (list (dt nil (cadr pair))
                                                  (dd nil (synth to-html (car pair))))))
                                    pairs)))))

(defun maybes2 (pairs path)
  (apply #'dl nil
	 (remove nil (apply #'append 
                            (mapcar #'(lambda (pair) 
                                        (if (car pair)
                                            (list (dt nil (cadr pair))
                                                  (dd nil (synth to-html (car pair) path)))))
                                    pairs)))))

(defmacro dlist (&rest args)
  `(apply #'dl nil (apply #'append
                          (remove nil 
                                  (list ,@(loop while args
                                             collecting `(if ,(pop args)
                                                             (list (dt nil ,(pop args))
                                                                   (dl nil ,(pop args))))))))))



;; (dlist label (span nil "Nome:") (synth to-html label path)
;;        input (span nil "input:") (synth to-html input path))
;; (defun description-list (keys vals)
;;   (apply #'dl 
;; 	 nil 
;; 	 (apply #'append (mapcar #'(lambda (pair) 
;; 				     (list (dt nil (car pair))
;; 					   (dd nil (cdr pair))))
;; 				 (pairlis (reverse keys) (reverse vals))))))

;; (synth output (synth to-doc (div nil (span nil (text "hello")))) 0)
;; (pprint (synth to-list (div nil (span nil (text "hello")))))

;; (format t "~a" (synth output (div (list :id 1) 
;; 				  (h1 nil 
;; 				      (text "hello"))
;; 				  (h1 nil 
;; 				      (text "hello2"))) 0))

;; https://simon.html5.org/html-elements
;; <html manifest>
;; <head>
;; <title>
;; <base href target>
;; <link href rel media hreflang type sizes>
;; <meta name http-equiv content charset>
;; <style media type scoped>
;; <script src async defer type charset>
;; <noscript>
;; <body onafterprint onbeforeprint onbeforeunload onblur onerror onfocus onhashchange onload onmessage onoffline ononline onpagehide onpageshow onpopstate onresize onscroll onstorage onunload>
;; <section>
;; <nav>
;; <article>
;; <aside>
;; <h1>
;; <h2>
;; <h3>
;; <h4>
;; <h5>
;; <h6>
;; <hgroup>
;; <header>
;; <footer>
;; <address>
;; <p>
;; <hr>
;; <pre>
;; <blockquote cite>
;; <ol reversed start>
;; <ul>
;; <li value>
;; <dl>
;; <dt>
;; <dd>
;; <figure>
;; <figcaption>
;; <div>
;; <a href target ping rel media hreflang type>
;; <em>
;; <strong>
;; <small>
;; <s>
;; <cite>
;; <q cite>
;; <dfn>
;; <abbr>
;; <data value>
;; <time datetime pubdate>
;; <code>
;; <var>
;; <samp>
;; <kbd>
;; <sub>
;; <sup>
;; <i>
;; <b>
;; <u>
;; <mark>
;; <ruby>
;; <rt>
;; <rp>
;; <bdi>
;; <bdo>
;; <span>
;; <br>
;; <wbr>
;; <ins cite datetime>
;; <del cite datetime>
;; <img alt src srcset crossorigin usemap ismap width height>
;; <iframe src srcdoc name sandbox seamless width height>
;; <embed src type width height>
;; <object data type typemustmatch name usemap form width height>
;; <param name value>
;; <video src crossorigin poster preload autoplay mediagroup loop muted controls width height>
;; <audio src crossorigin preload autoplay mediagroup loop muted controls>
;; <source src type media>
;; <track default kind label src srclang>
;; <canvas width height>
;; <map name>
;; <area alt coords shape href target ping rel media hreflang type>
;; <table>
;; <caption>
;; <colgroup span>
;; <col span>
;; <tbody>
;; <thead>
;; <tfoot>
;; <tr>
;; <td colspan rowspan headers>
;; <th colspan rowspan headers scope abbr>
;; <form accept-charset action autocomplete enctype method name novalidate target>
;; <fieldset disabled form name>
;; <legend>
;; <label form for>
;; <input accept alt autocomplete autofocus checked dirname disabled form formaction formenctype formmethod formnovalidate formtarget height inputmode list max maxlength min multiple name pattern placeholder readonly required size src step type value width>
;; <button autofocus disabled form formaction formenctype formmethod formnovalidate formtarget name type value>
;; <select autofocus disabled form multiple name required size>
;; <datalist option>
;; <optgroup disabled label>
;; <option disabled label selected value>
;; <textarea autocomplete autofocus cols dirname disabled form inputmode maxlength name placeholder readonly required rows wrap>
;; <keygen autofocus challenge disabled form keytype name>
;; <output for form name>
;; <progress value max>
;; <meter value min max low high optimum>
;; <details open>
;; <summary>
;; <command type label icon disabled checked radiogroup command>
;; <menu type label>
;; <dialog open>
;; Input Types
;; hidden
;; text
;; search
;; tel
;; url
;; email
;; password
;; datetime
;; date
;; month
;; week
;; time
;; datetime-local
;; number
;; range
;; color
;; checkbox
;; radio
;; file
;; submit
;; image
;; reset
;; button
;; Global Attributes
;; accesskey
;; aria-*
;; class
;; contenteditable
;; contextmenu
;; data-*
;; dir
;; draggable
;; dropzone
;; hidden
;; id
;; inert
;; itemid
;; itemprop
;; itemref
;; itemscope
;; itemtype
;; lang
;; role
;; spellcheck
;; style
;; tabindex
;; title
;; translate
;; Event Handlers
;; onabort
;; onblur
;; oncanplay
;; oncanplaythrough
;; onchange
;; onclick
;; oncontextmenu
;; ondblclick
;; ondrag
;; ondragend
;; ondragenter
;; ondragleave
;; ondragover
;; ondragstart
;; ondrop
;; ondurationchange
;; onemptied
;; onended
;; onerror
;; onfocus
;; onformchange
;; onforminput
;; oninput
;; oninvalid
;; onkeydown
;; onkeypress
;; onkeyup
;; onload
;; onloadeddata
;; onloadedmetadata
;; onloadstart
;; onmousedown
;; onmousemove
;; onmouseout
;; onmouseover
;; onmouseup
;; onmousewheel
;; onpause
;; onplay
;; onplaying
;; onprogress
;; onratechange
;; onreset
;; onreadystatechange
;; onseeked
;; onseeking
;; onselect
;; onshow
;; onstalled
;; onsubmit
;; onsuspend
;; ontimeupdate
;; onvolumechange
;; onwaiting
