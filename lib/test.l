;; -*- mode: lisp -*-

(define passed 0)
(define failed 0)
(define tests ())

(define-macro test (x msg)
  `(if (not ,x)
       (do (set failed (+ failed 1))
	   (return ,msg))
     (inc passed)))

(define equal? (a b)
  (if (atom? a) (= a b)
    (= (string a) (string b))))

(define-macro test= (a b)
  `(test (equal? ,a ,b)
	 (cat "failed: expected " (string ,a) ", was " (string ,b))))

(define-macro define-test (name _ rest: body)
  `(add tests (list ',name (fn () ,@body))))

(define run-tests ()
  (all (_ (name f)) tests
    (let (result (f))
      (when (string? result)
        (pr " " name result))))
  (pr " " passed "passed," failed "failed"))

(define-test reader ()
  (test= nil (read-from-string ""))
  (test= 17 (read-from-string "17"))
  (test= 0.015 (read-from-string "1.5e-2"))
  (test= true (read-from-string "true"))
  (test= (not true) (read-from-string "false"))
  (test= 'hi (read-from-string "hi"))
  (test= '"hi" (read-from-string "\"hi\""))
  (test= "|hi|" (read-from-string "|hi|"))
  (test= '(1 2) (read-from-string "(1 2)"))
  (test= '(1 (a)) (read-from-string "(1 (a))"))
  (test= '(quote a) (read-from-string "'a"))
  (test= '(quasiquote a) (read-from-string "`a"))
  (test= '(quasiquote (unquote a)) (read-from-string "`,a"))
  (test= '(quasiquote (unquote-splicing a)) (read-from-string "`,@a"))
  (test= 2 (length (read-from-string "(1 2 a: 7)")))
  (test= 7 (get (read-from-string "(1 2 a: 7)") 'a))
  (test= #t (get (read-from-string "(:a)") 'a)))

(define-test boolean ()
  (test= #t (or #t #f))
  (test= #f (or #f #f))
  (test= #t (or #f #f #t))
  (test= #t (not #f))
  (test= #t (not (and #f #t)))
  (test= #f (not (or #f #t)))
  (test= #t (and #t #t))
  (test= #f (and #t #f))
  (test= #f (and #t #t #f)))

(define-test short ()
  (test= #t (or #t (error 'bad)))
  (test= #f (and #f (error 'bad)))
  (let (a #t)
    (test= #t (or #t (do (set a #f) #f)))
    (test= #t a)
    (test= #f (and #f (do (set a #f) #t)))
    (test= #t a))
  (let (b #t)
    (test= #t (or (do (set b #f) #f) (do (set b #t) b)))
    (test= #t b)
    (test= #t (or (do (set b #t) b) (do (set b #t) b)))
    (test= #t b)
    (test= #t (and (do (set b #f) #t) (do (set b #t) b)))
    (test= #t b)
    (test= #f (and (do (set b #f) b) (do (set b #t) b)))
    (test= #f b)))

(define-test numeric ()
  (test= 4 (+ 2 2))
  (test= 18 18.00)
  (test= 4 (- 7 3))
  (test= 5.0 (/ 10 2))
  (test= 6 (* 2 3.00))
  (test= #t (> 2.01 2))
  (test= #t (>= 5.0 5.0))
  (test= #t (> 2.1e3 2000))
  (test= #t (< 2e-3 0.0021))
  (test= #f (< 2 2))
  (test= #t (<= 2 2))
  (test= -7 (- 7)))

(define-test math ()
  (test= 3 (max 1 3))
  (test= 2 (min 2 7))
  (let (n (random))
    (test= #t (and (> n 0) (< n 1))))
  (test= 4 (floor 4.78)))

(define-test precedence ()
  (test= -3 (- (+ 1 2)))
  (test= 10 (- 12 (+ 1 1)))
  (test= 11 (- 12 (* 1 1)))
  (test= 10 (+ (/ 4 2) 8)))

(define-test string ()
  (test= 3 (length "foo"))
  (test= 3 (length "\"a\""))
  (test= 'a "a")
  (test= "a" (char "bar" 1))
  (let (s "a
b")
    (test= 3 (length s)))
(let (s "a
b
c")
    (test= 5 (length s)))
  (test= 3 (length "a\nb"))
  (test= 3 (length "a\\b")))

(define-test quote ()
  (test= 7 (quote 7))
  (test= #t (quote true))
  (test= #f (quote false))
  (test= (quote a) 'a)
  (test= (quote (quote a)) ''a)
  (test= "\"a\"" '"a")
  (test= "\"\\n\"" (quote "\n"))
  (test= "\"\\\\\"" (quote "\\"))
  (test= '(quote "a") ''"a")
  (test= "|(|" '|(|)
  (test= (quote unquote) 'unquote)
  (test= (quote (unquote)) '(unquote))
  (test= (quote (unquote a)) '(unquote a)))

(define-test list ()
  (test= '() (list))
  (test= () (list))
  (test= '(a) (list 'a))
  (test= '(a) (quote (a)))
  (test= '(()) (list (list)))
  (test= 0 (length (list)))
  (test= 2 (length (list 1 2)))
  (test= '(1 2 3) (list 1 2 3))
  (test= 17 (get (list foo: 17) 'foo))
  (test= 17 (get (list 1 foo: 17) 'foo))
  (test= #t (get (list :foo) 'foo))
  (test= #t (get '(:foo) 'foo))
  (test= #t (get (hd '((:foo))) 'foo))
  (test= '(:a) (list :a))
  (test= '(b: #f) (list b: #f))
  (test= '(c: 0) (list c: 0)))

(define-test quasiquote ()
  (test= (quote a) (quasiquote a))
  (test= 'a `a)
  (test= () `())
  (test= 2 `,2)
  (test= nil `(,@nil))
  (let (a 42)
    (test= 42 `,a)
    (test= 42 (quasiquote (unquote a)))
    (test= '(quasiquote (unquote a)) ``,a)
    (test= '(quasiquote (unquote 42)) ``,,a)
    (test= '(quasiquote (quasiquote (unquote (unquote a)))) ```,,a)
    (test= '(quasiquote (quasiquote (unquote (unquote 42)))) ```,,,a)
    (test= '(a (quasiquote (b (unquote c)))) `(a `(b ,c)))
    (test= '(a (quasiquote (b (unquote 42)))) `(a `(b ,,a)))
    (let (b 'c)
      (test= '(quote c) `',b)
      (test= '(42) `(,a))
      (test= '((42)) `((,a)))
      (test= '(41 (42)) `(41 (,a)))))
  (let (c '(1 2 3))
    (test= '((1 2 3)) `(,c))
    (test= '(1 2 3) `(,@c))
    (test= '(0 1 2 3) `(0 ,@c))
    (test= '(0 1 2 3 4) `(0 ,@c 4))
    (test= '(0 (1 2 3) 4) `(0 (,@c) 4))
    (test= '(1 2 3 1 2 3) `(,@c ,@c))
    (test= '((1 2 3) 1 2 3) `((,@c) ,@c)))
  (let (a 42)
    (test= '(quasiquote ((unquote-splicing (list a)))) ``(,@(list a)))
    (test= '(quasiquote ((unquote-splicing (list 42)))) ``(,@(list ,a))))
  (test= #t (get `(:foo) 'foo))
  (let (a 17
        b '(1 2)
        c (table a: 10)
        d (list a: 10))
    (test= 17 (get `(foo: ,a) 'foo))
    (test= 2 (length `(foo: ,a ,@b)))
    (test= 17 (get `(foo: ,@a) 'foo))
    (test= '(1 a: 10) `(1 ,@c))
    (test= '(1 a: 10) `(1 ,@d))
    (test= #t (get (hd `((:foo))) 'foo))
    (test= #t (get (hd `(,(list :foo))) 'foo))
    (test= #t (get `(,@(list :foo)) 'foo))
    (test= #t (get `(1 2 3 ,@'(:foo)) 'foo)))
  (let-macro ((a keys `(table ,@keys)))
    (test= #t (get (a :foo) 'foo))
    (test= 17 (get (a bar: 17) 'bar)))
  (let-macro ((a () `(table baz: (fn () 17))))
    (test= 17 ((get (a) 'baz)))))

(define-test quasiexpand ()
  (test= 'a (macroexpand 'a))
  (test= '(17) (macroexpand '(17)))
  (test= '(1 z) (macroexpand '(1 z)))
  (test= '(%array 1 "z") (macroexpand '`(1 z)))
  (test= '(%array 1 z) (macroexpand '`(,1 ,z)))
  (test= 'z (macroexpand '`(,@z)))
  (test= '(join (%array 1) z) (macroexpand '`(,1 ,@z)))
  (test= '(join (%array 1) (join x y)) (macroexpand '`(,1 ,@x ,@y)))
  (test= '(join (%array 1) (join z (%array 2))) (macroexpand '`(,1 ,@z ,2)))
  (test= '(join (%array 1) (join z (%array "a"))) (macroexpand '`(,1 ,@z a)))
  (test= '"x" (macroexpand '`x))
  (test= '(%array "quasiquote" "x") (macroexpand '``x))
  (test= '(%array "quasiquote" (%array "quasiquote" "x")) (macroexpand '```x))
  (test= 'x (macroexpand '`,x))
  (test= '(%array "quote" x) (macroexpand '`',x))
  (test= '(%array "quasiquote" (%array "x")) (macroexpand '``(x)))
  (test= '(%array "quasiquote" (%array "unquote" "a")) (macroexpand '``,a))
  (test= '(%array "quasiquote" (%array (%array "unquote" "x")))
         (macroexpand '``(,x))))

(define-test calls ()
  (let (f (fn () 42)
	l (list f)
	t (table f: f))
    (test= 42 (f))
    (test= 42 ((at l 0)))
    (test= 42 (t.f))
    (test= 42 ((get t 'f)))
    (test= nil ((fn () (return))))
    (test= 10 ((fn (x) (- x 2)) 12))))

(define-test id ()
  (let (a 10
        b (table x: 20)
        f (fn () 30))
    (test= 10 a)
    (test= 10 |a|)
    (test= 20 |b.x|)
    (test= 30 |f()|)))

(define-test names ()
  (let (a! 0
        b? 1
        -% 2
        ** 3
        break 4)
    (test= 0 a!)
    (test= 1 b?)
    (test= 2 -%)
    (test= 3 **)
    (test= 4 break)))

(define-test set ()
  (let (a 42)
    (set a 'bar)
    (test= 'bar a)
    (let (x (set a 10))
      (test= x nil)
      (test= a 10))
    (set a #f)
    (test= a #f)
    (set a)
    (test= a nil)))

(define-test do ()
  (let (a 17)
    (do (set a 10)
	(test= 10 a))
    (test= 10 (do a))
    (let (b (do (set a 2) (+ a 5)))
      (test= a 2)
      (test= b 7))
    (do (set a 10)
        (do (set a 20)
            (test= 20 a)))
    (test= 20 (do (set a 10)
                  (do (set a 20) a)))))

(define-test if ()
  (test= 'a (macroexpand '(if a)))
  (test= '(%if a b) (macroexpand '(if a b)))
  (test= '(%if a b c) (macroexpand '(if a b c)))
  (test= '(%if a b (%if c d)) (macroexpand '(if a b c d)))
  (test= '(%if a b (%if c d e)) (macroexpand '(if a b c d e)))
  (if #t
      (test= #t #t)
    (test= #t #f))
  (if #f (test= #t #f)
      #f (test= #f #t)
    (test= #t #t))
  (if #f (test= #t #f)
      #f (test= #f #t)
      #f (test= #f #t)
    (test= #t #t))
  (if #f (test= #t #f)
      #t (test= #t #t)
      #f (test= #f #t)
    (test= #t #t))
  (test= 1 (if #t 1 2))
  (test= 1 (if (let (a 10) a) 1 2))
  (test= 1 (if #t (let (a 1) a) 2))
  (test= 1 (if #f 2 (let (a 1) a)))
  (test= 1 (if #f 2 #t (let (a 1) a)))
  (test= 1 (if #f 2 #f 3 (let (a 1) a))))

(define-test while ()
  (let (i 0)
    (while (< i 5)
      (if (= i 3) (break) (inc i)))
    (test= 3 i)
    (while (< i 10)
      (inc i))
    (test= 10 i)
    (let (a (while (< i 15) (inc i)))
      (test= nil a)
      (test= 15 i))
    (let (b (while (< i 20)
              (if (= i 19)
                  (break)
                (inc i))))
      (test= nil a)
      (test= 19 i))))

(define-test table ()
  (test= 10 (get (table a: 10) 'a))
  (test= #t (get (table :a) 'a)))

(define-test empty ()
  (test= #t (empty? ()))
  (test= #t (empty? (table)))
  (test= #f (empty? '(1)))
  (test= #f (empty? '(:a)))
  (test= #f (empty? (table :a)))
  (test= #f (empty? '(b: #f))))

(define-test get-set ()
  (let (t (table))
    (set (get t 'foo) 'bar)
    (test= 'bar (get t 'foo))
    (test= 'bar (get t "foo"))
    (let (k 'foo)
      (test= 'bar (get t k)))
    (test= 'bar (get t (cat "f" "oo")))))

(define-test all ()
  (let (t '(1 2 3 :a b: #f))
    (let (a 0 b 0)
      (all (k v) t
        (if (number? k)
            (inc a)
          (inc b)))
      (test= 3 a)
      (test= 2 b))
    (let (a 0)
      (all (_ _) t (inc a))
      (test= 5 a))))

(define-test fn ()
  (let (f (fn (n) (+ n 10)))
    (test= 20 (f 10))
    (test= 30 (f 20))
    (test= 40 ((fn (n) (+ n 10)) 30))
    (test= '(2 3 4) (map (fn (x) (+ x 1)) '(1 2 3)))))

(define-test let-fn ()
  (let-fn (f (n) (+ n 10))
    (test= 20 (f 10))))

(define-test return ()
  (let (a ((fn () 17)))
    (test= 17 a))
  (let (a ((fn () (if #t 10 20))))
    (test= 10 a))
  (let (a ((fn () (while #f (blah)))))
    (test= nil a))
  (let (a 11)
    (let (b ((fn () (inc a))))
      (test= nil b)
      (test= 12 a))))

(define-test guard ()
  (test= '(#t 42) (guard 42))
  (test= '(#f foo) (guard (error "foo")))
  (test= '(#f foo) (guard (do (error "foo") (error "baz"))))
  (test= '(#t 42) (guard (if #t 42 (error "baz"))))
  (test= '(#f baz) (guard (if #f 42 (error "baz")))))

(define-test let ()
  (let (a 10)
    (test= 10 a))
  (let (a 11
	b 12)
    (test= 11 a)
    (test= 12 b))
  (let (a 1)
    (test= 1 a)
    (let (a 2)
      (test= 2 a))
    (test= 1 a))
  (let (a 1)
    (let (a 2)
      (let (a 3)
        (test= a 3))
      (test= a 2))
    (test= a 1))
  (let (a 20)
    (test= 20 a)
    (let (a (+ a 7))
      (test= 27 a))
    (let (a (+ a 10))
      (test= 30 a))
    (test= 20 a))
  (test= 10 (let (a 10) a))
  (let (a (let (b 12) b))
    (test= 12 a))
  (let (a (let (a 10) a))
    (test= 10 a))
  (let (a (+ (let (a 0)
               (set a 10)
               (+ a 2))
             3))
    (test= a 15))
  ((fn (zz)
     (test= 20 zz)
     (let (zz 21)
       (test= 21 zz))
     (test= 20 zz))
   20))

(define-test destructuring ()
  (let ((a b c) '(1 2 3))
    (test= 1 a)
    (test= 2 b)
    (test= 3 c))
  (let ((_ b) '(1 2))
    (test= 2 b))
  (let ((w (x (y) z)) '(1 (2 (3) 4)))
    (test= 1 w)
    (test= 2 x)
    (test= 3 y)
    (test= 4 z))
  (let ((a b rest: c) '(1 2 3 4))
    (test= '(3 4) c))
  (let ((w (x rest: y) rest: z) '(1 (2 3 4) 5 6 7))
    (test= '(3 4) y)
    (test= '(5 6 7) z))
  (let ((:foo) (table foo: 99))
    (test= 99 foo))
  (let ((:foo) (list foo: 99))
    (test= 99 foo))
  (let ((foo: a) (table foo: 99))
    (test= 99 a))
  (let ((foo: (a b)) (table foo: '(98 99)))
    (test= 98 a)
    (test= 99 b))
  (let ((:foo bar: (:baz))
        (table foo: 42 bar: '(99 :baz)))
    (test= 42 foo)
    (test= #t baz))
  (let ((a (b :foo) :bar)
        (list 10 (list 20 foo: 17) bar: '(1 2 3)))
    (test= 10 a)
    (test= 20 b)
    (test= 17 foo)
    (test= '(1 2 3) bar)))

(define-test let-macro ()
  (let-macro ((a () 17)
              (b (a) `(+ ,a 10)))
    (test= 17 (a))
    (test= 42 (b 32))
    (let-macro ((a () 1))
      (test= 1 (a)))
    (test= 17 (a)))
  (let-macro ((a () 18))
    (let (b (fn () 20))
      (test= 18 (a))
      (test= 20 (b))))
  (let-macro ((a (x)
                (let (x 10)
                  (set x 20))
                `(+ ,x 1)))
    (test= 2 (a 1))))

(define-test let-symbol ()
  (let-symbol (a 17
               b (+ 10 7))
    (test= 17 a)
    (test= 17 b)
    (let-symbol (a 1)
      (test= 1 a))
    (test= 17 a))
  (let-symbol (a 18)
    (let (b 20)
      (test= 18 a)
      (test= 20 b))))

(define-test define-symbol ()
  (define-symbol zzz 42)
  (test= zzz 42))

(define-test macros-and-symbols ()
  (let-symbol (a 1)
    (let-macro ((a () 2))
      (test= 2 (a)))
    (test= 1 a))
  (let-macro ((a () 2))
    (let-symbol (a 1)
      (test= 1 a))
    (test= 2 (a))))

(define-test macros-and-let ()
  (let (a 10)
    (test= a 10)
    (let-macro ((a () 12))
      (test= 12 (a)))
    (test= a 10))
  (let (b 20)
    (test= b 20)
    (let-symbol (b 22)
      (test= 22 b))
    (test= b 20))
  (let-macro ((c () 30))
    (test= 30 (c))
    (let (c 32)
      (test= 32 c))
    (test= 30 (c)))
  (let-symbol (d 40)
    (test= 40 d)
    (let (d 42)
      (test= 42 d))
    (test= 40 d)))

(define-test symbols ()
  (test= true #t)
  (test= #f #f)
  (test= #t (< #-inf -1e10))
  (test= #f (< #+inf -1e10))
  (test= #f (= #nan #nan))
  (test= #t (nan? #nan))
  (test= #t (nan? (* #nan 20))))

(define-test add ()
  (let (l ())
    (add l 'a)
    (add l 'b)
    (add l 'c)
    (test= '(a b c) l)
    (test= nil (add () 'a))))

(define-test drop ()
  (let (l '(a b c))
    (test= 'c (drop l))
    (test= 'b (drop l))
    (test= 'a (drop l))
    (test= nil (drop l))))

(define-test last ()
  (test= 3 (last '(1 2 3)))
  (test= nil (last ()))
  (test= 'c (last '(a b c))))

(define-test join ()
  (test= '(1 2 3) (join '(1 2) '(3)))
  (test= '(1 2) (join () '(1 2)))
  (test= () (join () ()))
  (test= () (join nil nil))
  (test= () (join nil ()))
  (test= () (join))
  (test= () (join ()))
  (test= '(1) (join '(1) nil))
  (test= '(a) (join '(a) ()))
  (test= '(a) (join nil '(a)))
  (test= '(a) (join '(a)))
  (test= '(a :b) (join '(a) (table :b)))
  (test= '(a b :b) (join '(a) '(b :b)))
  (test= '(a b: 10) (join '(a :b) (table b: 10)))
  (test= '(b: 10) (join (table :b) '(b: 10)))
  (let (t (join '(a b: 1) '(b c: 2)))
    (test= 1 t.b)
    (test= 2 t.c)
    (test= 'b (at t 1))))

(define-test reverse ()
  (test= () (reverse ()))
  (test= '(3 2 1) (reverse '(1 2 3)))
  (test= '(3 2 1 :a) (reverse '(1 2 3 :a))))

(define-test map ()
  (test= () (map (fn (x) x) ()))
  (test= '(1) (map (fn (x) x) '(1)))
  (test= '(2 3 4) (map (fn (x) (+ x 1)) '(1 2 3)))
  (test= '(2 3 4 a: 5) (map (fn (x) (+ x 1)) (list 1 2 3 a: 4)))
  (test= '(:a) (map (fn (x) x) '(:a)))
  (test= '(b: #f) (map (fn (x) x) '(b: #f)))
  (test= '(:a b: #f) (map (fn (x) x) '(:a b: #f))))

(define-test cut ()
  (test= () (cut ()))
  (test= '(a) (cut '(a)))
  (test= '(b c) (cut '(a b c) 1))
  (test= '(b c) (cut '(a b c d) 1 3))
  (test= '(1 2 3) (cut '(1 2 3) 0 10))
  (test= '(1) (cut '(1 2 3) -4 1))
  (test= '(1 2 3) (cut '(1 2 3) -4))
  (test= '(2 :a) (cut '(1 2 :a) 1))
  (test= '(:a b: 2) (cut '(:a b: 2)))
  (let (t '(1 2 3))
    (test= () (cut t (length t))))
  (let (t '(1 2 3 :a))
    (test= '(:a) (cut t (length t)))))

(define-test clip ()
  (test= "uux" (clip "quux" 1))
  (test= "uu" (clip "quux" 1 3))
  (test= "" (clip "quux" 5))
  (test= "ab" (clip "ab" 0 4))
  (test= "ab" (clip "ab" -4 4))
  (test= "a" (clip "ab" -1 1)))

(define-test search ()
  (test= nil (search "" "a"))
  (test= 0 (search "" ""))
  (test= 0 (search "a" ""))
  (test= 0 (search "abc" "a"))
  (test= 2 (search "abcd" "cd"))
  (test= nil (search "abcd" "ce"))
  (test= nil (search "abc" "z")))

(define-test split ()
  (test= () (split "" ""))
  (test= () (split "" ","))
  (test= (list "a") (split "a" ","))
  (test= (list "a" "") (split "a," ","))
  (test= (list "a" "b") (split "a,b" ","))
  (test= (list "a" "b" "") (split "a,b," ",")))

(define-test reduce ()
  (test= 'a (reduce (fn (a b) (+ a b)) '(a)))
  (test= 6 (reduce (fn (a b) (+ a b)) '(1 2 3)))
  (test= '(1 (2 3))
         (reduce
          (fn (a b) (list a b))
          '(1 2 3)))
  (test= '(1 2 3 4 5)
         (reduce
          (fn (a b) (join a b))
          '((1) (2 3) (4 5)))))

(define-test keep ()
  (test= () (keep (fn (x) x) ()))
  (let (even (fn (x) (= (% x 2) 0)))
    (test= '(6) (keep even '(5 6 7))))
  (test= '((1) (2 3)) (keep some? '(() (1) () (2 3)))))

(define-test in? ()
  (test= #t (in? 'x '(x y z)))
  (test= #t (in? 7 '(5 6 7)))
  (test= nil (in? 'baz '(no can do))))

(define-test find ()
  (test= nil (find (fn (x) x) ()))
  (test= 7 (find (fn (x) x) '(7)))
  (test= #t (find (fn (x) (= x 7)) '(2 4 7)))
  (test= #t (find (fn (x) (= x 7)) '(2 4 foo: 7)))
  (test= #t (find (fn (x) (= x #t)) '(2 4 :bar)))
  (test= #t (in? 7 '(2 4 7)))
  (test= #t (in? 7 '(2 4 foo: 7)))
  (test= #t (in? #t '(2 4 :bar))))

(define-test find ()
  (test= nil (first (fn (x) x) ()))
  (test= 7 (first (fn (x) x) '(7)))
  (test= #t (first (fn (x) (= x 7)) '(2 4 7)))
  (test= 4 (first (fn (x) (and (> x 3) x)) '(1 2 3 4 5 6))))

(define-test sort ()
  (test= '(a b c) (sort '(c a b)))
  (test= '(3 2 1) (sort '(1 2 3) >)))

(define-test type ()
  (test= #t (atom? nil))
  (test= #t (atom? "abc"))
  (test= #t (atom? 42))
  (test= #t (atom? #t))
  (test= #t (atom? (fn ())))
  (test= #f (atom? '(1)))
  (test= #f (atom? (table)))
  (test= #t (string? "abc"))
  (test= #f (string? 17))
  (test= #f (string? '(a)))
  (test= #f (string? #t))
  (test= #f (string? (table)))
  (test= #f (number? "abc"))
  (test= #t (number? 17))
  (test= #f (number? '(a)))
  (test= #f (number? #t))
  (test= #f (number? (table)))
  (test= #f (boolean? "abc"))
  (test= #f (boolean? 17))
  (test= #f (boolean? '(a)))
  (test= #t (boolean? #t))
  (test= #f (boolean? (table)))
  (test= #f (function? 17))
  (test= #f (function? "foo"))
  (test= #f (function? '(a)))
  (test= #f (function? (table)))
  (test= #t (function? (fn () 17)))
  (test= #f (list? "abc"))
  (test= #f (list? 17))
  (test= #t (list? '(a)))
  (test= #f (list? #t))
  (test= #f (list? (table)))
  (test= #f (table? "abc"))
  (test= #f (table? 17))
  (test= #f (table? '(a)))
  (test= #f (table? #t))
  (test= #t (table? (table))))

(define-test apply ()
  (test= 4 (apply (fn (a b) (+ a b)) '(2 2)))
  (test= '(2 2) (apply (fn a a) '(2 2)))
  (let (t '(1))
    (set (get t 'foo) 17)
    (test= 17 (apply (fn a (get a 'foo)) t)))
  (test= 42 (apply (fn (:foo) foo) (list foo: 42)))
  (test= 42 (apply (fn ((:foo)) foo) (list (list foo: 42)))))

(define-test eval ()
  (test= 4 (eval '(+ 2 2)))
  (test= 5 (eval '(let (a 3) (+ 2 a))))
  (test= 9 (eval '(do (define x 7) (+ x 2))))
  (test= 6 (eval '(apply + '(1 2 3)))))

(define-test parameters ()
  (test= 42 ((fn ((a)) a) '(42)))
  (let (f (fn (a (b c)) (list a b c)))
    (test= '(1 2 3) (f 1 '(2 3))))
  (let (f (fn (a (b rest: c) rest: d) (list a b c d)))
    (test= '(1 2 (3 4) (5 6 7)) (f 1 '(2 3 4) 5 6 7)))
  (test= '(3 4) ((fn (a b rest: c) c) 1 2 3 4))
  (let (f (fn (w (x rest: y) rest: z) (list y z)))
    (test= '((3 4) (5 6 7)) (f 1 '(2 3 4) 5 6 7)))
  (test= 42 ((fn (:foo) foo) foo: 42))
  (test= 42 ((fn ((:foo)) foo) (list foo: 42)))
  (let (f (fn (a bar: b (:foo)) (list a b foo)))
    (test= '(10 20 42) (f 10 bar: 20 (list foo: 42)))))
