;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname names-under-20) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(define-struct person (name age children))
;; Person is (make-person String Integer ListOfPerson)
;; a person's name, age, and a list of the person's children's names

;; ListOfPerson is one of:
;; - empty
;; - (cons Person ListOfPerson)
;; a list of people

(define P1 (make-person "N1" 15 empty))
(define P2 (make-person "N2" 40 (list P1)))
(define P3 (make-person "N3" 17 empty))
(define P4 (make-person "N4" 32 (list P3 P1)))

#;
(define (fn-for-person p)
  (... (person-name p)
       (person-age p)
       (fn-for-lop (person-children p))))

#;
(define (fn-for-lop lop)
  (cond [(empty? lop) (...)]
        [else
         (... (fn-for-person (first lop))
              (fn-for-lop (rest lop)))]))


;; Person -> ListOfString
;; ListOfPerson -> ListOfString
;; produce a list of the names of the persons under 20

(check-expect (names-under-20 P1) (list "N1"))
(check-expect (names-under-20 P2) (list "N1"))
(check-expect (names-under-20 P4) (list "N3" "N1"))

(define (names-under-20 p)
  (local [(define (names-under-20--person p)
            (if (< (person-age p) 20)
                (cons (person-name p)
                      (names-under-20--lop (person-children p)))
                (names-under-20--lop (person-children p))))

          (define (names-under-20--lop lop)
            (cond [(empty? lop) empty]
                  [else
                   (append (names-under-20--person (first lop))
                           (names-under-20--lop (rest lop)))]))]
    (names-under-20--person p)))
      
