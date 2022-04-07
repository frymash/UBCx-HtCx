;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |celsius-fahrenheit converter|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(define (celsius-to-fahrenheit c)
  (+
   (* c (/ 9 5))
   32)
)

(define (fahrenheit-to-celsius f)
  (* (- f 32) (/ 5 9))
)

(celsius-to-fahrenheit 37.0)
(fahrenheit-to-celsius 98.6)