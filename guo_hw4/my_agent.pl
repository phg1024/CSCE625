%my_agent.pl

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
  format('This is init_agent:\n\tIt gets called once, use it for your initialization\n\n'),
  format('=====================================================\n\n').

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
run_agent(_, goforward ):-
  format('\n=====================================================\n'),
  format('This is run_agent(.,.):\n\t It gets called each time step.\n\tThis default one simply moves forward\n'),
  format('You might find "display_world" useful, for your debugging.\n'),
  display_world,
  format('=====================================================\n\n').
