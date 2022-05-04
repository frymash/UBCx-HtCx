;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname |List Abbreviations|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(cons "a" (cons "b" (cons "c" empty)))

(list "a" "b" "c")

(list (+ 1 2) (+ 3 4) (+ 5 6))

; =====================================

(define L1 (list "b" "c" "d"))

; Note that cons and list operate on different mechanisms.
; For example,

; cons joins 2 given elements together into a list
; Any Any -> List

(cons "a" L1) ; (list "a" "b" "c" "d")

; list creates a new list and takes the nth argument as
; the nth element of the new list
;

(list "a" L1) ; (list "a" (list "b" "c" "d"))


; =====================================

; append combines its arguments together in a single list
; List List List .... List -> List

(define L2 (list "e" "f" "g"))

(append L1 L2)
