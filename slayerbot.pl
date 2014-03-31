
% Knowledge Base

tell_KB([Vampire,Smoke,Cologne,Bump]) :-
    add_pit_kb(Smoke),
    add_vampire_kb(Vampire),
    add_wall_kb(Bump),
    add_dude_kb(Cologne),
    !.

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

add_wall_KB(yes) :-% here I know where there is wall
    agent_location(L),
    retractall(is_wall(L)),
    assert(is_wall(L)),
    !.

add_wall_KB(no).



% location helper logic
location_toward([X,Y],0,[New_X,Y]) :- New_X is X+1.
location_toward([X,Y],90,[X,New_Y]) :- New_Y is Y+1.
location_toward([X,Y],180,[New_X,Y]) :- New_X is X-1.
location_toward([X,Y],270,[X,New_Y]) :- New_Y is Y-1.

adjacent(L1,L2) :- location_toward(L1,_,L2).

location_ahead(Ahead) :-
    location(L),
    orientation(O),
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
    location(L),
    dude(L),
    !.

cologne(no).

bumped(yes) :-
    location([X,Y]),
    X < 1,
    !.

bumped(yes) :-
    location([X,Y]),
    Y < 1,
    !.

bumped(yes) :-
    location([X,Y]),
    bounds([Max_X, Max_Y]),
    X > Max_X,
    !.

bumped(yes) :-
    location([X,Y]),
    bounds([Max_X, Max_Y]),
    Y > Max_Y,
    !.

bumped(no).
    

% directions
dir(east) :- orientation(0) .
dir(north) :- orientation(90) .
dir(west) :- orientation(180) .
dir(south) :- orientation(270) .

%-----------------------------------------------------
% Plan next move
%

make_action_query(Strategy,Action) :- act(strategy_reflex,Action),!.
make_action_query(Strategy,Action) :- act(strategy_find_out,Action),!.
make_action_query(Strategy,Action) :- act(strategy_go_out,Action),!.

act(strategy_reflex,rebound) :- % last location
    location(L),
    is_wall(L),
    is_short_goal(rebound),!.

act(strategy_reflex,die) :-
    agent_healthy,
    vampire_healthy,
    location(L),
    vampire_location(L),
    is_short_goal(die_vampire),
    !.

act(strategy_reflex,die) :-
    agent_healthy,
    location(L),
    pit_location(L),
    is_short_goal(die_pit),
    !.

act(strategy_reflex,attack) :-
    location_ahead(L),
    is_vampire(yes, L),
    !.

act(strategy_reflex,grab) :-
    location(L),
    is_dude(L),
    is_short_goal(grab_dude),
    !.

act(strategy_reflex,climb) :- 
    location([1,1]),
    agent_hold,
    format("I'm getting out of this place~n", []),
    is_short_goal(nothing_more),
    !.

%-------------------------------------------------------------------------
% Move Directions
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
    location(L),
    location_toward(L,Planned_O,Planned_L),
    good(Planned_L),
    no(is_wall(Planned_L)),
    is_short_goal(find_out_turnleft_good_good),
    !.

act(strategy_find_out,turnleft) :-
    agent_goal(find_out),
    good(_),
    agent_orientation(O),
    Planned_O is (O-90) mod 360,
    location(L),
    location_toward(L,Planned_O,Planned_L),
    good(Planned_L),
    no(is_wall(Planned_L)),
    is_short_goal(find_out_turnleft_good_good),
    !.

% Actuators
% change state of slayer bot
execute(turn_left) :- 
    orientation(O),
    01 is (O+90) mod 360,
    retractall(orientation(_)),
    assert(orientation(O1)),
    !.
execute(turn_left) :- 
    orientation(O),
    01 is (O+270) mod 360,
    retractall(orientation(_)),
    assert(orientation(O1)),
    !.



