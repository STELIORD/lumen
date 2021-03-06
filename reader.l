(define delimiters (set-of "(" ")" "[" "]" "{" "}" ";" "\r" "\n"))
(define whitespace (set-of " " "\t" "\r" "\n"))

(define stream (str more)
  (obj pos: 0 string: str len: (# str) more: more))

(define peek-char (s)
  (let ((pos: pos len: len string: str) s)
    (when (< pos len)
      (char str pos))))

(define read-char (s)
  (let c (peek-char s)
    (if c (do (inc (get s 'pos)) c))))

(define skip-non-code (s)
  (while true
    (let c (peek-char s)
      (if (nil? c) (break)
          (get whitespace c) (read-char s)
          (= c ";")
          (do (while (and c (not (= c "\n")))
                (set c (read-char s)))
              (skip-non-code s))
        (break)))))

(define read-table (obj))

(define read (s eof)
  (skip-non-code s)
  (let c (peek-char s)
    (if (is? c)
        ((or (get read-table c)
             (get read-table ""))
         s)
      eof)))

(define read-all (s)
  (with l ()
    (let eof (obj)
      (while true
        (let form (read s eof)
          (if (= form eof) (break))
          (add l form))))))

(define-global read-string (str more)
  (read (stream str more)))

(define key? (atom)
  (and (string? atom)
       (> (# atom) 1)
       (= (char atom (edge atom)) ":")))

(define expected (s c)
  (let ((more: more pos: pos) s)
    (or more (error (cat "Expected " c " at " pos)))))

(define wrap (s x)
  (let y (read s)
    (if (= y (get s 'more)) y
      (list x y))))

(define hex-prefix? (str)
  (let i (if (= (code str 0) 45) 1 0)  ; "-"
    (and (= (code str i) 48)           ; "0"
         (let n (code str (inc i))
           (or (= n 120) (= n 88)))))) ; "x" or "X"

(define maybe-number (str)
  (if (hex-prefix? str)
      (target js: (parseInt str 16) lua: (tonumber str))
      (number-code? (code str (edge str)))
    (number str)))

(define real? (x)
  (and (number? x) (not (nan? x)) (not (inf? x))))

(define-reader ("" s) ; atom
  (let (str "")
    (while true
      (let c (peek-char s)
        (if (and c (and (not (get whitespace c))
                        (not (get delimiters c))))
            (cat! str (read-char s))
          (break))))
  (if (= str "true") true
      (= str "false") false
    (let n (maybe-number str)
      (if (real? n) n str)))))

(define-reader ("(" s)
  (read-char s)
  (with r nil
    (let l ()
      (while (nil? r)
        (skip-non-code s)
        (let c (peek-char s)
          (if (= c ")") (do (read-char s) (set r l))
              (nil? c) (set r (expected s ")"))
            (let x (read s)
              (if (key? x)
                  (let (k (clip x 0 (edge x))
                        v (read s))
                    (set (get l k) v))
                (add l x)))))))))

(define-reader (")" s)
  (error (cat "Unexpected ) at " (get s 'pos))))

(define-reader ("[" s)
  (read-char s)
  (with r nil
    (let (l '(%brackets) n 1)
      (while (nil? r)
        (skip-non-code s)
        (let c (peek-char s)
          (if (= c "]") (do (read-char s) (set r l))
              (nil? c) (set r (expected s "]"))
            (let x (read s)
              (set (at l n) x)
              (inc n))))))))

(define-reader ("]" s)
  (error (cat "Unexpected ] at " (get s 'pos))))

(define-reader ("{" s)
  (read-char s)
  (with r nil
    (let (l '(%braces) n 1)
      (while (nil? r)
        (skip-non-code s)
        (let c (peek-char s)
          (if (= c "}") (do (read-char s) (set r l))
              (nil? c) (set r (expected s "}"))
            (let x (read s)
              (set (at l n) x)
              (inc n))))))))

(define-reader ("}" s)
  (error (cat "Unexpected } at " (get s 'pos))))

(define-reader ("\"" s)
  (read-char s)
  (with r nil
    (let str "\""
      (while (nil? r)
        (let c (peek-char s)
          (if (= c "\"") (set r (cat str (read-char s)))
              (nil? c) (set r (expected s "\""))
            (do (when (= c "\\")
                  (cat! str (read-char s)))
                (cat! str (read-char s)))))))))

(define-reader ("|" s)
  (read-char s)
  (with r nil
    (let str "|"
      (while (nil? r)
        (let c (peek-char s)
          (if (= c "|") (set r (cat str (read-char s)))
              (nil? c) (set r (expected s "|"))
            (cat! str (read-char s))))))))

(define-reader ("'" s)
  (read-char s)
  (wrap s 'quote))

(define-reader ("`" s)
  (read-char s)
  (wrap s 'quasiquote))

(define-reader ("," s)
  (read-char s)
  (if (= (peek-char s) "@")
      (do (read-char s)
          (wrap s 'unquote-splicing))
    (wrap s 'unquote)))

(export stream
        read
        read-all
        read-string
        read-table)
