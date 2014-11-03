max_list([H|T], M) :- max_list(T, H, M).

max_list([], C, C).
max_list([H|T], C, M) :-
  C2 is max(C, H),
  max_list(T, C2, M).
