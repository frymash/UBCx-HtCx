;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname merge-sort-v2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;; (listof Num) -> (listof Num)
;; merge sort

(check-expect (mergesort empty) empty)
(check-expect (mergesort (list 1)) (list 1))
(check-expect (mergesort (list 6 4)) (list 4 6))
(check-expect (mergesort (list 4 6)) (list 4 6))
(check-expect (mergesort (list 3 5 2 1 4 7 9 8 6)) (list 1 2 3 4 5 6 7 8 9))
(check-expect (mergesort (list 1 2 3 4 5 6 7 8 9)) (list 1 2 3 4 5 6 7 8 9))

(define (mergesort lon)
  (local [;; (listof Num) (listof Num) -> (listof Num)
          ;; sorts and merges 2 lists
          (define (merge lon1 lon2)
            (cond [(empty? lon1) lon2]
                  [(empty? lon2) lon1]
                  ;; (and (empty? lon1)(empty lon2)) is already accounted for by mergesort
                  [else
                   (if (< (first lon1)(first lon2))
                       (cons (first lon1)(merge (rest lon1) lon2))
                       (cons (first lon2)(merge lon1 (rest lon2))))]))
          (define (take lon n)
            (cond [(zero? n) empty] ;(1)
                  [else             ;(2)
                   (cons (first lon) (take (rest lon) (sub1 n)))]))

          (define (drop lon n)
            (cond [(zero? n) lon]   ;(1)
                  [else             ;(2)
                   (drop (rest lon) (sub1 n))]))]
    (cond [(empty? lon) empty]
          [(empty? (rest lon)) lon]
          [else
           (merge (mergesort (take lon (quotient (length lon) 2)))
                  (mergesort (drop lon (quotient (length lon) 2))))])))




