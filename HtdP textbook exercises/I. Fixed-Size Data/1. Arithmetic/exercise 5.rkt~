;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |exercise 5|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; Exercise 5. Use the 2htdp/image library to create the image of a simple boat
; or tree. Make sure you can easily change the scale of the entire image. 

(require 2htdp/image)

(define (boat scale)
  (above (triangle scale "solid" "black")
         (rectangle (* scale 3) (/ scale 1.5) "solid" "black")
  )
)

; boat <scale>
(boat 100)
