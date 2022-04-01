;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders-starter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders

;; ==========
;; Constants:
;; ==========

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED -0.01)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED -0.01)
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


;; =================
;; Data Definitions:
;; =================

(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below ListOfMissile data definition

#;
(define (fn-for-game s)
  (... (fn-for-loi (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))))



(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t)
       (tank-dir t)))



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


#;
(define (fn-for-invader i)
  (... (invader-x i)
       (invader-y i)
       (invader-dx i)))


;; ListOfInvader is one of:
;; - empty
;; - (cons Invader ListofInvader)
;; interp. a list of Invaders present in the current state of the game

(define LOI1 empty)
(define LOI2 (list I1))
(define LOI3 (list I2 I1))

#;
(define (fn-for-loi loi)
  (cond [(empty? loi) false]
        [else
         (... (first loi)
              (fn-for-loi (rest loi)))]))


(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))    ;not hit U1
(define M2 (make-missile 150 (+ (invader-y I1) 10))) ; exactly hit U1
(define M3 (make-missile 150 (+ (invader-y I1) 5)))  ; overhit U1
(define COLLIDE_MISSILE (make-missile 200 50))


#;
(define (fn-for-missile m)
  (... (missile-x m)
       (missile-y m)))


;; ListOfMissile is one of:
;; - empty
;; - (cons Missile ListOfMissile)
;; interp. a list of Missiles present in the current state of the game

(define LOM1 empty)
(define LOM2 (list M1))
(define LOM3 (list M2 M1))

#;
(define (fn-for-lom lom)
  (cond [(empty? lom) false]
        [else
         (... (first lom)
              (fn-for-lom (rest lom)))]))


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
;; !!! add function to eliminate colliding missiles and invaders

; (define (advance-game g) G0) ; stub

(check-expect (advance-game G0)
              (make-game empty
                         empty
                         (advance-tank (game-tank G0)))) ; (game-tank G0) -> T0 -> (make-tank (/ WIDTH 2) 1)

;; (define G3 (make-game (list I1 I2) (list M1 M2) T1))
(check-expect (advance-game G3)
              (make-game (advance-loi (game-invaders G3))
                         (advance-lom (game-missiles G3))
                         (advance-tank (game-tank G3))))

;; edge case 1: an invader reaches the bottom of the screen. game must end
(check-expect (advance-game END_GAME)
              (make-game (game-invaders END_GAME)
                         (game-missiles END_GAME)
                         (game-tank END_GAME)))

#;
(define (fn-for-game s)
  (... (fn-for-loi (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))))

(define (advance-game g)
  (cond [(invader-win? (game-invaders g))
          (make-game (game-invaders g)
                     (game-missiles g)
                     (game-tank g))]
        [else
         (make-game (advance-loi (game-invaders g))
                    (advance-lom (game-missiles g))
                    (advance-tank (game-tank g)))]))


;; ListOfInvader -> Boolean
;; interp. returns true if an Invader in the ListOfInvader has reached the
;; bottom of the frame
;; !!!

;; (define (invader-win? LOI1) true) ; stub

(check-expect (invader-win? empty) false)
(check-expect (invader-win? (list END_INVADER)) true)
(check-expect (invader-win? (list I1)) false)
(check-expect (invader-win? (list I1 I6)) false)
(check-expect (invader-win? (list I1 I6 END_INVADER)) true)

#;
(define (fn-for-loi loi)
  (cond [(empty? loi) false]
        [else
         (... (first loi)
              (fn-for-loi (rest loi)))]))

(define (invader-win? loi)
  (cond [(empty? loi) false]
        [(>= (invader-y (first loi))
                 TANK-OFFSET) true]
        [else
         (invader-win? (rest loi))]))


;; ListOfInvader -> ListOfInvader
;; interp. moves a list of invaders 45 degrees downwards at invader-dx speed

;; (define (advance-loi loi) empty) ; stub

(check-expect (advance-loi empty) empty)

(check-expect (advance-loi (list I1))
              (list (advance-invader I1)))

(check-expect (advance-loi (list I2 I1))
              (list (advance-invader I2)
                    (advance-invader I1)))

#;
(define (fn-for-loi loi)
  (cond [(empty? loi) false]
        [else
         (... (first loi)
              (fn-for-loi (rest loi)))]))

(define (advance-loi loi)
  (cond [(empty? loi) empty]
        [else
         (cons (advance-invader (first loi))
               (advance-loi (rest loi)))]))


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

#;
(define (fn-for-invader invader)
  (... (invader-x invader)
       (invader-y invader)
       (invader-dx invader)))


(define (advance-invader i)
  (cond [(or (and (= (invader-x i) 0)
                  (< (invader-dx i) 0))        ; invader hits left side of screen
             (and (= (invader-x i) WIDTH)
                  (> (invader-dx i) 0)))       ; invader hits right side of screen
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


;; ListOfMissiles -> ListOfMissiles
;; interp. moves a list of missiles upwards onscreen by MISSILE-SPEED after every tick

;; (define (advance-lom lom) empty) ; stub

(check-expect (advance-lom (list M1))
              (list (advance-missile M1)))

(check-expect (advance-lom (list M2 M1))
              (list (advance-missile M2)
                    (advance-missile M1)))

#;
(define (fn-for-lom lom)
  (cond [(empty? lom) false]
        [else
         (... (first lom)
              (fn-for-lom (rest lom)))]))

(define (advance-lom lom)
  (cond [(empty? lom) empty]
        [else
         (cons (advance-missile (first lom))
               (advance-lom (rest lom)))]))
  


;; Missile -> Missile
;; interp. moves ONE missile upwards onscreen by MISSILE-SPEED after every tick

; (define (advance-missile missile) M1) ; stub

(check-expect (advance-missile M1)
              (make-missile (missile-x M1)
                            (+ (missile-y M1)
                               MISSILE-SPEED)))

(check-expect (advance-missile M2)
              (make-missile (missile-x M2)
                            (+ (missile-y M2)
                               MISSILE-SPEED)))

#;
(define (fn-for-missile m)
  (... (missile-x m)
       (missile-y m)))

(define (advance-missile m)
  (make-missile (missile-x m)
                (+ (missile-y m)
                   MISSILE-SPEED)))


;; Tank -> Tank
;; interp. moves a given tank horizontally by tank-dir pixels every tick

;; (define (advance-tank tank) T0) ; stub

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


#;
(define (fn-for-tank t)
  (... (tank-x t)
       (tank-dir t)))

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

;; (define (render-game G0) BLANK) ; stub

(check-expect (render-game G0)
              (render-tank (game-tank G0) MTS))

(check-expect (render-game G3)
              (render-invaders (game-invaders G3)
                               (render-missiles (game-missiles G3)
                                                 (render-tank (game-tank G1)
                                                              MTS))))

#;
(define (fn-for-game s)
  (... (fn-for-loi (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))))

(define (render-game g)
  (render-invaders (game-invaders g)
                   (render-missiles (game-missiles g)
                                    (render-tank (game-tank g)
                                                 MTS))))
                            

;; ListOfInvaders Image -> Image
;; interp. produces an image of the invaders present in the current state of the game

;; (define (render-invaders LOI1 BLANK) BLANK) ; stub

(check-expect (render-invaders empty MTS)
              MTS)

(check-expect (render-invaders (list I1 I2) MTS)
              (render-invader I1 (render-invader I2 MTS)))

#;
(define (fn-for-loi loi)
  (cond [(empty? loi) false]
        [else
         (... (first loi)
              (fn-for-loi (rest loi)))]))

(define (render-invaders loi img)
  (cond [(empty? loi) img]
        [else
         (render-invader (first loi)
                         (render-invaders (rest loi) img))]))


;; Invader Image -> Image
;; interp. produces an image of an Invader based on the Invader's data

;; (define (render-invader I1 MTS) MTS) ; stub

(check-expect (render-invader I1 MTS)
              (place-image INVADER
                           (invader-x I1)
                           (invader-y I1)
                           MTS))

#;
(define (fn-for-invader i)
  (... (invader-x i)
       (invader-y i)
       (invader-dx i)))

(define (render-invader i img)
  (place-image INVADER
               (invader-x i)
               (invader-y i)
               img))


;; ListOfMissiles Image -> Image
;; interp. produces an image of the missiles present in the current state of the game

;; (define (render-missiles LOM1 BLANK) BLANK) ; stub

(check-expect (render-missiles LOM1 MTS)
              MTS)

(check-expect (render-missiles LOM2 MTS)
              (render-missile M1 MTS))

(check-expect (render-missiles LOM3 MTS)
              (render-missile M2
                              (render-missile M1 MTS)))

#;
(define (fn-for-lom lom)
  (cond [(empty? lom) false]
        [else
         (... (first lom)
              (fn-for-lom (rest lom)))]))


(define (render-missiles lom img)
  (cond [(empty? lom) img]
        [else
         (render-missile (first lom)
                         (render-missiles (rest lom) img))]))


;; Missile Image -> Image
;; interp. produces an image of an Missile based on the Missile's data

;; (define (render-missile M1 MTS) MTS) ; stub

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

#;
(define (fn-for-missile m)
  (... (missile-x m)
       (missile-y m)))

(define (render-missile m img)
  (place-image MISSILE
               (missile-x m)
               (missile-y m)
               img))


;; Tank Image -> Image
;; interp. produces an image of the tank based on its position in the current state of the game

;; (define (render-tank T0 MTS) MTS) ; stub

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

#;
(define (fn-for-tank t)
  (... (tank-x t)
       (tank-dir t)))

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

;; (define (shoot-or-scoot G0 ke) G0) ; stub

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

#;
(define (fn-for-key-event kevt)
  (cond [(key=? " " kevt) (...)]
        [else
         (...)]))

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

;; (define (change-tank-dir T0) T0) ; stub

(check-expect (change-tank-dir T1)
              (make-tank 50 -1))

(check-expect (change-tank-dir T2)
              (make-tank 50 1))

(check-expect (change-tank-dir (make-tank 50 0))
              (make-tank 50 0))

#;
(define (fn-for-tank t)
  (... (tank-x t)
       (tank-dir t)))


(define (change-tank-dir t)
  (make-tank (tank-x t)
             (- (tank-dir t))))


;; ======================
;; MAIN PROGRAM EXECUTION
;; ======================

(main (make-game (list I1 I6)
                 (list M1 M2)
                 (make-tank (/ WIDTH 2) TANK-SPEED)))