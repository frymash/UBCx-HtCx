;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |cat test|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; 1. Defining the cat

;; CatPosition is Number
;; interpretation: x coordinate of the act

(define CP1 0)
(define CP2 5)

#;
(define (fn-for-catposition cp)
  (...cp))

; Template rules used:
; - atomic non-distinct: Number


;; 2. Defining a function which translates the cat's position

;; CatPosition -> CatPosition
;; moves the cat's position by a specified distance

; (define (move-cat cp) 0)

(define distance 3)

(check-expect (move-cat 0) 3)
(check-expect (move-cat 3) 6)
(check-expect (move-cat 6) 9)

(define (move-cat cp)
  (+ cp distance))


;; 3. Defining a function which produces an image of the moving cat

;; CatPosition -> Image
;; produces an image of the moving cat based on its current position

; (define (render-cat cp) img)

(check-expect (render-cat 100)
              (place-image CAT-IMG 100 Y-COORD (empty-scene 20 20)))

#;
(define (render-cat cp)
  (place-image CAT-IMG cp Y-COORD (empty-scene 20 20)))


;; 4. Define a big-bang function which creates an animate image of a moving cat.

(require 2htdp/universe)

(big-bang 0               ; CatPosition
  (on-tick move-cat)      ; CatPosition -> CatPosition
  (to-draw render-cat))   ; CatPosition -> Image