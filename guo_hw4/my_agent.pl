%my_agent.pl

:- use_module(library(lists)).
:- use_module(library(pairs)).


%   this procedure requires the external definition of two procedures:
%
%     init_agent: called after new world is initialized.  should perform
%                 any needed agent initialization.
%
%     run_agent(percept,action): given the current percept, this procedure
%                 should return an appropriate action, which is then
%                 executed.
%
% This is what should be fleshed out

init_agent:-
  format('\n=====================================================\n'),
  format('Initializing the agent...'),
  format('\n=====================================================\n'),
  retractall(agent_coords(_,_)),
  retractall(safe_coords(_)),
  retractall(agent_orient(_)),
  retractall(maybe_pit(_)),
  retractall(maybe_wumpus(_)),
  retractall(maybe_gold(_)),
  retractall(feel_breeze(_)),
  retractall(feel_stench(_)),
  retractall(feel_glitter(_)),
  retractall(pit_coords(_)),
  retractall(wumpus_coords(_)),
  retractall(gold_coords(_)),
  assert(agent_coords(1,1)),
  assert(safe_coords([1-1])),
  assert(agent_orient(0)),
  assert(maybe_pit([])),
  assert(maybe_wumpus([])),
  assert(maybe_gold([])),
  assert(feel_breeze([])),
  assert(feel_stench([])),
  assert(feel_glitter([])),
  assert(pit_coords([])),
  assert(wumpus_coords([])),
  assert(gold_coords([])),
  format('Agent initialized.\n').

agent_new_coords(X,Y,0,NX,NY) :-
  NX is X+1,
  NY is Y.

agent_new_coords(X,Y,90,NX,NY) :-
  NX is X,
  NY is Y+1.

agent_new_coords(X,Y,180,NX,NY) :-
  NX is X-1,
  NY is Y.

agent_new_coords(X,Y,270,NX,NY) :-
  NX is X,
  NY is Y-1.

x_coord(Loc, X):-
  Loc = X-Y.

y_coord(Loc, Y):-
  Loc = X-Y.

is_wumpus(X, Y):-
  wumpus_coords(W),
  member(X-Y, W).

is_pit(X, Y):-
  pit_coords(P),
  member(X-Y, P).

is_safe(X, Y) :-
  safe_coords(S),
  member(X-Y, S).

neighbors(X, Y, N) :-
  Xl is X - 1,
  Xr is X + 1,
  Yu is Y + 1,
  Yd is Y - 1,
  N = [Xl-Y, Xr-Y, X-Yu, X-Yd].

list_safe_locations(Locs):-
  format('safe locations: '),
  list_coords(Locs),
  format('\n').

list_coords([]).

list_coords(Locs):-
  Locs = [H|T],
  H = X-Y,
  format('(~d,~d) ', [X, Y]),
  list_coords(T).

% mark neighboring locations as pit-possible
find_possible_pit([], []).
find_possible_pit([H|T], P):-
  H = X-Y,
  (is_safe(X, Y) ->
  find_possible_pit(T, P);
  find_possible_pit(T, P0),
  P = [X-Y|P0]).

possible_pit_in_neighbor(X, Y):-
  neighbors(X, Y, N),
  find_possible_pit(N, P),
  maybe_pit(P0),
  retract(maybe_pit(P0)),
  union(P0, P, P1),
  assert(maybe_pit(P1)).

% mark neighboring locations as wumpus-possible
find_possible_wumpus([], []).
find_possible_wumpus([H|T], W):-
  H = X-Y,
  (is_safe(X, Y) ->
  find_possible_wumpus(T, W);
  find_possible_wumpus(T, W0),
  W = [X-Y|W0]).

possible_wumpus_in_neighbor(X, Y):-
  neighbors(X, Y, N),
  find_possible_wumpus(N, W),
  maybe_wumpus(W0),
  retract(maybe_wumpus(W0)),
  union(W0, W, W1),
  assert(maybe_wumpus(W1)).

% mark neighboring locations as gold-possible
find_possible_gold([], []).
find_possible_gold([H|T], W):-
  H = X-Y,
  (is_safe(X, Y) ->
  find_possible_gold(T, W);
  find_possible_gold(T, W0),
  W = [X-Y|W0]).

possible_gold_in_neighbor(X, Y):-
  neighbors(X, Y, N),
  find_possible_gold(N, G),
  maybe_gold(G0),
  retract(maybe_gold(G0)),
  union(G0, G, G1),
  assert(maybe_gold(G1)).

list_possible_pits :-
  maybe_pit(Locs),
  format('possible pits: '),
  list_coords(Locs),
  format('\n').

list_possible_gold :-
  maybe_gold(Locs),
  format('possible gold: '),
  list_coords(Locs),
  format('\n').

list_possible_wumpus :-
  maybe_wumpus(Locs),
  format('possible wumpus: '),
  list_coords(Locs),
  format('\n').

list_feel_breeze :-
  feel_breeze(Locs),
  format('feel breeze at: '),
  list_coords(Locs),
  format('\n').

list_feel_stench :-
  feel_stench(Locs),
  format('feel stench at: '),
  list_coords(Locs),
  format('\n').

list_feel_glitter :-
  feel_glitter(Locs),
  format('feel glitter at: '),
  list_coords(Locs),
  format('\n').

add_feel_breeze(X, Y) :-
  feel_breeze(B0),
  retract(feel_breeze(B0)),
  union(B0, [X-Y], B1),
  assert(feel_breeze(B1)).

add_feel_stench(X, Y) :-
  feel_stench(B0),
  retract(feel_stench(B0)),
  union(B0, [X-Y], B1),
  assert(feel_stench(B1)).

add_feel_glitter(X, Y) :-
  feel_glitter(B0),
  retract(feel_glitter(B0)),
  union(B0, [X-Y], B1),
  assert(feel_glitter(B1)).

%   Action is one of:
%     goforward: move one square along current orientation if possible
%     turnleft:  turn left 90 degrees
%     turnright: turn right 90 degrees
%     grab:      pickup gold if in square
%     shoot:     shoot an arrow along orientation, killing wumpus if
%                in that direction
%     climb:     if in square 1,1, leaves the cave and adds 1000 points
%                for each piece of gold
%
%   Percept = [Stench,Breeze,Glitter,Bump,Scream]
%             The five parameters are either 'yes' or 'no'.
%             A example: ['yes', 'no', 'no', 'no', 'no'] means a perception of
%             Stench in current location

%run_agent(Percept,Action):-
run_agent(['no', 'no', 'no', 'no', 'no'], goforward ):-
  format('\n=====================================================\n'),
  format('Feeling safe to move forward.\n'),
  display_world,
  list_possible_pits,
  list_possible_gold,
  list_possible_wumpus,
  list_feel_breeze,
  list_feel_stench,
  list_feel_glitter,
  agent_coords(X, Y),
  agent_orient(Ori),
  safe_coords(L),
  neighbors(X, Y, N),
  union(L, N, L1), % mark neighbors safe
  list_safe_locations(L1),
  retract(safe_coords(L)),
  assert(safe_coords(L1)),
  agent_new_coords(X, Y, Ori, X1, Y1),
  retract(agent_coords(X, Y)),
  assert(agent_coords(X1, Y1)),
  format('agent was at (~d,~d), now at (~d,~d).\n', [X, Y, X1, Y1]),
  format('=====================================================\n\n').


run_agent([Stench, Breeze, Glitter, Bump, Scream], Action) :-
  % mark neighbors with possible pit
  display_world,
  agent_coords(X, Y),
  agent_orient(Ori),
  neighbors(X, Y, N),
  (Breeze == 'yes' -> add_feel_breeze(X, Y), possible_pit_in_neighbor(X, Y); true),
  (Stench == 'yes' -> add_feel_stench(X, Y), possible_wumpus_in_neighbor(X, Y); true),
  (Glitter == 'yes' -> add_feel_glitter(X, Y), possible_gold_in_neighbor(X, Y); true),
  list_possible_pits,
  list_possible_gold,
  list_possible_wumpus,
  list_feel_breeze,
  list_feel_stench,
  list_feel_glitter,
  Action = goforward.
