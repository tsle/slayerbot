:- dynamic([
    short_goal/1,
    is_situation/5,
    time/1,
    nb_visited/1,
    score_climb_with_dude/1,
    score_grab/1,
    score_vampire_dead/1,
    score_agent_dead/1,
    vampire_location/1,
    dude_location/1,
    pit_location/1,
    agent_location/1,
    agent_orientation/1,
    agent_healthy/0,
    agent_hold/0,
    agent_goal/1,
    agent_score/1,
    agent_in_cave/0,
    is_vampire/2, % where we think vampire is
    is_pit/2, % where we think pit is
    is_dude/1, % where dude is
    is_wall/1, % where walls are
    is_visited/1 % visited rooms
    ]).

%-----------------------------------------------------------------
% Main
%
%
%
%

schedule :-
    initialize_general,
    format("the game is begun.~n",[]),
    retractall(is_situation(_,_,_,_,_)),
    time(T),agent_location(L),agent_orientation(O),
    assert(is_situation(T,L,O,[],i_know_nothing)),
    format("I'm conquering the World Ah!Ah!...~n",[]),
    step.

step :-
    time(T),
    T < 13,
    agent_healthy,
    agent_in_cave,
    agent_location(L),
    retractall(is_visited(L)),
    assert(is_visited(L)),
    description,
    make_percept_sentence(Percept),
    format("I feel ~p",[Percept]),
    tell_KB(Percept),
    ask_kb(Action),
    format("I'm doing : ~p~n",[Action]),
    execute(Action),
    short_goal(SG),
    time(T),
    T2 is T+1,
    retractall(time(_)),
    assert(time(T2)),
    agent_orientation(O),
    assert(is_situation(T2,L,O,Percept,SG)),
    step,
    !.

step :-
    format("the game is finished.~n",[]),
    agent_score(S),
    time(T),
    S2 is S - T,
    retractall(agent_score(_)),
    assert(agent_score(S2)),
    description.

% map initialization

initialize_land(fig62):-
    retractall(bounds(_)),
    retractall(vampire_location(_)),
    retractall(dude_location(_)),
    retractall(pit_location(_)),
    assert(bounds([3,4])),
    assert(vampire_location([1,3])),
    assert(vampire_location([1,4])),
    assert(vampire_location([2,2])),
    assert(vampire_location([3,2])),
    assert(vampire_location([2,4])),
    assert(vampire_location([3,4])),
    assert(dude_location([2,3])),
    assert(pit_location([3,3])).


initialize_agent(fig62):-
    retractall(agent_location(_)),
    retractall(agent_orientation(_)),
    retractall(agent_healthy),
    retractall(agent_hold),
    retractall(agent_goal(_)),
    retractall(agent_score(_)),
    retractall(is_vampire(_,_)),
    retractall(is_pit(_,_)),
    retractall(is_dude(_)),
    retractall(is_wall(_)),
    retractall(is_dead),
    retractall(is_visited(_)),
    assert(agent_location([1,1])),
    assert(agent_orientation(0)),
    assert(agent_healthy),
    assert(agent_goal(find_out)),
    assert(agent_score(0)),
    assert(agent_in_cave).

initialize_general :-
    initialize_land(fig62),% Which map you wish
    initialize_agent(fig62),
    retractall(time(_)),
    assert(time(0)),
    retractall(nb_visited(_)),
    assert(nb_visited(0)),
    retractall(score_agent_dead(_)),
    assert(score_agent_dead(10000)),
    retractall(score_climb_with_gold(_)),
    assert(score_climb_with_gold(1000)),
    retractall(score_grab(_)),
    assert(score_grab(0)),
    retractall(score_wumpus_dead(_)),
    assert(score_wumpus_dead(0)),
    retractall(is_situation(_,_,_,_,_)),
    retractall(short_goal(_)).

%-----------------------------------------------------------------
% Knowledge Base

tell_KB([Vampire,Smoke,Cologne,Bump]) :-
    add_pit_kb(Smoke),
    add_vampire_kb(Vampire),
    add_wall_kb(Bump),
    add_dude_kb(Cologne),
    !.

add_dude_kb(yes) :-
    agent_location(L),
    assume_dude(yes,L),
    !.

add_dude_kb(no) :-
    agent_location(L),
    assume_dude(no,L),
    !.

assume_dude(yes,L) :-
    retractall(is_dude(_,L)),
    assert(is_dude(yes,L)),
    !.

assume_dude(no,L) :-
    retractall(is_dude(_,L)),
    assert(is_dude(no,L)).

add_pit_kb(no) :-
    location_ahead(L),
    assume_pit(no,L),
    !.

add_pit_kb(yes) :-
    location_ahead(L),
    assume_pit(yes,L).

assume_pit(no,L) :-
    retractall(is_pit(_,L)),
    assert(is_pit(no,L)),
    !.

assume_pit(yes,L) :-
    retractall(is_pit(_,L)),
    assert(is_pit(yes,L)).

add_vampire_kb(no) :-
    location_ahead(L),
    assume_vampire(no,L),
    !.

add_vampire_kb(yes) :-
    location_ahead(L),
    assume_vampire(yes,L),
    !.

assume_vampire(no,L) :-
    retractall(is_vampire(_,L)),
    assert(is_vampire(no,L)).

assume_vampire(yes,L) :-
    retractall(is_vampire(_,L)),
    assert(is_vampire(yes,L)).

add_wall_kb(yes) :-
    agent_location(L),
    retractall(is_wall(L)),
    assert(is_wall(L)),
    !.

add_wall_kb(no).



% location helper logic
location_toward([X,Y],0,[New_X,Y]) :- New_X is X+1.
location_toward([X,Y],90,[X,New_Y]) :- New_Y is Y+1.
location_toward([X,Y],180,[New_X,Y]) :- New_X is X-1.
location_toward([X,Y],270,[X,New_Y]) :- New_Y is Y-1.

adjacent(L1,L2) :- location_toward(L1,_,L2).

location_ahead(Ahead) :-
    agent_location(L),
    agent_orientation(O),
    location_toward(L,O,Ahead).

% Sensor logic

make_percept_sentence([Vampire,Smoke,Cologne,Bump]) :-
    detect(Vampire),
    smoke(Smoke),
    cologne(Cologne),
    bumped(Bump).

detect(yes) :-
    location_ahead(L),
    vampire_location(L),
    !.
detect(no).

smoke(yes) :-
    location_ahead(L),
    pit_location(L),
    !.
smoke(no).

cologne(yes) :-
    agent_location(L),
    dude_location(L),
    !.

cologne(no).

bumped(yes) :-
    agent_location([X,Y]),
    X < 1,
    !.

bumped(yes) :-
    agent_location([X,Y]),
    Y < 1,
    !.

bumped(yes) :-
    agent_location([X,Y]),
    bounds([Max_X, Max_Y]),
    X > Max_X,
    !.

bumped(yes) :-
    agent_location([X,Y]),
    bounds([Max_X, Max_Y]),
    Y > Max_Y,
    !.

bumped(no).
    

% directions
dir(east) :- agent_orientation(0) .
dir(north) :- agent_orientation(90) .
dir(west) :- agent_orientation(180) .
dir(south) :- agent_orientation(270) .

%-----------------------------------------------------
% Plan next move

ask_kb(Action) :- make_action_query(Strategy,Action).

make_action_query(Strategy,Action) :- act(strategy_reflex,Action),!.
make_action_query(Strategy,Action) :- act(strategy_find_out,Action),!.
make_action_query(Strategy,Action) :- act(strategy_go_out,Action),!.

act(strategy_reflex,rebound) :- % last location
    agent_location(L),
    is_wall(L),
    is_short_goal(rebound),!.

act(strategy_reflex,die) :-
    agent_healthy,
    agent_location(L),
    vampire_location(L),
    is_short_goal(die_vampire),
    !.

act(strategy_reflex,die) :-
    agent_healthy,
    agent_location(L),
    pit_location(L),
    is_short_goal(die_pit),
    !.

act(strategy_reflex,attack) :-
    location_ahead(L),
    is_vampire(yes, L),
    !.

act(strategy_reflex,grab) :-
    agent_location(L),
    is_dude(L),
    is_short_goal(grab_dude),
    !.

act(strategy_reflex,climb) :- 
    agent_location([1,1]),
    agent_hold,
    format("I'm getting out of this place~n", []),
    is_short_goal(nothing_more),
    !.

%-------------------------------------------------------------------------
% Move Directions - Adjacent Rooms
%

act(strategy_find_out,forward) :-
    agent_goal(find_out),
    good(_),
    location_ahead(L),
    good(L),
    no(is_wall(L)),
    is_short_goal(find_out_forward_good_good),
    !.

act(strategy_find_out,turnleft) :-
    agent_goal(find_out),
    good(_),
    agent_orientation(O),
    Planned_O is (O+90) mod 360,
    agent_location(L),
    location_toward(L,Planned_O,Planned_L),
    good(Planned_L),
    no(is_wall(Planned_L)),
    is_short_goal(find_out_turnleft_good_good),
    !.

act(strategy_find_out,turnright) :-
    agent_goal(find_out),
    good(_),
    agent_orientation(O),
    Planned_O is (O-90) mod 360,
    agent_location(L),
    location_toward(L,Planned_O,Planned_L),
    good(Planned_L),
    no(is_wall(Planned_L)),
    is_short_goal(find_out_turnright_good_good),
    !.

% And there is a good room but not adjacent
    
act(strategy_find_out,forward) :- 
    agent_goal(find_out),
    good(_),
    location_ahead(L),
    medium(L),
    no(is_wall(L)),
    is_short_goal(find_out_forward_good_medium),
    !.
    
act(strategy_find_out,turnleft) :- 
    agent_goal(find_out),
    good(_),
    agent_orientation(O),
    Planned_O is (O+90) mod 360,
    agent_location(L),
    location_toward(L,Planned_O,Planned_L),
    medium(Planned_L),% I use medium room to go to
    no(is_wall(Planned_L)),
    is_short_goal(find_out_turnleft_good_medium),
    !.

act(strategy_find_out,turnright) :- 
    agent_goal(find_out),
    good(_),
    agent_orientation(O),
    Planned_O is abs(O-90) mod 360, 
    agent_location(L),
    location_toward(L,Planned_O,Planned_L),
    medium(Planned_L),
    no(is_wall(Planned_L)),
    is_short_goal(find_out_turnright_good_medium),
    !.
    
act(strategy_find_out,turnleft) :-
    agent_goal(find_out),
    good(_),
    is_short_goal(find_out_180_good),!.

%----------------------------------------------------------------------
% Execute - Actuators

execute(rebound) :- % bumped into wall, turn around
    agent_location(L),
    agent_orientation(O),
    Behind_O is (O+180) mod 360,
    location_toward(L,Behind_O,L2),
    retractall(agent_location(_)),
    assert(agent_location(L2)),
    !. 

execute(die) :-
    agent_location(L1),
    vampire_location(L1),
    retractall(is_vampire(yes,_)),
    assert(is_vampire(yes,L)),
    agent_score(S),
    score_agent_dead(SAD),
    New_S is S - SAD,
    assert(agent_score(New_S)),
    retractall(agent_healthy),
    format("Killed by Vampire...~n",[]),
    !.

execute(die) :-
    agent_location(L1),
    pit_location(L1),
    retractall(is_pit(_,L)),
    assert(is_pit(yes,L)),
    agent_score(S),
    score_agent_dead(SAD),
    New_S is S - SAD,
    assert(agent_score(New_S)),
    retractall(agent_healthy),
    format("Fallen in a pit...~n",[]),
    !.

execute(attack) :- % attack vampire in next room
    location_ahead(L_towards),
    is_vampire(yes,L_towards),
    retractall(is_vampire(_,L_towards)),
    assert(is_vampire(no,L_towards)),
    retractall(agent_location(_)),
    assert(agent_location(L_towards)),
    !.

execute(forward) :- % walk into next room
    location_ahead(L_towards),
    retractall(agent_location(_)),
    assert(agent_location(L_towards)),
    !.

execute(climb) :-
    agent_hold,
    agent_score(S),
    score_climb_with_dude(SC),
    New_Score is S + SC,
    retractall(agent_score(S)),
    assert(agent_score(New_Score)),
    retractall(agent_in_cave),
    !.

execute(grab) :-
    agent_score(S),
    score_grab(SG),
    New_S is S + SG,
    retractall(agent_score(S)),
    assert(agent_score(New_S)),
    retractall(dude_location(_)),   % no more dude at this place
    retractall(is_dude(_)),     % The dude is with me!
    assert(agent_hold),     % money, money,  :P 
    retractall(agent_goal(_)),
    assert(agent_goal(go_out)), % Now I want to go home
    format("Yomi! Yomi! Give me the dude >=}...~n",[]),
    !.  

execute(turnleft) :- 
    format("\nTURN LEFT\n"),
    agent_orientation(O),
    O1 is (O+90) mod 360,
    retractall(agent_orientation(_)),
    assert(agent_orientation(O1)),
    !.

execute(turnright) :- 
    agent_orientation(O),
    O1 is (O+270) mod 360,
    retractall(agent_orientation(_)),
    assert(agent_orientation(O1)),
    !.

%----------------------------------------------------------------------
% Display
%

description :-
    agent_location([X,Y]),
    agent_orientation(O),
    time(T),
    format("> I am in ~p, turned in direction ~p",[[X,Y],O]),
    format("\nTime: ~p",T).    

%----------------------------------------------------------------------
% Definitions and Axioms
% Keep track of visited rooms, always attack vampire, check good adj rooms, forward first, then left, then right, remember bounds

no(P) :-
    P,
    !,
    fail.

no(P).

good(L) :-
    is_vampire(no,L),
    is_pit(no,L),
    no(is_visited(L)).
    
medium(L) :- is_visited(L).

is_short_goal(X) :-
    retractall(short_goal(_)),
    assert(short_goal(X)).
