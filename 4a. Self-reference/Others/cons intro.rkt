;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |cons intro|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
empty

(cons 1 (cons 2 (cons 3 empty)))
(define L1 (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 empty))))))

(first L1)                  ; retrieve 1st element
(rest L1)                   ; retrieve 2nd to last element
(first (rest L1))           ; retrieve 2nd element

(rest (rest L1))            ; retrieve 3rd to last element
(first (rest (rest L1)))    ; retrieve 3rd element

(empty? empty) ; true
(empty? L1)    ; false
(empty? 1)     ; false