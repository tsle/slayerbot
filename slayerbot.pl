
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

ask_kb(Action) :- make_action_query(Strategy,Action).

make_action_query(Strategy,Action) :- act(strategy_reflex,Action),!.
make_action_query(Strategy,Action) :- act(strategy_find_out,Action),!.
make_action_query(Strategy,Action) :- act(strategy_go_out,Action),!.

act(strategy_reflex,rebound) :- % last location
    location(L),
    is_wall(L),
    is_short_goal(rebound),!.

act(strategy_reflex,die) :-
    alive,
    location(L),
    vampire_location(L),
    is_short_goal(die_vampire),
    !.

act(strategy_reflex,die) :-
    alive,
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
    location(L),
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
    location(L),
    location_toward(L,Planned_O,Planned_L),
    good(Planned_L),
    no(is_wall(Planned_L)),
    is_short_goal(find_out_turnright_good_good),
    !.

% And there is a good room but not adjacent
    
act(strategy_find_out,forward) :- 
    agent_goal(find_out),
    agent_courage,
    good(_),
    location_ahead(L),
    medium(L),
    no(is_wall(L)),
    is_short_goal(find_out_forward_good_medium),
    !.
    
act(strategy_find_out,turnleft) :- 
    agent_goal(find_out),
    agent_courage,
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
    agent_courage,
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
    agent_courage,
    good(_),
    is_short_goal(find_out_180_good_),!.
    act(strategy_find_out,forward) :-
    agent_goal(find_out)

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

%----------------------------------------------------------------------
% Execute - Actuators
%

execute(bump) :- % bumped into wall, turn around
    agent_location(L),
    agent_orientation(O),
    Behind_O is (O+180) mod 360,
    location_ahead(L,Behind_O,L2),
    retractall(agent_location(_)),
    assert(agent_location(L2)),
    !. 

execute(attack) :- % attack vampire in next room
    location_ahead(L_towards),
    is_vampire(L_towards),
    retractall(is_vampire(L_towards)),
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
    
medium(L) :- 
    is_visited(L).
