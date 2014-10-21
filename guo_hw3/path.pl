arc(m,p,8).
arc(q,p,11).
arc(q,m,5).
arc(k,q,3).

% degenerate case
route(A,B,Visited,Path,L) :-
       arc(A,B,L),
	   append(Visited, [A, B], Path).

% general case
route(A,B,Visited,Path,L) :-
       arc(A,C,Dist),
       C \== B,
       \+member(C,Visited),
	   append(Visited, [A], NewVisited),
       route(C,B,NewVisited,Path,Lp),
       L is Dist+Lp.

% from a set of paths, find the shortest one
shortest([Head|Tail],M) :- shortestRoute(Tail,Head,M).
shortestRoute([],M,M).
shortestRoute([Head|Tail], CurMin, Min) :- 
		Head = [_|L], 
		CurMin = [_|Lmin], 
		L < Lmin, !, shortestRoute(Tail, Head, Min).
shortestRoute([_|Tail],CurMin,Min) :- shortestRoute(Tail,CurMin,Min).

% driver rule
path(A,B,Path) :-
   setof([Path, Len],route(A,B,[],Path,Len), PathSet),	% the set of all paths
   PathSet \== [], % the set of path must not be empty
   shortest(PathSet,[Path, Len]).