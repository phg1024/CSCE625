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
  retractall(feel_breeze(_)),
  retractall(feel_stench(_)),
  retractall(feel_glitter(_)),
  retractall(pit_coords(_)),
  retractall(wumpus_coords(_)),
  retractall(gold_coords(_)),
  retractall(visited(_)),
  retractall(targets(_)),
  retractall(world_boundary(_)),
  assert(agent_coords(1,1)),
  assert(safe_coords([1-1])),
  assert(agent_orient(0)),
  assert(feel_breeze([])),
  assert(feel_stench([])),
  assert(feel_glitter([])),
  assert(pit_coords([])),
  assert(wumpus_coords([])),
  assert(gold_coords([])),
  assert(visited([])),
  assert(targets([])),
  assert(world_boundary(-10000, -10000, 10000, 10000)),
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

neighbors(X, Y, N) :-
  Xl is X - 1, Xr is X + 1, Yu is Y + 1, Yd is Y - 1,
  N = [Xr-Y, X-Yu, Xl-Y, X-Yd].

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

maybe_pit(X, Y):-
  feel_breeze(B),
  Xl is X - 1, Xr is X + 1, Yu is Y + 1, Yd is Y - 1,
  member(Xl-Y, B); member(Xr-Y, B); member(X-Yu, B); member(X-Yd, B).

exclude_pit_in_neighbor(X, Y):-
  Xl is X - 1, Xr is X + 1, Yu is Y + 1, Yd is Y - 1,
  assert(is_pit(Xl-Y, no)),
  assert(is_pit(Xr-Y, no)),
  assert(is_pit(X-Yu, no)),
  assert(is_pit(X-Yd, no)).

maybe_gold(X, Y):-
  feel_glitter(G),
  Xl is X - 1, Xr is X + 1, Yu is Y + 1, Yd is Y - 1,
  member(Xl-Y, G); member(Xr-Y, G); member(X-Yu, G); member(X-Yd, G).

exclude_gold_in_neighbor(X, Y):-
  Xl is X - 1, Xr is X + 1, Yu is Y + 1, Yd is Y - 1,
  assert(is_gold(Xl-Y, no)),
  assert(is_gold(Xr-Y, no)),
  assert(is_gold(X-Yu, no)),
  assert(is_gold(X-Yd, no)).

maybe_wumpus(X, Y):-
  feel_stench(S),
  Xl is X - 1, Xr is X + 1, Yu is Y + 1, Yd is Y - 1,
  member(Xl-Y, S); member(Xr-Y, S); member(X-Yu, S); member(X-Yd, S).

exclude_wumpus_in_neighbor(X, Y):-
  Xl is X - 1, Xr is X + 1, Yu is Y + 1, Yd is Y - 1,
  assert(is_wumpus(Xl-Y, no)),
  assert(is_wumpus(Xr-Y, no)),
  assert(is_wumpus(X-Yu, no)),
  assert(is_wumpus(X-Yd, no)).

is_safe(X, Y):-
  \+is_pit(X, Y),
  \+is_wumpus(X, Y).

list_possible_pits :- maybe_pit(Locs), format('possible pits: '), list_coords(Locs), format('\n').
list_possible_gold :- maybe_gold(Locs), format('possible gold: '), list_coords(Locs), format('\n').
list_possible_wumpus :- maybe_wumpus(Locs), format('possible wumpus: '), list_coords(Locs), format('\n').
list_feel_breeze :- feel_breeze(Locs), format('feel breeze at: '), list_coords(Locs), format('\n').
list_feel_stench :- feel_stench(Locs), format('feel stench at: '), list_coords(Locs), format('\n').
list_feel_glitter :- feel_glitter(Locs), format('feel glitter at: '), list_coords(Locs), format('\n').
list_targets :- targets(Locs), format('targets: '), list_coords(Locs), format('\n').
list_visited :- visited(Locs), format('visited: '), list_coords(Locs), format('\n').

add_feel_breeze(X, Y) :-
  feel_breeze(B0),
  retractall(feel_breeze(_)),
  union(B0, [X-Y], B1),
  assert(feel_breeze(B1)).

add_feel_stench(X, Y) :-
  feel_stench(B0),
  retractall(feel_stench(_)),
  union(B0, [X-Y], B1),
  assert(feel_stench(B1)).

add_feel_glitter(X, Y) :-
  feel_glitter(B0),
  retractall(feel_glitter(_)),
  union(B0, [X-Y], B1),
  assert(feel_glitter(B1)).

add_path(X1-Y1, X2-Y2):-
  assert(has_path(X1-Y1, X2-Y2)),
  assert(has_path(X2-Y2, X1-Y1)).

add_path_to_neighbor(X, Y, []).
add_path_to_neighbor(X, Y, [H|T]):-add_path(X-Y, H), add_path_to_neighbor(X, Y, T).

visit(X, Y) :-
  format('visiting ~d, ~d\n', [X, Y]),
  visited(V0),
  retractall(visited(_)),
  union(V0, [X-Y], V1),
  assert(visited(V1)),
  targets(T), %remove visited from targets
  delete(T, X-Y, NT),
  retractall(targets(_)),
  assert(targets(NT)),
  neighbors(X, Y, N),
  add_path_to_neighbor(X, Y, N).

print_planned_route(R):-
  format('planned route: '),
  list_coords(R),
  format('\n').

% the list of targets is empty, no where to go
current_target(TX, TY):-
  targets([]),
  TX is -1, TY is -1.

current_target(TX, TY):-
  targets([H|T]),
  x_coord(H, TX),
  y_coord(H, TY).

%% path finding predicates
connected(X-Y1, X-Y2):-
  format('testing connection ~d,~d to ~d,~d ...', [X, Y1, X, Y2]),
  has_path(X-Y1, X-Y2),
  is_safe(X, Y2),
  (Y1 is Y2 + 1; Y1 is Y2 - 1),
  format('can go\n').

connected(X1-Y, X2-Y):-
  format('testing connection ~d,~d to ~d,~d ...', [X1, Y, X2, Y]),
  has_path(X-Y1, X-Y2),
  is_safe(X2, Y),
  (X1 is X2 + 1; X1 is X2 - 1),
  format('can go\n').

% degenerate case
route(A,B,Visited,Path,L) :-
  has_path(A,B),
  append(Visited, [A, B], Path),
  L = 1.

% general case
route(A,B,Visited,Path,L) :-
  A = X-Y,
  neighbors(X, Y, N),
  member(C, N),
  has_path(A,C),
  C \== B,
  \+member(C,Visited),  % necessary if there is loop in the graph
  append(Visited, [A], NewVisited),
  route(C,B,NewVisited,Path,Lp),
  L is 1+Lp.

% from a set of paths, find the shortest one
shortest([Head|Tail],M) :- shortestRoute(Tail,Head,M).
shortestRoute([],M,M).
shortestRoute([Head|Tail], CurMin, Min) :-
  Head = [_|L],
  CurMin = [_|Lmin],
  L < Lmin, !, shortestRoute(Tail, Head, Min).
shortestRoute([_|Tail],CurMin,Min) :- shortestRoute(Tail,CurMin,Min).

path(A, A, []).

path(A,B,Path) :-
  A = X0-Y0, B = X1-Y1,
  format('planning path from ~d, ~d to ~d, ~d\n', [X0, Y0, X1, Y1]),
  pathWithLength(A, B, Path, _).

pathWithLength(A, B, Path, Length) :-
  setof([Path, Len],route(A,B,[],Path,Len), PathSet),	% the set of all paths
  PathSet \== [], % the set of path must not be empty
  format('paths found.\n'),
  shortest(PathSet,[Path, Length]).

next_pos([H|T], Pos):-
  T = [T1|_],
  Pos = T1.

best_turn(X-Y, X-Y1, 0, Action):- Y is Y1 + 1, Action = turnleft.
best_turn(X-Y, X-Y1, 0, Action):- Y is Y1 - 1, Action = turnright.
best_turn(X-Y, X1-Y, 0, Action):- X is X1 + 1, Action = turnright.

best_turn(X-Y, X-Y1, 180, Action):- Y is Y1 + 1, Action = turnright.
best_turn(X-Y, X-Y1, 180, Action):- Y is Y1 - 1, Action = turnleft.
best_turn(X-Y, X1-Y, 180, Action):- X is X1 - 1, Action = turnright.

best_turn(X-Y, X1-Y, 90, Action):- X is X1 + 1, Action = turnleft.
best_turn(X-Y, X1-Y, 90, Action):- X is X1 - 1, Action = turnright.
best_turn(X-Y, X-Y1, 90, Action):- Y is Y + 1, Action = turnright.

best_turn(X-Y, X1-Y, 270, Action):- X is X1 + 1, Action = turnright.
best_turn(X-Y, X1-Y, 270, Action):- X is X1 - 1, Action = turnleft.
best_turn(X-Y, X-Y1, 270, Action):- Y is Y - 1, Action = turnright.

same_direction(X-Y1, X-Y2, Ori):- Y1 is Y2-1, Ori is 270.
same_direction(X-Y1, X-Y2, Ori):- Y1 is Y2+1, Ori is 90.
same_direction(X1-Y, X2-Y, Ori):- X1 is X2-1, Ori is 0.
same_direction(X1-Y, X2-Y, Ori):- X1 is X2+1, Ori is 180.

%% update targets
update_targets([Breeze, Stench, Glitter, Bump]):-
  (Breeze == 'yes'; Stench == 'yes'),
  format('updating targets...\n'),
  agent_coords(X, Y),
  format('the agent is at ~d, ~d\n', [X, Y]),
  format('feeling good, add all neighbors to the target list\n'),
  neighbors(X, Y, N),
  format('neighbors: '), list_coords(N), format('\n'),
  targets(T),
  visited(V),
  retractall(targets(_)),
  subtract(N, V, NN),
  subtract(T, NN, NT),
  format('new targets: '), list_coords(NT), format('\n'),
  assert(targets(NT)).

update_targets(['no', 'no', 'no', Bump]):-
  format('updating targets...\n'),
  agent_coords(X, Y),
  format('the agent is at ~d, ~d\n', [X, Y]),
  format('feeling good, add all neighbors to the target list\n'),
  neighbors(X, Y, N),
  format('neighbors: '), list_coords(N), format('\n'),
  targets(T),
  visited(V),
  retractall(targets(_)),
  union(T, N, T1),
  format('new targets: '), list_coords(T1), format('\n'),
  subtract(T1, V, NT),
  format('valid new targets: '), list_coords(NT), format('\n'),
  assert(targets(NT)).

%% decision making predicates
make_action_decision([Breeze, Stench, Glitter, Bump], Action):-
  format('perceived: ~s, ~s, ~s, ~s\n', [Breeze, Stench, Glitter, Bump]),
  (Bump == 'yes' % remove the out of range target
  -> targets([H|T]),
  retractall(targets(_)),
  assert(targets(T)),
  visited(V0),
  union(V0, [H], V1),
  retractall(visited(V0)),
  assert(visited(V1))
  ;true),
  agent_coords(X, Y),
  format('the agent is at ~d, ~d\n', [X, Y]),
  current_target(TX, TY),
  format('current target location is ~d, ~d\n', [TX, TY]),
  path(X-Y, TX-TY, R),
  print_planned_route(R),
  agent_orient(Ori),
  format('agent orientation ~d\n', [Ori]),
  next_pos(R, Next),
  (same_direction(X-Y, Next, Ori)
  -> Action = goforward, format('same direction, can go forward\n')
  ; format('need to turn\n'), best_turn(X-Y, Next, Ori, Action)).

set_world_boundary(X, Y, 0):-
  world_boundary(Xmin, Ymin, Xmax, Ymax),
  retractall(world_boundary(_)),
  assert(world_boundary(Xmin, Ymin, X, Ymax)).

set_world_boundary(X, Y, 90):-
  world_boundary(Xmin, Ymin, Xmax, Ymax),
  retractall(world_boundary(_)),
  assert(world_boundary(Xmin, Y, Xmax, Ymax)).

set_world_boundary(X, Y, 180):-
  world_boundary(Xmin, Ymin, Xmax, Ymax),
  retractall(world_boundary(_)),
  assert(world_boundary(X, Ymin, Xmax, Ymax)).

set_world_boundary(X, Y, 270):-
  world_boundary(Xmin, Ymin, Xmax, Ymax),
  retractall(world_boundary(_)),
  assert(world_boundary(Xmin, Ymin, Xmax, Y)).


update_KB([Breeze, Stench, Glitter, Bump]):-
  format('perceived: ~s, ~s, ~s, ~s\n', [Breeze, Stench, Glitter, Bump]),
  format('updating KB ...\n'),
  agent_coords(X, Y),
  agent_orient(Ori),
  (Breeze == 'yes' -> add_feel_breeze(X, Y); exclude_pit_in_neighbor(X, Y)),
  (Stench == 'yes' -> add_feel_stench(X, Y); exclude_wumpus_in_neighbor(X, Y)),
  (Glitter == 'yes' -> add_feel_glitter(X, Y); exclude_gold_in_neighbor(X, Y)),
  (Bump == 'yes' -> set_world_boundary(X, Y, Ori); true).

set_agent_orient(Ori):- retractall(agent_orient(_)), assert(agent_orient(Ori)).
set_agent_coords(X, Y):- retractall(agent_coords(_, _)), assert(agent_coords(X, Y)).

update_agent_coords(turnleft):-agent_orient(Ori), NewOri is (Ori+90) mod 360, set_agent_orient(NewOri).
update_agent_coords(turnright):-agent_orient(Ori), NewOri is (Ori+270) mod 360, set_agent_orient(NewOri).
update_agent_coords(goforward):-
  format('going forward\n'),
  agent_coords(X, Y), agent_orient(Ori),
  agent_new_coords(X, Y, Ori, NX, NY), set_agent_coords(NX, NY).
update_agent_coords(grab).
update_agent_coords(shoot).
update_agent_coords(climb).


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
run_agent([Stench, Breeze, Glitter, Bump, Scream], Action) :-
  % mark neighbors with possible pit
  display_world,
  agent_coords(X, Y),
  agent_orient(Ori),
  neighbors(X, Y, N),
  update_KB([Breeze, Stench, Glitter, Bump]),
  visit(X, Y),
  update_targets([Breeze, Stench, Glitter, Bump]),
  list_feel_breeze,
  list_feel_stench,
  list_feel_glitter,
  list_targets,
  list_visited,
  make_action_decision([Breeze, Stench, Glitter, Bump], Action),
  update_agent_coords(Action).
