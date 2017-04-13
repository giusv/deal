(defprod prim (linguaggio (&rest (prims (list prim))))
  (to-list () (list 'linguaggio (list :primitives (synth-all to-list prims))))
  (to-production () (multitags 
                     (text "La sintassi astratta del linguaggio di specifica degli indicatori. Di seguito viene descritto ciascun costrutto utilizzato nella sua definizione. Lo schema di utilizzo di un costrutto &egrave; ricorrente: ogni costrutto &egrave; delimitato da parentesi tonde, e contiene una sequenza di simboli. Il primo di essi denota il costrutto, mentre i restanti rappresentano gli argomenti del costrutto stesso.")
                     (apply #'dl nil (apply #'append 
                                            (mapcar #'(lambda (prim)
                                                        (list (dt nil (synth to-syntax prim))
                                                              (dd nil (synth to-production prim))))
                                                    prims))))))

(defprod prim (indicatore ((name symbol)
                           (args (list argument))
                           (pars (list parameter))
                           (expr expression)))
  (to-list () (list 'indicatore (list :name name :args (synth-all to-list args) :pars (synth-all to-list pars) :expr (synth to-list expr))))
  (to-production () (multitags (text "Costrutto principale per la definizione di un indicatore. Esso prende in ingresso l'identificativo univoco dell'indicatore, una lista di argomenti in ingresso, una ulteriore lista di parametri configurabili e l'espressione che implementa il calcolo dell'indicatore stesso.")))
  (to-syntax () (text "(indicatore (in-1 ... in-n) ((arg-1 typ-1) ... (arg-m typ-m)) expr)")))

(defmacro indicatore* (name (&rest args) (&rest pars) &body expr)
  (let ((exp-args (mapcar (lambda (arg) `(argomento ',arg)) args) )
        (exp-pars (mapcar (lambda (par) `(parametro ',(car par) ',(cadr par))) pars)))
    `(indicatore ',name (list ,@exp-args) (list ,@exp-pars)
       (let (,@(mapcar #`(,(car a1) ,(cadr a1)) (mapcar #'list (append args (mapcar #'car pars)) (append exp-args exp-pars)))) 
         ,@expr)))) 

(defprod prim (periodo ((mesi number)))
  (to-list () (list 'periodo (list :mesi mesi)))
  (to-production () (multitags (text "Costrutto che prende in ingresso un numero e restituisce il costrutto la finestra mobile su cui calcolare le occorrenze di un determinato evento."))))

(defprod prim (indice ((name symbol)))
  (to-list () (list 'indice (list :nome name)))
  (to-production () (multitags (text "Indice all'interno di una tabella."))))

(defprod prim (parametro ((name symbol)
                          (type symbol)))
  (to-list () (list 'parametro (list :nome name :tipo type)))
  (to-production () (multitags (text "Costrutto che prende in ingresso un nome e un tipo e restituisce il parametro da essi costituito."))))

(defprod prim (argomento ((type symbol)))
  (to-list () (list 'argomento (list :tipo type)))
  (to-production () (multitags (text "Costrutto che prende in ingresso un tipo (a scelta tra soggetto e veicolo) e restituisce l'argomento da esso costituito."))))

(defmacro tabella (name anaph) 
  `(progn (defprod prim (,(symb name "%") ((predicate predicate)))
      (to-list () (list ',name (list :predicato (synth to-list predicate))))
      (to-production () (multitags (text "Costrutto che prende in ingresso un predicato e restituisce la tabella dei ~a che soddisfano il predicato stesso. Nella definizione del predicato si pu&ograve; far uso dell'anafora \"~a\" che identifica il ~a di volta in volta sotto esame." ,(string-downcase (symbol-name name)) ,(string-downcase (symbol-name anaph)) ,(string-downcase (symbol-name anaph)))))
      (to-syntax () (text "(~a predicato)" ,(string-downcase name))))
          (defmacro ,name (predicate)
            `(let ((,',anaph (indice ',',anaph)))
              (,',(symb name "%") ,predicate)))))

(defmacro tabelle (&rest tabs)
  `(progn
     ,@(mapcar #'(lambda (tab)
		   `(tabella ,(car tab) ,(cadr tab)))
	       tabs)))
(tabelle (sinistri sinistro)
         (soggetti soggetto)
         (veicoli veicolo))

(synth to-list (sinistri nil))
(defprod prim (numero ((query query)
                       (cluster cluster)))
  (to-list () `(numero (:e ,(synth to-list query) :cluster ,(synth to-list cluster))))
  (to-production () (multitags (text "Costrutto che prende in ingresso il risultato di un query (una tabella) e la lunghezza in mesi di una finestra temporale. Esso conta le occorrenze degli eventi descritti da ciascuna riga all'interno di una finestra mobile delle lunghezza specificata.")))
(to-syntax () (text "(numero tabella cluster)")))

(defprod prim (e (&rest (predicates predicate)))
  (to-list () `(e (:predicati ,(synth-all to-list predicates))))
  (to-production () (multitags (text "Predicato che prende in ingresso una lista di predicati e restituisce la loro congiunzione logica.")))
  (to-syntax () (text "(e pred1 ... pred n)")))

(defprod prim (o (&rest (predicates predicate)))
  (to-list () `(o (:predicati ,(synth-all to-list predicates))))
  (to-production () (multitags (text "Predicato che prende in ingresso una lista di predicati e restituisce la loro disgiunzione logica.")))
  (to-syntax () (text "(o pred1 ... pred n)")))

(defprod prim (non ((predicate predicate)))
  (to-list () `(non (:predicato ,(synth to-list predicate))))
  (to-production () (multitags (text "Predicato che prende in ingresso un predicato e ne restituisce la sua negazione logica.")))
  (to-syntax () (text "(non pred)")))



(defmacro ruolo (name) 
  `(defprod prim (,name ((person symbol)
                         (accident symbol)))
    (to-list () (list ',name (list :soggetto person :sinistro accident)))
    (to-production () (multitags (text "Predicato che prende in ingresso i riferimenti a un soggetto e a un sinistro e restituisce vero se il soggetto &egrave; ~a nel sinistro" ,(string-downcase (symbol-name name)))))
    (to-syntax () (text "(~a persona sinistro)" ,(string-downcase (symbol-name name))))))

(defmacro ruoli (&rest names)
  `(progn
     ,@(mapcar #'(lambda (name)
		   `(ruolo ,name))
	       names)))


(ruoli coinvolto leso richiedente proprietario contraente deceduto testimone responsabile conducente patente-invalida)

(defmacro funzione (name desc) 
  `(defprod prim (,name ((accident symbol)))
    (to-list () (list ',name (list :sinistro accident)))
    (to-production () (multitags (text "Funzione che prende in ingresso il riferimento a un sinistro e restituisce ~a." ,desc)))
    (to-syntax () (text "(~a sinistro)" ,(string-downcase (symbol-name name))))))

(defmacro funzioni (&rest funcs)
  `(progn
     ,@(mapcar #'(lambda (func)
		   `(funzione ,(car func) ,(cadr func)))
	       funcs)))
(funzioni (numero-lesi "il numero di lesi presenti nel sinistro")
          (numero-fgvs "il numero di richieste FGVS presenti nel sinistro")
          (data-denuncia "la data della denuncia del sinistro")
          (data-accadimento "la data di accadimento del sinistro")
          (giorni-da-decorrenza "il numero di giorni trascorsi tra la decorrenza della polizza e il sinistro")
          (giorni-a-scadenza "il numero di giorni trascorsi tra il sinistro e la scadenza della polizza"))

(defmacro espressione (name prep) 
  `(defprod prim (,name ((num1 number) 
                         (num2 number)))
    (to-list () (list ',name (list :num1 (synth to-list num1) :num2 (synth to-list num2))))
    (to-production () (multitags (text "Predicato che prende in ingresso due numeri e restituisce vero se il primo numero &egrave; ~a secondo." ,prep)))
    (to-syntax () (text "(~a num1 num2)" ,(string-downcase (symbol-name name))))))

(defmacro espressioni (&rest exps)
  `(progn
     ,@(mapcar #'(lambda (exp)
		   `(espressione ,(car exp) ,(cadr exp)))
	       exps)))
(espressioni (maggiore-o-uguale "maggiore o uguale del")
             (minore-o-uguale "minore o uguale del")
             (maggiore "maggiore del")
             (minore "minore del")
             (uguale "uguale al") 
             (diverso "diverso dal"))

(defparameter linguaggio (linguaggio (indicatore nil nil nil nil)
                                               (parametro nil nil)
                                               (argomento nil)
                                               (sinistri nil)
                                               (veicoli nil)
                                               (soggetti nil)
                                               (numero nil nil)
                                               (e)
                                               (o)
                                               (non nil)
                                               (coinvolto nil nil)
                                               (leso nil nil)
                                               (leso nil nil)
                                               (richiedente nil nil)
                                               (proprietario nil nil)
                                               (contraente nil nil)
                                               (deceduto nil nil)
                                               (testimone nil nil)
                                               (responsabile nil nil)
                                               (conducente nil nil)
                                               (patente-invalida nil nil)))
;; (synth output (synth to-doc (synth to-production linguaggio
;;                                    )) 0)


;; (indicatore* 
;;     sco1 
;;     (soggetto) 
;;     ((mesi numero) (occorrenze numero))
;;   (maggiore (numero (sinistri (or (coinvolto soggetto sinistro)
;;                                   (proprietario soggetto sinistro)))
;;                     (periodo mesi))
;;             occorrenze))


