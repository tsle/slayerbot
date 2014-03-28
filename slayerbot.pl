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
detect(yes) :-
    location_ahead(L),
    vampire_location(L),
    !.
detect(no).

smoke(yes) :-
    location_ahead(L),
    pit_location(L),
    !.
smooke(no).

cologne(yes) :-
    location(L),
    dude(L),
    !.
cologne(no).

% directions
dir(east) :- orientation(0) .
dir(north) :- orientation(90) .
dir(west) :- orientation(180) .
dir(south) :- orientation(270) .

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



