

process([], []).
process([X], [[1, X]]).
process([1 | T], [[1, 1], [X, 0] | TAIL]):- process(T, [[X, 0] | TAIL]), !.
process([1 | T], [[NUMCOUNT, 1] | TAIL]):- process(T, [[C, 1] | TAIL]), succ(C, NUMCOUNT), !.
process([0 | T], [[1, 0], [X, 1] | TAIL]):- process(T, [[X, 1] | TAIL]), !.
process([0 | T], [[NUMCOUNT, 0] | TAIL]):- process(T, [[C, 0] | TAIL]), succ(C, NUMCOUNT), !.

pattern_check([], []).
pattern_check([[1, 1] | T], ['.' | Y]):- pattern_check(T, Y).
pattern_check([[2, 1] | T], ['.' | Y]):- pattern_check(T, Y).
pattern_check([[2, 1] | T], ['-' | Y]):- pattern_check(T, Y).
pattern_check([[H, 1] | T], ['-' | Y]):- H >= 3, pattern_check(T, Y).
pattern_check([[1, 0] | T], Y):- pattern_check(T, Y).
pattern_check([[2, 0] | T], Y):- pattern_check(T, Y).
pattern_check([[2, 0] | T], ['^' | Y]):- pattern_check(T, Y).
pattern_check([[3, 0] | T], ['^' | Y]):- pattern_check(T, Y).
pattern_check([[4, 0] | T], ['^' | Y]):- pattern_check(T, Y).
pattern_check([[5, 0] | T], ['^' | Y]):- pattern_check(T, Y).
pattern_check([[5, 0] | T], ['#' | Y]):- pattern_check(T, Y).
pattern_check([[H, 0] | T], ['#' | Y]):- H >= 5, pattern_check(T, Y).



% x is stream of 0, 1. Z is list of list, [NumberOf0or1, 0 or 1]
% 1, 0 -> [[1, 1], [1, 0]]
% 1,1,1,0,1,1,1,0,0,0,1,1,1  -> [[3, 1], [1, 1], [3, 0], [3, 0], [3, 0]]

signal_morse([], []).
signal_morse(X, M):- process(X, Z), pattern_check(Z, M).



morse(a, [.,-]).           % A
morse(b, [-,.,.,.]).	   % B
morse(c, [-,.,-,.]).	   % C
morse(d, [-,.,.]).	   % D
morse(e, [.]).		   % E
morse('e''', [.,.,-,.,.]). % É (accented E)
morse(f, [.,.,-,.]).	   % F
morse(g, [-,-,.]).	   % G
morse(h, [.,.,.,.]).	   % H
morse(i, [.,.]).	   % I
morse(j, [.,-,-,-]).	   % J
morse(k, [-,.,-]).	   % K or invitation to transmit
morse(l, [.,-,.,.]).	   % L
morse(m, [-,-]).	   % M
morse(n, [-,.]).	   % N
morse(o, [-,-,-]).	   % O
morse(p, [.,-,-,.]).	   % P
morse(q, [-,-,.,-]).	   % Q
morse(r, [.,-,.]).	   % R
morse(s, [.,.,.]).	   % S
morse(t, [-]).	 	   % T
morse(u, [.,.,-]).	   % U
morse(v, [.,.,.,-]).	   % V
morse(w, [.,-,-]).	   % W
morse(x, [-,.,.,-]).	   % X or multiplication sign
morse(y, [-,.,-,-]).	   % Y
morse(z, [-,-,.,.]).	   % Z
morse(0, [-,-,-,-,-]).	   % 0
morse(1, [.,-,-,-,-]).	   % 1
morse(2, [.,.,-,-,-]).	   % 2
morse(3, [.,.,.,-,-]).	   % 3
morse(4, [.,.,.,.,-]).	   % 4
morse(5, [.,.,.,.,.]).	   % 5
morse(6, [-,.,.,.,.]).	   % 6
morse(7, [-,-,.,.,.]).	   % 7
morse(8, [-,-,-,.,.]).	   % 8
morse(9, [-,-,-,-,.]).	   % 9
morse(., [.,-,.,-,.,-]).   % . (period)
morse(',', [-,-,.,.,-,-]). % , (comma)
morse(:, [-,-,-,.,.,.]).   % : (colon or division sign)
morse(?, [.,.,-,-,.,.]).   % ? (question mark)
morse('''',[.,-,-,-,-,.]). % ' (apostrophe)
morse(-, [-,.,.,.,.,-]).   % - (hyphen or dash or subtraction sign)
morse(/, [-,.,.,-,.]).     % / (fraction bar or division sign)
morse('(', [-,.,-,-,.]).   % ( (left-hand bracket or parenthesis)
morse(')', [-,.,-,-,.,-]). % ) (right-hand bracket or parenthesis)
morse('"', [.,-,.,.,-,.]). % " (inverted commas or quotation marks)
morse(=, [-,.,.,.,-]).     % = (double hyphen)
morse(+, [.,-,.,-,.]).     % + (cross or addition sign)
morse(@, [.,-,-,.,-,.]).   % @ (commercial at)

% Error.
morse(error, [.,.,.,.,.,.,.,.]). % error - see below

% Prosigns.
morse(as, [.,-,.,.,.]).          % AS (wait A Second)
morse(ct, [-,.,-,.,-]).          % CT (starting signal, Copy This)
morse(sk, [.,.,.,-,.,-]).        % SK (end of work, Silent Key)
morse(sn, [.,.,.,-,.]).          % SN (understood, Sho' 'Nuff)

% turn list of morse chars to a list of lists
% which is a group of -s, .s that make up a word
% [-,-,^,-,-,-,#,-,-,-,^,-,.] -> [[-,-], [-,-,-], [#], [-,-,-], [-,.]]
% [-,-] -> [[-,-]] 

signal_process([], [[]]).
signal_process(['^' | T], [[] | TAIL]):- signal_process(T, TAIL), !.
signal_process(['#' | T], [[], ['#'] | TAIL]):- signal_process(T, TAIL), !.
signal_process([H | T], [[H | REST] | TAIL]):- signal_process(T, [REST | TAIL]), !.

decode([], [[]]).
decode([['#'], []], [[1, '#']]).
decode([['#'] | T], [[], [1, '#'], R | TAIL]):- decode(T, [R | TAIL]),  R \= [], !.
decode([['#'] | T], [[], [NUMCOUNT, '#'] | L]):- decode(T, [[], [C, '#'] | L]), succ(C, NUMCOUNT), !.
decode([H | T], [[HM | REST] | TM]):- morse(HM, H), decode(T, [REST | TM]), HM \= 'error', REST \= ['error'], REST \= [_, '#'], !.
decode([H | T], [[HM] | TM]):- morse(HM, H), decode(T, TM), !.

rm_err([], []).
rm_err([[] | T], TAIL):- rm_err(T, TAIL), !.
rm_err([['error'] | T], ['error' | TAIL]):- rm_err(T, TAIL), !.
rm_err([_, [_, '#'], ['error'] | T], TAIL):- rm_err(T, TAIL), !.
rm_err([_, ['error'] | T], TAIL):- rm_err(T, TAIL), !.
rm_err([[1, '#'] | T], ['#' | TAIL]):- rm_err(T, TAIL), !.
rm_err([[COUNT, '#'] | T], ['#' | TAIL]):- succ(C, COUNT), rm_err([[C, '#'] | T], TAIL), !.
rm_err([[X | REST] | T], [X | TAIL]):- rm_err([REST | T], TAIL), [X | REST] \= [_, '#'], !.


% need to make a list of letters.  each letter is its own list of -s and .s
% X is sequence of chars, M is list decoded message

signal_message([], []).
signal_message(X, M):- signal_morse(X, R), signal_process(R, Z), decode(Z, W), rm_err(W, M). 






