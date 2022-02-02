;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname define-struct) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(define-struct coord (x y))

;; Constructors
(define P1 (make-coord 1 2))
(define P2 (make-coord 3 4))

;; Selectors
(coord-x P1) ; 1
(coord-y P2) ; 4

;; Predicates to check if data belongs to the compound data class
(coord? P1) ; true
(coord? "str") ; false