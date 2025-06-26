:- ['farm.pro'].

:- dynamic number_of_agents/1.

% state(Agents, Objects).
% Agents = agent_dict{AgentId: agent{x, y, type, energy_point, children, subtype}, ...}
% Objects = object_dict{ObjectId: object{x, y, type, subtype}, ...}
/**************************************************/

% move/4 predicate is true if the agent can make the move and the new state is NewState
move(State, AgentId, Action, NewState):-
    State = [Agents, Objects],
    call(Action, AgentId, Agents, NewAgent), % call the action (call(move_up, AgentId, Agents, NewAgent))
    put_dict(AgentId, Agents, NewAgent, NewAgents),
    NewState = [NewAgents, Objects].

% move_random/4 predicate is true if the agent can make the random move
move_random(AgentId, Objects, Agents, NewAgent):-
    random_move(Agents, Objects, AgentId, Action),
    call(Action, AgentId, Agents, NewAgent).


move_up(AgentId, Agents, NewAgent):-
    get_dict(AgentId, Agents, Agent),
    get_dict(y, Agent, Y), Y1 is Y - 1, \+is_occupied(Agent.type, AgentId, Agent.x, Y1, Agents), put_dict(y, Agent, Y1, NewAgent).

move_down(AgentId, Agents, NewAgent):-
    get_dict(AgentId, Agents, Agent),
    get_dict(y, Agent, Y), Y1 is Y + 1, \+is_occupied(Agent.type, AgentId, Agent.x, Y1, Agents), put_dict(y, Agent, Y1, NewAgent).

move_right(AgentId, Agents, NewAgent):-
    get_dict(AgentId, Agents, Agent),
    get_dict(x, Agent, X), X1 is X + 1, \+is_occupied(Agent.type, AgentId, X1, Agent.y, Agents), put_dict(x, Agent, X1, NewAgent).

move_left(AgentId, Agents, NewAgent):-
    get_dict(AgentId, Agents, Agent),
    get_dict(x, Agent, X), X1 is X - 1, \+is_occupied(Agent.type, AgentId, X1, Agent.y, Agents), put_dict(x, Agent, X1, NewAgent).

move_up_right(AgentId, Agents, NewAgent):-
    get_dict(AgentId, Agents, Agent),
    get_dict(x, Agent, X), get_dict(y, Agent, Y), X1 is X + 1, Y1 is Y - 1, \+is_occupied(Agent.type, AgentId, X1, Y1, Agents), put_dict(x, Agent, X1, NewAgent_), put_dict(y, NewAgent_, Y1, NewAgent).

move_up_left(AgentId, Agents, NewAgent):-
    get_dict(AgentId, Agents, Agent),
    get_dict(x, Agent, X), get_dict(y, Agent, Y), X1 is X - 1, Y1 is Y - 1, \+is_occupied(Agent.type, AgentId, X1, Y1, Agents), put_dict(x, Agent, X1, NewAgent_), put_dict(y, NewAgent_, Y1, NewAgent).

move_down_right(AgentId, Agents, NewAgent):-
    get_dict(AgentId, Agents, Agent),
    get_dict(x, Agent, X), get_dict(y, Agent, Y), X1 is X + 1, Y1 is Y + 1, \+is_occupied(Agent.type, AgentId, X1, Y1, Agents), put_dict(x, Agent, X1, NewAgent_), put_dict(y, NewAgent_, Y1, NewAgent).

move_down_left(AgentId, Agents, NewAgent):-
    get_dict(AgentId, Agents, Agent),
    get_dict(x, Agent, X), get_dict(y, Agent, Y), X1 is X - 1, Y1 is Y + 1, \+is_occupied(Agent.type, AgentId, X1, Y1, Agents), put_dict(x, Agent, X1, NewAgent_), put_dict(y, NewAgent_, Y1, NewAgent).

/**************************************************/

% is_occupied/5 predicate is true if the position is occupied by another agent or out of the map for herbivores
is_occupied(herbivore, AgentId, X, Y, Agents):-
    width(Width), height(Height),
    (
        (X < 1; Y < 1; X >= Width-1; Y >= Height-1);
        (get_dict(Id, Agents, Agent), Id \= AgentId, Agent.x = X, Agent.y = Y)
    ).

% is_occupied/5 predicate is true if the position is out of the map for carnivores
is_occupied(carnivore, AgentId, X, Y, Agents):-
    width(Width), height(Height),
    ((X < 1; Y < 1; X >= Width-1; Y >= Height-1);
     (get_dict(Id, Agents, Agent), Id \= AgentId, Agent.type = carnivore, Agent.x = X, Agent.y = Y) ). 


is_occupied_rep(Agents, Objects, AgentId, Action):-
    call(Action, AgentId, Agents, NewAgent),
    (get_dict(_, Objects, Object), Object.x = NewAgent.x, Object.y = NewAgent.y).

/**************************************************/

% eat/3 is true if the agent can eat the food and the new state is NewState
% If it can reproduce, it reproduces automatically and child moves randomly

eat(State, AgentId, NewState):-
    State = [Agents, Objects],
    get_dict(AgentId, Agents, Agent),
    check_food(Agent.type, AgentId, Agents, Objects, Food),
    energy_point(Food.subtype, EP), 
    NewEP is Agent.energy_point + EP,
    put_dict(energy_point, Agent, NewEP, NA),
    put_dict(AgentId, Agents, NA, NAs_),

    ((Agent.type = herbivore) -> 
        (
            ((
                get_dict(ObjectId, Objects, F), 
                Food.x = F.x, 
                Food.y = F.y
            ),
            del_dict(ObjectId, Objects, _ ,NewObjects),
            State_ = [NAs_, NewObjects]        
        ),
        (
            can_reproduce(NA) -> 
            reproduce(State_, AgentId, NewState);
            ( 
            NewState = [NAs_, NewObjects])
        )
        );

        (
            ((
                get_dict(AId, Agents, F), 
                AgentId \= AId, 
                Food.x = F.x, 
                Food.y = F.y
            ),
            del_dict(AId, NAs_, _ ,NAs),
            %write('Wolf eats an agent'), write(AId), nl,
            State_ = [NAs, Objects]
        ),
        (
            can_reproduce(NA) -> 
            reproduce(State_, AgentId, NewState);
            NewAgents = NAs, 
            NewState = [NewAgents, Objects])
        )
    ).

reproduce(State, AgentId, NewState):-
    State = [Agents, Objects],
    get_dict(AgentId, Agents, Agent),
    reproduction_ep(Agent.subtype, EnergyPoint),
    NewEP is Agent.energy_point - EnergyPoint ,
    put_dict(energy_point, Agent, NewEP, NA_),
    Nc is Agent.children + 1, 
    put_dict(children, NA_, Nc, NA),
    put_dict(AgentId, Agents, NA, NAs_),
    
    % get the max agent id
    find_max_id(Agents, N), N1 is N+1,
    put_dict(N1, NAs_, agents{x: Agent.x, y: Agent.y, type: Agent.type, energy_point: 0, children: 0, subtype: Agent.subtype}, NAs),

    %print_state([NAs, Objects, Time, TurnOrder]), nl,
    (
        move_rep(NAs, Objects, N1, NewActionList)
    ),
    (member(NewAction, NewActionList), !, call(NewAction, N1, NAs, NewAgent)),
    put_dict(N1, NAs, NewAgent, NewAgents),
    NewState = [NewAgents, Objects].

% can_reproduce/1 predicate is true if the agent has enough energy point to reproduce
can_reproduce(Agent):-
    reproduction_ep(Agent.subtype, EnergyPoint),
    Agent.energy_point >= EnergyPoint.


find_max_id(Dict, Max_id):-
    dict_pairs(Dict, _, Pairs),
    find_max_key(Pairs, Max_id).

find_max_key([Key-_|T], Max_id):-
    find_max_key(T, Key, Max_id).

find_max_key([], Max_id, Max_id):-!.

find_max_key([Key-_|T], Temp, Max_id):-
    Key > Temp,
    find_max_key(T, Key, Max_id).


/**************************************************/

% make_one_action/4 predicate is true if the agent can make the action and the new state is NewState
make_one_action(Action, State, Id, NewState):-
    State = [Agents, _],
    AgentId = Id,
    get_dict(AgentId, Agents, Agent),
    
    ((member(Action, [move_up, move_down, move_left, move_right, move_up_right, move_up_left, move_down_right, move_down_left])) ->
        (can_move(Agent.subtype, Action), move(State, AgentId, Action, NewState));
        (Action = eat -> eat(State, AgentId, NewState)),!
    ).

make_one_action_print(Action, State, Id, NewState):-
    State = [Agents, _],
    AgentId = Id,
    get_dict(AgentId, Agents, Agent),
    
    ((member(Action, [move_up, move_down, move_left, move_right, move_up_right, move_up_left, move_down_right, move_down_left])) ->
        (can_move(Agent.subtype, Action), move(State, AgentId, Action, NewState));
        (Action = eat -> eat(State, AgentId, NewState)),!
    ),
    print_state(NewState).

% make_series_of_actions/4 predicate is true if the agent can make the series of actions
make_series_of_actions([Action|T], State, Id, NewState):-
    make_one_action(Action, State, Id, NewState_),
    make_series_of_actions(T, NewState_, Id, NewState),!.

make_series_of_actions([], S, _, S):-!.

make_series_of_actions_print([Action|T], State, Id):-
    make_one_action_print(Action, State, Id, NewState_),
    make_series_of_actions_print(T, NewState_, Id),!.

make_series_of_actions_print([], _, _):-!.

/**************************************************/

init_from_map :-
    read_file(Objects,[X,Y]),
    W is Y+2,
    H is X+2,
    retractall(width(_)), retractall(height(_)), retractall(state(_, _)),
    assertz(width(W)), assertz(height(H)),
    As = agent_dict{},
    Ss = object_dict{},
    fill_map(Objects, [As,Ss], [A,S], 0, 0, Na, No),
    assertz(number_of_agents(Na)),
    assertz(number_of_objects(No)),
    assertz(global_time(0)),
% !!!!!!! state(Agents, Objects) is asserted. Now, state is defined in the knowledge base. So you can use it!!!!!!!
    retractall(state(_, _)), assertz(state(A, S)),!.


init_from_map(MapName) :-
    read_file(MapName,Objects,[X,Y]),
    W is Y+2,
    H is X+2,
    retractall(width(_)), retractall(height(_)), retractall(state(_, _)),
    assertz(width(W)), assertz(height(H)),
    As = agent_dict{},
    Ss = object_dict{},
    fill_map(Objects, [As,Ss], [A,S], 0, 0, Na, No),
    assertz(number_of_agents(Na)),
    assertz(number_of_objects(No)),
    assertz(global_time(0)),
    retractall(state(_, _)), assertz(state(A, S)),!.

read_file(MapName, Objects,[X,Y]):-
    open(MapName, read, File),
    read_lines(File, Objects, -1,[X,Y]),
    close(File).
/**************************************************/

    
get_object_from_position(X, Y, Objects, Object, ObjectId) :-
    dict_pairs(Objects, _, Pairs),
    member(ObjectId-Object, Pairs),
    get_dict(x, Object, X), get_dict(y, Object, Y),!.

get_object(State,ObjectId, Object) :-
    State = [_, Objects],
    get_dict(ObjectId, Objects, Object).

check_food(herbivore, AgentId, Agents, Objects, Food):-
    get_dict(AgentId, Agents, Agent),
    dict_pairs(Objects, _, Pairs),
    member(_-Food, Pairs),
    get_dict(x, Food, Agent.x), get_dict(y, Food, Agent.y), !,
    can_eat(Agent.subtype, Food.subtype).

check_food(carnivore, AgentId, Agents, _, Food):-
    get_dict(AgentId, Agents, Agent),
    dict_pairs(Agents, _, Pairs),
    member(_-Food, Pairs),
    get_dict(x, Food, Agent.x), get_dict(y, Food, Agent.y), Agent.subtype \= Food.subtype,!,
    can_eat(Agent.subtype, Food.subtype).


get_agent(State, AgentId, Agent) :-
    State = [Agents, _],
    get_dict(AgentId, Agents, Agent).


random_move(Agents, Objects, AgentId, Action):-
    findall(
        Action_, 
        (
            get_dict(AgentId, Agents, Agent),
            can_move(Agent.subtype, Action_),
            call(Action_, AgentId, Agents, _),
            \+is_occupied_rep(Agents, Objects, AgentId, Action_)), 
        ActionList
        ),
    random_member(Action, ActionList).

random_move_list_updated(_, 0, _, []):-!.

random_move_list_updated(State, R, AgentId, [Action_|T]):-
    R > 0 ,
    State = [Agents, _],
    get_dict(AgentId, Agents, Agent),
    findall(Action, (can_move(Agent.subtype, Action)), ActionList),
    random_member(Action_, ActionList),
    R1 is R - 1,
    random_move_list_updated(State, R1, AgentId, T).

random_move_list(_, 0, [], _):-!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
random_move_list(State, R, [Action_|T], Id):-
    R > 0 ,
    State = [Agents, _],
    get_dict(Id, Agents, Agent),
    findall(Action, (can_move(Agent.subtype, Action)), ActionList),
    random_member(Action_, ActionList),
    R1 is R - 1,
    random_move_list(State, R1, T, _).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_rep(Agents, Objects, AgentId, ActionList):-
    findall(
        Action_, 
        (
            get_dict(AgentId, Agents, Agent),
            can_move(Agent.subtype, Action_),
            call(Action_, AgentId, Agents, _),
            \+is_occupied_rep(Agents, Objects, AgentId, Action_)), 
        ActionList
        ).
    
/**************************************************/

/**************************************************/

fill_map([],[A,S],[A,S],X,Y,Na,No):- Na is Y, No is X, !.

fill_map([[_,_,'.']|L],[A,S],[An,Sn],Id_object, Id_agent, Na, No):-
    fill_map(L,[A,S],[An,Sn],Id_object, Id_agent, Na, No).

fill_map([[X,Y,Type]|L],[A,S],[An,Sn],Id_object, Id_agent, Na, No):-
    Type \= '.',
    (
        (Type = 'cow' ->
            put_dict(Id_agent, A, agents{x: X, y: Y, type: herbivore, energy_point: 0, children: 0, subtype: cow}, An_),
            Id_agent_ is Id_agent + 1,
            Id_object_ is Id_object,
            Sn_ = S
            );
        
        (Type = 'chicken' ->
            put_dict(Id_agent, A, agents{x: X, y: Y, type: herbivore, energy_point: 0, children: 0, subtype: chicken}, An_),
            Id_agent_ is Id_agent + 1,
            Id_object_ is Id_object,
            Sn_ = S
            );
        (Type = 'wolf' ->
            put_dict(Id_agent, A, agents{x: X, y: Y, type: carnivore, energy_point: 0, children: 0, subtype: wolf}, An_),
            Id_agent_ is Id_agent + 1,
            Id_object_ is Id_object,
            Sn_ = S
            ); 

        (Type = 'grass' ->
            put_dict(Id_object, S, object{x: X, y: Y, type: food, subtype: grass}, Sn_),
            Id_object_ is Id_object + 1,
            Id_agent_ is Id_agent,
            An_ = A
        );
        
        (Type = 'grain' ->
            put_dict(Id_object, S, object{x: X, y: Y, type: food, subtype: grain}, Sn_),
            Id_object_ is Id_object + 1,
            Id_agent_ is Id_agent,
            An_ = A
            );

        (Type = 'corn' ->
            put_dict(Id_object, S, object{x: X, y: Y, type: food, subtype: corn}, Sn_),
            Id_object_ is Id_object + 1,
            Id_agent_ is Id_agent,
            An_ = A
        )
    ),

    fill_map(L,[An_,Sn_],[An,Sn],Id_object_, Id_agent_, Na, No),!.

read_file(Objects,[X,Y]):-
    open('farm.txt', read, File),
    read_lines(File, Objects, -1,[X,Y]),
    close(File).

read_lines(File,[],_,_):-
    at_end_of_stream(File), !.

read_lines(File,L,-1,[Row,Col]):-
    read_line_to_string(File, String),
    split_string(String, '-', "", [C,R]),
    number_codes(Row, R),number_codes(Col, C),
    read_lines(File,L,0,[Row,Col+1]).

read_lines(File,[[A,B,Name]|L],Count,[Row,Col]):-
    Count =\= -1 ,
    \+ at_end_of_stream(File),
    get_char(File,C),
    object_props(Name,C,_),
    B is Count // Col + 1 , A is rem(Count, Col) + 1,
    read_lines(File,L,Count + 1,[Row,Col]).    

/**************************************************/

get_agent_from_position(X, Y, Agents, Agent) :-
    get_dict(_, Agents, Agent),
    get_dict(x, Agent, X), get_dict(y, Agent, Y),!.

get_agent_from_position_(X, Y, Agents, Agent) :-
    get_dict(_, Agents, Agent),
    get_dict(x, Agent, X), get_dict(y, Agent, Y).

get_multiple_agents_from_position(X, Y, Agents, AgentList) :-
    findall(Agent, get_agent_from_position_(X, Y, Agents, Agent), AgentList).

get_object_from_position(X, Y, Objects, Object) :-
    get_dict(_, Objects, Object),
    get_dict(x, Object, X), get_dict(y, Object, Y),!.

print_state(State) :-
    print_state(State, [1,1]).

print_state(State, [X,Y]):-
    State = [Agents, Objects],
    width(W), height(H),
    (
        (
            (get_agent_from_position(X, Y, Agents, Agent),
             get_object_from_position(X, Y, Objects, Object)) -> (get_dict(subtype, Agent, Sa), get_dict(subtype, Object, So), 
             object_props(Sa, A, _), object_props(So, O, _), write([A, O]));

             (get_multiple_agents_from_position(X, Y, Agents, [A1, A2|_])) -> (get_dict(subtype, A1, Sa), get_dict(subtype, A2, Sa_), 
             object_props(Sa, A1_ ,_), object_props(Sa_, A2_, _), write([A1_, A2_]));
            
            (
            (get_object_from_position(X, Y, Agents, Agent) -> (get_dict(subtype, Agent, S), object_props(S,A,_), write([A]))); 
            (get_object_from_position(X, Y, Objects, Object)) -> (get_dict(subtype, Object, S), object_props(S,O,_), write([O]));
             write(['.'])
            )
        )
    ),
    
    (
        (X<W-2 -> X1 is X+1, print_state(State, [X1,Y])); 
        (Y<H-2 -> Y1 is Y+1, nl, print_state(State, [1,Y1]));
        (!),nl,nl).
