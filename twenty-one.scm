|# For our purposes, the rules of twenty-one ("blackjack") are as follows. There are two players: the "customer"
and the "dealer". The object of the game is to be dealt a set of cards that comes as close to 21 as possible
without going over 21 ("busting"). Each player is dealt two cards, and one of the dealer's cards is left face up.
First, the customer has to decide whether to take another card ("hit") or finish playing ("stand"). The customer
keeps taking cards until s/he decides to stand. Then the dealer takes over. In our simulation, the dealer always 
hits if his total is 16 or less, and stands with 17 or more. Once the dealer stands, the player with the higher
total wins. If either player's total goes over 21, that player automatically loses. (Note that if the customer's
total goes over 21, the dealer doesn't play at all.)

A card is represented as a word, such as 10s for the ten of spades. (Ace, jack, queen, and king are a, j, q, and k.)
The picture cards (jack, queen, and king) are each worth 10 points; an ace is worth either 1 or 11 at the player's
option. We reshuffle the deck after each game, so strategies based on remembering which cards were dealt earlier 
are not possible.

The customer's strategy of when to take another card is represented as a procedure. The procedure takes two arguments:

The customer's hand so far, represented as a sentence in which each word is a card
The dealer's card that is face up, represented as a single word (not a sentence)
The strategy procedure should return a true or false output indicating whether or not the customer wants another card.#|

|# The program in twenty-one.scm is incomplete. It lacks a procedure best-total that takes a hand (a sentence of card
words) as argument, and returns the total number of points in the hand. It's called best-total because if a hand
contains aces, it may have several different totals. The procedure should return the largest possible total that's
less than or equal to 21.#|

(define (best-total hand)
  (define (sum-but-a se)
    (define (change-first se)
      (cond ((equal? 'a (bl (first se))) 0)
	    ((member? (bl (first se)) '(j q k)) 10)
	    (else (bl (first se)))))
    (if (empty? se)
	0
	(+ (change-first se) (sum-but-a (bf se)))))
  (define (num-of-a se)
    (define (if-a se)
      (if (equal? (bl (first se)) 'a)
	  1
	  0))
    (if (empty? se)
	0
	(+ (if-a se) (num-of-a (bf se)))))
  (cond ((= (num-of-a hand) 0) (sum-but-a hand))
	((> (sum-but-a hand) 10) (+ (sum-but-a hand) (num-of-a hand)))
	((<= (sum-but-a hand) 7) (+ (sum-but-a hand) 11 (- (num-of-a hand) 1)))
	((and (= (sum-but-a hand) 8) (<= (num-of-a hand) 3)) (+ (sum-but-a hand) 11 (- (num-of-a hand) 1)))
	((and (= (sum-but-a hand) 9) (<= (num-of-a hand) 2)) (+ (sum-but-a hand) 11 (- (num-of-a hand) 1)))
	((and (= (sum-but-a hand) 10) (= (num-of-a hand) 1)) 21)
	(else (+ (sum-but-a hand) (num-of-a hand)))))
	
	|# Time to define your first strategy procedure, stop-at-17. This will be just like the dealer's strategy:
	take another card if and only if your current total is strictly less than 17.#|
	
(define (stop-at-17 customer-hand-so-far dealer-up-card)
  (< (best-total customer-hand-so-far) 17))
  |# Generalize the idea behind stop-at-17 by writing a higher-order procedure called stop-at.
  (stop-at n) should return a strategy that keeps hitting until the customer's total is at least n.#|
  
(define (stop-at n) (lambda (customer-hand-so-far dealer-up-card)
		      (< (best-total customer-hand-so-far) n)))
		      
|# Define a strategy named dealer-sensitive that hits (takes a card) if and only if

the dealer has an ace, 7, 8, 9, 10, or picture card showing, and the customer's total is less than 17
or

the dealer has a 2, 3, 4, 5, or 6 showing, and the customer's total is less than 12.
The idea is that in the second case, the dealer is much
more likely to "bust" (go over 21), since there are more 10-point cards than anything else. #|

(define (dealer-sensitive customer-hand-so-far dealer-up-card)
  (or (and (member? (bl dealer-up-card) '(a 7 8 9 10 j q k))
	   (< (best-total customer-hand-so-far) 17))
      (and (member? (bl dealer-up-card) '(2 3 4 5 6))
	   (< (best-total customer-hand-so-far) 12))))
(define (suit-list sent)
  (if (empty? sent)
      sent
      (se (last (first sent)) (suit-list (bf sent)))))
|# On Valentine's Day, your local casino has a special deal: If you win a round of twenty-one
with a heart in your hand, they pay double. You decide that if you have a heart in your hand,
you should play more aggressively than usual. Write a valentine strategy that stops at 17 unless
you have a heart in your hand, in which case it stops at 19.#|

(define (valentine customer-hand-so-far dealer-up-card)
  (if (member? 'h (suit-list customer-hand-so-far))
      ((stop-at 19) customer-hand-so-far dealer-up-card)
      (stop-at-17 customer-hand-so-far dealer-up-card)))

|# Generalize the previous problem by defining a procedure suit-strategy that takes three arguments:

A suit (h, s, d, or c)
A strategy to be used if your hand doesn't include that suit
A strategy to be used if your hand does include that suit
It should return a strategy that behaves accordingly. Show how you could use this procedure
and the stop-at procedure to redefine the valentine strategy from the previous problem. #|

(define (suit-strategy suit stra1 stra2)
  (lambda (customer-hand-so-far dealer-up-card)
    (if (member? suit (suit-list customer-hand-so-far))
	(stra2 customer-hand-so-far dealer-up-card)
	(stra1 customer-hand-so-far dealer-up-card))))
(define re-valentine
  (suit-strategy 'h stop-at-17 (stop-at 19)))
  
  |# Write a procedure play-n such that (play-n strategy n) plays
  n games with a given strategy and returns the number of games
  that the customer won minus the number that s/he lost.#|
  
(define (play-n strategy n)
  (if (= n 0)
      0
      (+ (twenty-one strategy) (play-n strategy (- n 1)))))
      
|# Define a procedure majority that takes three strategies as arguments and returns a new strategy as
a result. The result strategy should decide whether or not to hit by consulting the three argument 
strategies and going with the majority. That is, the result strategy should return #t if and only 
if at least two of the three argument strategies do. #|

(define (majority stra1 stra2 stra3)
  (lambda (customer-hand-so-far dealer-up-card)
    (or (and (stra1 customer-hand-so-far dealer-up-card) (stra2 customer-hand-so-far dealer-up-card))
	(and (stra1 customer-hand-so-far dealer-up-card) (stra3 customer-hand-so-far dealer-up-card))
	(and (stra2 customer-hand-so-far dealer-up-card) (stra3 customer-hand-so-far dealer-up-card)))))

|# Some people just can't resist taking one more card. Write a procedure reckless that takes a strategy
as its argument and returns another strategy. This new strategy should take one more card than the original would. #|

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
  (se (make-suit 'H) (make-suit 'S) (make-suit 'D) (make-suit 'C)) )

(define (make-deck)
  (define (shuffle deck size)
    (define (move-card in out which)
      (if (= which 0)
	  (se (first in) (shuffle (se (bf in) out) (- size 1)))
	  (move-card (bf in) (se (first in) out) (- which 1)) ))
    (if (= size 0)
	deck
    	(move-card deck '() (random size)) ))
  (shuffle (make-ordered-deck) 52) )
