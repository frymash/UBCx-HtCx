;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders-without-function-templates) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders

;; ==========
;; Constants:
;; ==========
;; Disclaimer: The majority of the constants were pre-defined by the course instructors.
;; However, I have modified them to fit the idea of the game I wish to build.

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 2)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 2)
(define TANK-SPEED 4)
(define MISSILE-SPEED -5)

(define HIT-RANGE 10)

(define INVADE-RATE 100)

(define MTS (empty-scene WIDTH HEIGHT))

(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2))

(define MISSILE (ellipse 5 15 "solid" "red"))

(define BLANK (square 0 "solid" "white"))

(define TANK-OFFSET (- HEIGHT 15)) ; distance between the tank and the bottom of the frame
(define MISSILE-OFFSET 20)

(define NEW_INVADER_FREQUENCY 1)


;; =================
;; Data Definitions:
;; =================

(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below ListOfMissile data definition


(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left


(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader along x by dx pixels per clock tick

(define I1 (make-invader 150 100 3))           ;not landed, moving right
(define I2 (make-invader 150 200 -1)) 
(define I7 (make-invader 150 TANK-OFFSET -1))       ;exactly landed, moving left
(define I8 (make-invader 150 (+ TANK-OFFSET 1) 1)) ;> landed, moving right

; these examples were created to test the advance-invader function:
(define I4 (make-invader 150 100 -12))
(define I5 (make-invader 150 100 0))

; these examples were created to test the game:
(define I6 (make-invader 0 0 -2))
(define END_INVADER (make-invader 0 TANK-OFFSET 2))
(define COLLIDE_INVADER (make-invader 200 50 -2))


;; ListOfInvader is one of:
;; - empty
;; - (cons Invader ListofInvader)
;; interp. a list of Invaders present in the current state of the game

(define LOI1 empty)
(define LOI2 (list I1))
(define LOI3 (list I2 I1))


(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))    ;not hit U1
(define M2 (make-missile 150 (+ (invader-y I1) 10))) ; exactly hit U1
(define M3 (make-missile 150 (+ (invader-y I1) 5)))  ; overhit U1
(define COLLIDE_MISSILE (make-missile 200 50))


;; ListOfMissile is one of:
;; - empty
;; - (cons Missile ListOfMissile)
;; interp. a list of Missiles present in the current state of the game

(define LOM1 empty)
(define LOM2 (list M1))
(define LOM3 (list M2 M1))


;; Examples from the data definition for Game earlier on:

(define G0 (make-game empty empty T0))
(define G1 (make-game empty empty T1))
(define G2 (make-game (list I1) (list M1) T2))
(define G3 (make-game (list I1 I2) (list M1 M2) T1))

(define G4 (make-game empty empty T2))

(define END_GAME (make-game (list END_INVADER)
                            empty
                            T0))


;; ==========
;; Functions:
;; ==========

(define (main game)
  (big-bang game
    (on-tick advance-game)
    (to-draw render-game)
    (on-key shoot-or-scoot)))


;; Game -> Game
;; interp. moves the missiles, invaders, and tanks by preset speeds
;; every tick

(check-expect (advance-game G0)
              (make-game empty
                         empty
                         (advance-tank (game-tank G0)))) ; (game-tank G0) -> T0 -> (make-tank (/ WIDTH 2) 1)

;; (define G3 (make-game (list I1 I2) (list M1 M2) T1))
(check-expect (advance-game G3)
              (make-game (advance-loi (game-invaders G3)(game-missiles G3))
                         (advance-lom (game-invaders G3)(game-missiles G3))
                         (advance-tank (game-tank G3))))

;; edge case 1: an invader reaches the bottom of the screen. game must end
(check-expect (advance-game END_GAME)
              (make-game (game-invaders END_GAME)
                         (game-missiles END_GAME)
                         (game-tank END_GAME)))

(define (advance-game g)
  (cond [(invader-win? (game-invaders g))
          (make-game (game-invaders g)
                     (game-missiles g)
                     (game-tank g))]
        [(<= (random 50) NEW_INVADER_FREQUENCY)
         (make-game (advance-loi (append (game-invaders g)
                                         (list (make-invader (random WIDTH)
                                                       -5
                                                       INVADER-Y-SPEED)))
                                 (game-missiles g))
                    (advance-lom (game-invaders g)(game-missiles g))
                    (advance-tank (game-tank g)))]
        [(<= (random 100) NEW_INVADER_FREQUENCY)
         (make-game (advance-loi (append (game-invaders g)
                                         (list (make-invader (random WIDTH)
                                                             -5
                                                             (- INVADER-Y-SPEED))))
                                 (game-missiles g))
                    (advance-lom (game-invaders g)(game-missiles g))
                    (advance-tank (game-tank g)))] 
        [else
         (make-game (advance-loi (game-invaders g)(game-missiles g))
                    (advance-lom (game-invaders g)(game-missiles g))
                    (advance-tank (game-tank g)))]))



;; ListOfInvader -> Boolean
;; interp. returns true if an Invader in the ListOfInvader has reached the
;; bottom of the frame

;; (define (invader-win? LOI1) true) ; stub

(check-expect (invader-win? empty) false)
(check-expect (invader-win? (list END_INVADER)) true)
(check-expect (invader-win? (list I1)) false)
(check-expect (invader-win? (list I1 I6)) false)
(check-expect (invader-win? (list I1 I6 END_INVADER)) true)

(define (invader-win? loi)
  (cond [(empty? loi) false]
        [(>= (invader-y (first loi))
                 TANK-OFFSET) true]
        [else
         (invader-win? (rest loi))]))


;; ListOfInvader ListOfMissile -> ListOfInvader
;; interp. moves a list of invaders 45 degrees downwards at invader-dx speed
;; or removes invaders which collide with missiles

(check-expect (advance-loi empty empty) empty)

(check-expect (advance-loi (list I1) empty)
              (list (advance-invader I1)))

(check-expect (advance-loi (list I2 I1) empty)
              (list (advance-invader I2)
                    (advance-invader I1)))

(check-expect (advance-loi (list COLLIDE_INVADER I1 I2)
                           (list COLLIDE_MISSILE))
              (list (advance-invader I1)
                    (advance-invader I2)))

(define (advance-loi loi lom)
  (cond [(empty? loi) empty]
        [(collide-invader? (first loi) lom)
         (advance-loi (rest loi) lom)]
        [else
         (cons (advance-invader (first loi))
               (advance-loi (rest loi) lom))]))


;; Invader ListOfMissile -> Boolean
;; interp. returns true if the invader collides with any missile
;; in the ListOfMissile

(check-expect (collide-invader? COLLIDE_INVADER
                        empty)
              false)

(check-expect (collide-invader? COLLIDE_INVADER
                        (list (make-missile 40 40)))
              false)

(check-expect (collide-invader? COLLIDE_INVADER
                        (list COLLIDE_MISSILE))
              true)

(check-expect (collide-invader? COLLIDE_INVADER
                        (list (make-missile 40 40)
                              (make-missile 50 50)))
              false)

(check-expect (collide-invader? COLLIDE_INVADER
                        (list (make-missile 40 40)
                              COLLIDE_MISSILE))
              true)

(check-expect (collide-invader? COLLIDE_INVADER
                        (list (make-missile 40 40)
                              (make-missile 50 50)
                              COLLIDE_MISSILE
                              (make-missile 60 60)))
              true)

(check-expect (collide-invader? (make-invader 55 55 -1)
                        (list (make-missile 40 40)
                              (make-missile 50 50)
                              COLLIDE_MISSILE
                              (make-missile 60 60)))
              true)

(define (collide-invader? i lom)
  (cond [(empty? lom) false]
        ; ensure that a collision will be registered as long as
        ; ANY PART of the INVADER image is hit
        [(and (<= (- (invader-x i)
                     (/ (image-width INVADER) 2))
                  (missile-x (first lom))
                  (+ (invader-x i)
                     (/ (image-width INVADER) 2)))
              (<= (- (invader-y i)
                     (/ (image-height INVADER) 2))
                  (missile-y (first lom))
                  (+ (invader-y i)
                     (/ (image-height INVADER) 2))))
         true]
        [else
         (collide-invader? i (rest lom))]))


;; Invader -> Invader
;; interp. moves ONE invader 45 degrees downwards at invader-dx speed
;; if the invader hits a wall, it bounces off at a 45 degree angle
;; and continues in the opposite direction

;; (define (advance-invader invader) I1) ; stub

(check-expect (advance-invader I4) ; invader moving left, -ve invader-dx
              (make-invader (+ (invader-x I4)
                               (invader-dx I4))
                            (- (invader-y I4)
                               (invader-dx I4))
                            (invader-dx I4)))

(check-expect (advance-invader I1) ; invader moving right, +ve invader-dx
              (make-invader (+ (invader-x I1)
                               (invader-dx I1))
                            (+ (invader-y I1)
                               (invader-dx I1))
                            (invader-dx I1)))

(check-expect (advance-invader I5) ; invader is stationary, invader-dx = 0
              (make-invader (invader-x I5)
                            (invader-y I5)
                            (invader-dx I5)))

; edge case 1a: invader moves left and hits left side of screen, needs to change direction
(check-expect (advance-invader (make-invader 0 100 -12))
              (make-invader 0 100 12))

; edge case 1b: invader moves right from the left side of the screen
(check-expect (advance-invader (make-invader 0 100 12))
              (make-invader 12 112 12))

; edge case 2: invader moves right and hits right side of screen, needs to change direction
(check-expect (advance-invader (make-invader WIDTH 100 12))
              (make-invader WIDTH 100 -12))

(define (advance-invader i)
  (cond [(or (and (<= -5
                      (invader-x i)
                      0)
                  (< (invader-dx i) 0))        ; invader hits left side of screen (with a 5 pixel buffer)
             (and (<= WIDTH
                      (invader-x i)
                      (+ WIDTH 5))
                  (> (invader-dx i) 0)))       ; invader hits right side of screen (with a 5 pixel buffer)
         (make-invader
          (invader-x i)
          (invader-y i)
          (- (invader-dx i)))]
        [(< (invader-dx i) 0)            ; invader moving left, -ve invader-dx
         (make-invader
          (+ (invader-x i)
             (invader-dx i))
          (- (invader-y i)
             (invader-dx i))
          (invader-dx i))]
        [(> (invader-dx i) 0)            ; invader moving right, +ve invader-dx 
         (make-invader
          (+ (invader-x i)
             (invader-dx i))
          (+ (invader-y i)
             (invader-dx i))
          (invader-dx i))]
        [else                           ; invader remains still, invader-dx = 0
         (make-invader
          (invader-x i)
          (invader-y i)
          (invader-dx i))]))


;; ListOfInvaders ListOfMissiles -> ListOfMissiles
;; interp. moves a list of missiles upwards onscreen by MISSILE-SPEED after every tick

(check-expect (advance-lom empty (list M1))
              (list (advance-missile M1)))

(check-expect (advance-lom empty (list M2 M1))
              (list (advance-missile M2)
                    (advance-missile M1)))

(define (advance-lom loi lom)
  (cond [(empty? lom) empty]
        [(collide-missiles? (first lom) loi)
         (advance-lom loi (rest lom))]
        [else
         (cons (advance-missile (first lom))
               (advance-lom loi (rest lom)))]))


;; Missile ListOfInvaders -> Boolean
;; returns true if the missile collides with any invader
;; in the ListOfInvaders

(check-expect (collide-missiles? COLLIDE_MISSILE empty) false)

(check-expect (collide-missiles? COLLIDE_MISSILE
                                 (list (make-invader 40 40 1)))
              false)

(check-expect (collide-missiles? COLLIDE_MISSILE
                                 (list COLLIDE_INVADER))
              true)

(check-expect (collide-missiles? COLLIDE_MISSILE
                                 (list (make-invader 40 40 1)
                                       (make-invader 50 50 1)))
              false)

(check-expect (collide-missiles? COLLIDE_MISSILE
                                 (list (make-invader 40 40 1)
                                       (make-invader 50 50 1)
                                       COLLIDE_INVADER
                                       (make-invader 60 60 1)))
              true)

(check-expect (collide-missiles? (make-missile 55 55)
                                 (list (make-invader 40 40 1)
                                       (make-invader 50 50 1)
                                       COLLIDE_INVADER
                                       (make-invader 60 60 1)))
              true)

(define (collide-missiles? m loi)
  (cond [(empty? loi) false]
        ; ensure that a collision will be registered as long as
        ; ANY PART of the INVADER image is hit
        [(and (<= (- (invader-x (first loi))
                     (/ (image-width INVADER) 2))
                  (missile-x m)
                  (+ (invader-x (first loi))
                     (/ (image-width INVADER) 2)))
              (<= (- (invader-y (first loi))
                     (/ (image-height INVADER) 2))
                  (missile-y m)
                  (+ (invader-y (first loi))
                     (/ (image-height INVADER) 2))))
         true]
        [else
         (collide-missiles? m (rest loi))]))


;; Missile -> Missile
;; interp. moves ONE missile upwards onscreen by MISSILE-SPEED after every tick

(check-expect (advance-missile M1)
              (make-missile (missile-x M1)
                            (+ (missile-y M1)
                               MISSILE-SPEED)))

(check-expect (advance-missile M2)
              (make-missile (missile-x M2)
                            (+ (missile-y M2)
                               MISSILE-SPEED)))

(define (advance-missile m)
  (make-missile (missile-x m)
                (+ (missile-y m)
                   MISSILE-SPEED)))


;; Tank -> Tank
;; interp. moves a given tank horizontally by tank-dir pixels every tick

(check-expect (advance-tank T0)
              (make-tank (+ (tank-x T0)
                            (tank-dir T0))
                         (tank-dir T0)))

(check-expect (advance-tank T1)
              (make-tank (+ (tank-x T1)
                            (tank-dir T1))

                         
                         (tank-dir T1)))

; edge case 1: tank hits the left side of the screen. it should should stop moving
; and remain within the frame
(check-expect (advance-tank (make-tank 15 -5))
              (make-tank 15 -5))

; edge case 2: tank hits the right side of the screen. it should should stop moving
; and remain within the frame
(check-expect (advance-tank (make-tank (- WIDTH 15) 5))
              (make-tank (- WIDTH 15) 5))

(define (advance-tank t)
  (if (or (and (<= (tank-x t) 15)
               (< (tank-dir t) 0))
          (and (>= (tank-x t) (- WIDTH 15))
               (> (tank-dir t) 0)))
      (make-tank (tank-x t)
                 (tank-dir t))
      (make-tank (+ (tank-x t)
                    (tank-dir t))
                 (tank-dir t))))


;; Game -> Image
;; interp. produces an image based on the existing state of a
;; given Game.

(check-expect (render-game G0)
              (render-tank (game-tank G0) MTS))

(check-expect (render-game G3)
              (render-invaders (game-invaders G3)
                               (render-missiles (game-missiles G3)
                                                 (render-tank (game-tank G1)
                                                              MTS))))

(define (render-game g)
  (render-invaders (game-invaders g)
                   (render-missiles (game-missiles g)
                                    (render-tank (game-tank g)
                                                 MTS))))
                            

;; ListOfInvaders Image -> Image
;; interp. produces an image of the invaders present in the current state of the game


(check-expect (render-invaders empty MTS)
              MTS)

(check-expect (render-invaders (list I1 I2) MTS)
              (render-invader I1 (render-invader I2 MTS)))

(define (render-invaders loi img)
  (cond [(empty? loi) img]
        [else
         (render-invader (first loi)
                         (render-invaders (rest loi) img))]))


;; Invader Image -> Image
;; interp. produces an image of an Invader based on the Invader's data

(check-expect (render-invader I1 MTS)
              (place-image INVADER
                           (invader-x I1)
                           (invader-y I1)
                           MTS))

(define (render-invader i img)
  (place-image INVADER
               (invader-x i)
               (invader-y i)
               img))


;; ListOfMissiles Image -> Image
;; interp. produces an image of the missiles present in the current state of the game

(check-expect (render-missiles LOM1 MTS)
              MTS)

(check-expect (render-missiles LOM2 MTS)
              (render-missile M1 MTS))

(check-expect (render-missiles LOM3 MTS)
              (render-missile M2
                              (render-missile M1 MTS)))

(define (render-missiles lom img)
  (cond [(empty? lom) img]
        [else
         (render-missile (first lom)
                         (render-missiles (rest lom) img))]))


;; Missile Image -> Image
;; interp. produces an image of an Missile based on the Missile's data

(check-expect (render-missile M1 MTS)
              (place-image MISSILE
                           (missile-x M1)
                           (missile-y M1)
                           MTS))

(check-expect (render-missile M2 MTS)
              (place-image MISSILE
                           (missile-x M2)
                           (missile-y M2)
                           MTS))

(define (render-missile m img)
  (place-image MISSILE
               (missile-x m)
               (missile-y m)
               img))


;; Tank Image -> Image
;; interp. produces an image of the tank based on its position in the current state of the game

(check-expect (render-tank T1 MTS)
              (place-image TANK
                           (tank-x T1)
                           TANK-OFFSET
                           MTS))

(check-expect (render-tank T2 MTS)
              (place-image TANK
                           (tank-x T2)
                           TANK-OFFSET
                           MTS))

(define (render-tank t img)
  (place-image TANK
               (tank-x t)
               TANK-OFFSET
               img))


;; Game KeyEvent -> Game
;; interp. changes the state of specific assets when specific keys are pressed
;; helper function 1:
;; - produces missile when spacebar is pressed
;; helper function 2:
;; - changes the direction of the tank when arrow keys are pressed

(check-expect (shoot-or-scoot G0 " ")
              (make-game (game-invaders G0)
                         (cons (make-missile (tank-x (game-tank G0))
                                             (- TANK-OFFSET MISSILE-OFFSET))
                               (game-missiles G0))
                         (game-tank G0)))

(check-expect (shoot-or-scoot G0 "a")
              (make-game (game-invaders G0)
                         (game-missiles G0)
                         (game-tank G0)))

(check-expect (shoot-or-scoot G1 "left") ; moving right
              (make-game (game-invaders G1)
                         (game-missiles G1)
                         (change-tank-dir (game-tank G1))))

(check-expect (shoot-or-scoot G1 "right") ; moving right
              (make-game (game-invaders G1)
                         (game-missiles G1)
                         (game-tank G1)))

(check-expect (shoot-or-scoot G2 "left") ; moving left
              (make-game (game-invaders G2)
                         (game-missiles G2)
                         (game-tank G2)))

(check-expect (shoot-or-scoot G2 "right") ; moving left
              (make-game (game-invaders G2)
                         (game-missiles G2)
                         (change-tank-dir (game-tank G2))))

(define (shoot-or-scoot g ke)
  (cond [(key=? " " ke) ; shoot
         (make-game (game-invaders g)
                    (cons (make-missile (tank-x (game-tank g))
                                        (- TANK-OFFSET MISSILE-OFFSET))
                          (game-missiles g))
                    (game-tank g))]
        [(or ; scoot
          (and (key=? "left" ke)
               (> (tank-dir (game-tank g)) 0))
          (and (key=? "right" ke)
               (< (tank-dir (game-tank g)) 0)))
         (make-game (game-invaders g)
                    (game-missiles g)
                    (change-tank-dir (game-tank g)))]
        [else
         (make-game (game-invaders g)
                    (game-missiles g)
                    (game-tank g))]))


;; Tank -> Tank
;; interp. changes the direction of the tank

(check-expect (change-tank-dir T1)
              (make-tank 50 -1))

(check-expect (change-tank-dir T2)
              (make-tank 50 1))

(check-expect (change-tank-dir (make-tank 50 0))
              (make-tank 50 0))

(define (change-tank-dir t)
  (make-tank (tank-x t)
             (- (tank-dir t))))


;; ======================
;; MAIN PROGRAM EXECUTION
;; ======================

(main (make-game empty
                 empty
                 (make-tank (/ WIDTH 2) TANK-SPEED)))
