Projects
========

Project - Black Jack
Project 1 BlackJack Test
BEST-TOTAL
>(best-total '(7s 4d))
11
>(best-total '(7s 4d ad))
12
>(best-total '(3d 2s as))
16
>(best-total '(3h 5h ad as))
20
>(best-total '(2h 4d 3s as ah))
21
>(best-total '(qh as))
21
>(best-total '(js 2h as ad))
14
>(best-total '(js ks ah ad))
22

STOP-AT-17
Because the BEST-TOTAL procedure works fine, we only need to test the three different cases when
the best total is greater than, equal to, or less than 17. The procedure should return #f,#f,#t accordingly.
>(stop-at-17 '(qs ad 9h) '5h)
#f
>(stop-at-17 '(3s 4d kh) 'qh)
#f
>(stop-at-17 '(4s 2h) '10s)
#t
Test (twenty-one stop-at-17) returns -1, 0, or 1

PLAY-N
>(play-n stop-at-17 5)
1
>(play-n stop-at-17 17)
-1
>(play-n (stop-at 19) 3)
-1
>(play-n dealer-sensitive 4)
0

DEALER-SENSITIVE
if best-total is less than 12, dealer-sensitive returns true no matter what is the dealer-up-card.
if best-total is between 12 and 17, dealer-sensitive returns true only when a,7,8,9,10 or pic showing.
if best-total is greater than 17, dealer-sensitive returns false no matter which card is showing.
>(dealer-sensitive '(3d 5s) 'qh)
#t
>(dealer-sensitive '(4h 4d 3s) '2s)
#t
>(dealer-sensitive '(5h qd) '7h)
#t
>(dealer-sensitive '(3d 9h ad) '3s)
#f
>(dealer-sensitive '(kh 8s 5d) '9d)
#f

STOP-AT
>((stop-at 10) '(ah 3d 4s) 'as)
#f
>((stop-at 0) '(as 10h) '4d)
#f
>((stop-at 19) '(10s 5h) 'ah)
#t

VALENTINE
when best-total of customer-hand-so-far is less than 17, VALENTINE returns true no matter the
customer has a heart or not; when the total is between 17 and 19, a heart could make a difference;
when the total is more than 19, it always returns false.
>(valentine '(kc as 3s) '9d)
#t
>(valentine '(qs 3d 5c) 'ks)
#f
>(valentine '(5c 6h 7s) 'as)
#t
>(valentine '(kh ah 3h 10h) '9d)
#f

SUIT-STRATEGY
rewrite valentine as below:

(define re-valentine
  
(suit-strategy 'h stop-at-17 (stop-at 19)))

MAJORITY
>((majority stop-at-17 valentine dealer-sensitive) '(qs 3c 2h) 'ah)
#t
>((majority (stop-at 15) valentine dealer-sensitive) '(4h 8d ad 3s) '10c)
#t
>((majority valentine dealer-sensitive (stop-at 16)) '(5h 3h 2h 7h) '4s)
#f

RECKLESS
>((reckless stop-at-17) '(3h 4s 5c 6s) '5h)
#t
>((reckless dealer-sensitive) '(2c 3c 9h) '2s)
#t

JOKER
>(make-ordered-deck)
(ah 2h 3h 4h 5h 6h 7h 8h 9h 10h jh qh kh as 2s 3s 4s 5s 6s 7s 8s 9s 10s 
js qs ks ad 2d 3d 4d 5d 6d 7d 8d 9d 10d jd qd kd ac 2c 3c 4c 5c 6c 7c 8c 9c 10c jc qc kc joker1 joker2)
>(make-deck)
(10s qd 8s 3s ah 2s 10d 6d jd joker2 4s 3d 4d jh ad 8d ks 8h 9d jc 7c 7d 
2d 5h ac 5s qc 4h qh 6c 9s 5c 10c 7h 6s qs 9h 3c 10h joker1 js 5d 2h 6h 8c 3h kc as kh 4c kd 9c 7s 2c)

BEST-TOTAL
>(best-total '(3s 4d 8s))
15
>(best-total '(3h 4c 8s as))
16
>(best-total '(joker1 3c 5d))
19
>(best-total '(3c 6c joker2 5h))
21
>(best-total '(kc joker1 5s 7d))
23
>(best-total '(joker1 js 7h 2c as))
21
>(best-total '(6h 5d 3d joker2 2s ah ad))
21
>(best-total '(7c joker2 ad 4h 9h joker1 as))
24
