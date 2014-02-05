|# We are going to change the rules of twenty-one by adding two jokers to the deck.
A joker can be worth any number of points from 1 to 11. Modify whatever has to be
modified to make this work. (The main point of this exercise is precisely for you
to figure out which procedures must be modified.) You will submit both joker.scm
and twenty-one.scm for grading. Don't worry about making strategies optimal; just
be sure nothing blows up and the hands are totalled correctly. #|

(define (best-total hand)
  (define (sum-but-magic se)
    (define (change-first se)
      (cond ((equal? 'a (bl (first se))) 0)
	    ((member? (bl (first se)) '(j q k)) 10)
	    ((equal? 'joker (bl (first se))) 0)
	    (else (bl (first se)))))
    (if (empty? se)
	0
	(+ (change-first se) (sum-but-magic (bf se)))))
  (define (num-of-a se)
    (define (if-a se)
      (if (equal? (bl (first se)) 'a)
	  1
	  0))
    (if (empty? se)
	0
	(+ (if-a se) (num-of-a (bf se)))))
  (define (num-of-joker se)
    (define (if-joker se)
      (if (equal? (bl (first se)) 'joker)
	  1
	  0))
    (if (empty? se)
	0
	(+ (if-joker se) (num-of-joker (bf se)))))
  (define (no-joker hand)
    (cond ((= (num-of-a hand) 0) (sum-but-magic hand))
	  ((> (sum-but-magic hand) 10) (+ (sum-but-magic hand) (num-of-a hand)))
	  ((<= (sum-but-magic hand) 7) (+ (sum-but-magic hand) 11 (- (num-of-a hand) 1)))
	  ((and (= (sum-but-magic hand) 8) (<= (num-of-a hand) 3)) (+ (sum-but-magic hand) 11 (- (num-of-a hand) 1)))
	  ((and (= (sum-but-magic hand) 9) (<= (num-of-a hand) 2)) (+ (sum-but-magic hand) 11 (- (num-of-a hand) 1)))
	  ((and (= (sum-but-magic hand) 10) (= (num-of-a hand) 1)) 21)
	  (else (+ (sum-but-magic hand) (num-of-a hand)))))
  (define (joker-no-ace hand)
    (cond ((and (= (num-of-joker hand) 1) (< (sum-but-magic hand) 10)) (+ (sum-but-magic hand) 11))
	  ((and (= (num-of-joker hand) 1) (< (sum-but-magic hand) 20)) 21)
	  ((and (= (num-of-joker hand) 1) (>= (sum-but-magic hand) 20)) (+ (sum-but-magic hand) 1))
	  ((and (= (num-of-joker hand) 2) (<= (sum-but-magic hand) 19)) 21)
	  (else (+ (sum-but-magic hand) 2))))
  (define (joker-and-ace hand)
    (if (< (- 21 (sum-but-magic hand)) (+ (num-of-a hand) (num-of-joker hand)))
	(+ (+ (num-of-a hand) (num-of-joker hand)) (sum-but-magic hand))
	21))
  (cond ((= (num-of-joker hand) 0) (no-joker hand))
	((= (num-of-a hand) 0) (joker-no-ace hand))
	(else (joker-and-ace hand))))
(define (stop-at-17 customer-hand-so-far dealer-up-card)
  (< (best-total customer-hand-so-far) 17))
(define (stop-at n) (lambda (customer-hand-so-far dealer-up-card)
		      (< (best-total customer-hand-so-far) n)))
(define (dealer-sensitive customer-hand-so-far dealer-up-card)
  (or (and (member? (bl dealer-up-card) '(a 7 8 9 10 j q k))
	   (< (best-total customer-hand-so-far) 17))
      (and (member? (bl dealer-up-card) '(2 3 4 5 6))
	   (< (best-total customer-hand-so-far) 12))))
(define (suit-list sent)
  (if (empty? sent)
      sent
      (se (last (first sent)) (suit-list (bf sent)))))
(define (valentine customer-hand-so-far dealer-up-card)
  (if (member? 'h (suit-list customer-hand-so-far))
      (stop-at 19)
      stop-at-17))
(define (suit-strategy suit stra1 stra2)
  (lambda (customer-hand-so-far dealer-up-card)
    (if (member? suit (suit-list customer-hand-so-far))
	stra2
	stra1)))
(define re-valentine
  (suit-strategy 'h stop-at-17 (stop-at 19)))
(define (play-n strategy n)
  (if (= n 0)
      0
      (+ (twenty-one strategy) (play-n strategy (- n 1)))))
(define (majority stra1 stra2 stra3)
  (lambda (customer-hand-so-far dealer-up-card)
    (or (and (stra1 customer-hand-so-far dealer-up-card) (stra2 customer-hand-so-far dealer-up-card))
	(and (stra1 customer-hand-so-far dealer-up-card) (stra3 customer-hand-so-far dealer-up-card))
	(and (stra2 customer-hand-so-far dealer-up-card) (stra3 customer-hand-so-far dealer-up-card)))))
(define (reckless strategy) (lambda (customer-hand-so-far dealer-up-card)
			      (strategy (bl customer-hand-so-far) dealer-up-card)))
(define (twenty-one strategy)
  (define (play-dealer customer-hand dealer-hand-so-far rest-of-deck)
    (cond ((> (best-total dealer-hand-so-far) 21) 1)
	  ((< (best-total dealer-hand-so-far) 17)
	   (play-dealer customer-hand
			(se dealer-hand-so-far (first rest-of-deck))
			(bf rest-of-deck)))
	  ((< (best-total customer-hand) (best-total dealer-hand-so-far)) -1)
	  ((= (best-total customer-hand) (best-total dealer-hand-so-far)) 0)
	  (else 1)))

  (define (play-customer customer-hand-so-far dealer-up-card rest-of-deck)
    (cond ((> (best-total customer-hand-so-far) 21) -1)
	  ((strategy customer-hand-so-far dealer-up-card)
	   (play-customer (se customer-hand-so-far (first rest-of-deck))
			  dealer-up-card
			  (bf rest-of-deck)))
	  (else
	   (play-dealer customer-hand-so-far
			(se dealer-up-card (first rest-of-deck))
			(bf rest-of-deck)))))

  (let ((deck (make-deck)))
    (play-customer (se (first deck) (first (bf deck)))
		   (first (bf (bf deck)))
		   (bf (bf (bf deck))))) )

(define (make-ordered-deck)
  (define (make-suit s)
    (every (lambda (rank) (word rank s)) '(A 2 3 4 5 6 7 8 9 10 J Q K)) )
  (se (se (make-suit 'H) (make-suit 'S) (make-suit 'D) (make-suit 'C)) 'joker1 'joker2))

(define (make-deck)
  (define (shuffle deck size)
    (define (move-card in out which)
      (if (= which 0)
	  (se (first in) (shuffle (se (bf in) out) (- size 1)))
	  (move-card (bf in) (se (first in) out) (- which 1)) ))
    (if (= size 0)
	deck
    	(move-card deck '() (random size)) ))
  (shuffle (make-ordered-deck) 54) )
