% Test queries for the farm project
:- ['main.pro'].

test_state :-
    state(Agents, Objects),
    write('State loaded successfully'), nl,
    write('Agents: '), write(Agents), nl,
    write('Objects: '), write(Objects), nl.

% Test agents_distance
test_agents_distance_01 :-
    state(Agents, _),
    agents_distance(Agents.0, Agents.1, Distance),
    write('Distance between Agent 0 and Agent 1: '), write(Distance), nl.

test_agents_distance_12 :-
    state(Agents, _),
    agents_distance(Agents.1, Agents.2, Distance),
    write('Distance between Agent 1 and Agent 2: '), write(Distance), nl.

% Test number_of_agents
test_number_of_agents :-
    state(Agents, Objects),
    number_of_agents([Agents, Objects], NumberOfAgents),
    write('Number of agents: '), write(NumberOfAgents), nl.

% Test value_of_farm
test_value_of_farm :-
    state(Agents, Objects),
    value_of_farm([Agents, Objects], Value),
    write('Value of farm: '), write(Value), nl.

% Test find_food_coordinates
test_find_food_coordinates_0 :-
    state(Agents, Objects),
    (find_food_coordinates([Agents, Objects], 0, Coordinates) ->
        (write('Food coordinates for agent 0: '), write(Coordinates), nl);
        (write('No food found for agent 0'), nl)).

test_find_food_coordinates_2 :-
    state(Agents, Objects),
    (find_food_coordinates([Agents, Objects], 2, Coordinates) ->
        (write('Food coordinates for agent 2: '), write(Coordinates), nl);
        (write('No food found for agent 2'), nl)).

test_find_food_coordinates_4 :-
    state(Agents, Objects),
    (find_food_coordinates([Agents, Objects], 4, Coordinates) ->
        (write('Food coordinates for agent 4: '), write(Coordinates), nl);
        (write('No food found for agent 4 (expected: false)'), nl)).

% Test find_nearest_agent
test_find_nearest_agent_0 :-
    state(Agents, Objects),
    find_nearest_agent([Agents, Objects], 0, Coordinates, NearestAgent),
    write('Nearest agent to agent 0 - Coordinates: '), write(Coordinates), nl,
    write('NearestAgent: '), write(NearestAgent), nl.

test_find_nearest_agent_3 :-
    state(Agents, Objects),
    find_nearest_agent([Agents, Objects], 3, Coordinates, NearestAgent),
    write('Nearest agent to agent 3 - Coordinates: '), write(Coordinates), nl,
    write('NearestAgent: '), write(NearestAgent), nl.

% Test find_nearest_food
test_find_nearest_food_1 :-
    state(Agents, Objects),
    find_nearest_food([Agents, Objects], 1, Coordinates, FoodType, Distance),
    write('Nearest food to agent 1 - Coordinates: '), write(Coordinates), nl,
    write('FoodType: '), write(FoodType), nl,
    write('Distance: '), write(Distance), nl.

% Test move_to_coordinate
test_move_to_coordinate_1 :-
    state(Agents, Objects),
    (move_to_coordinate([Agents, Objects], 1, 1, 5, ActionList, 4) ->
        (write('Move agent 1 to (1,5) - ActionList: '), write(ActionList), nl);
        (write('Failed to move agent 1 to (1,5)'), nl)).

test_move_to_coordinate_3 :-
    state(Agents, Objects),
    (move_to_coordinate([Agents, Objects], 3, 10, 5, ActionList, 7) ->
        (write('Move agent 3 to (10,5) - ActionList: '), write(ActionList), nl);
        (write('Failed to move agent 3 to (10,5)'), nl)).

test_move_to_coordinate_2_fail :-
    state(Agents, Objects),
    (move_to_coordinate([Agents, Objects], 2, 10, 6, ActionList, 4) ->
        (write('Move agent 2 to (10,6) - ActionList: '), write(ActionList), nl);
        (write('Failed to move agent 2 to (10,6) (expected: false)'), nl)).

% Test move_to_nearest_food
test_move_to_nearest_food_1 :-
    state(Agents, Objects),
    (move_to_nearest_food([Agents, Objects], 1, ActionList, 3) ->
        (write('Move agent 1 to nearest food - ActionList: '), write(ActionList), nl);
        (write('Failed to move agent 1 to nearest food'), nl)).

test_move_to_nearest_food_0_fail :-
    state(Agents, Objects),
    (move_to_nearest_food([Agents, Objects], 0, ActionList, 4) ->
        (write('Move agent 0 to nearest food - ActionList: '), write(ActionList), nl);
        (write('Failed to move agent 0 to nearest food (expected: false)'), nl)).

% Test consume_all
test_consume_all_1 :-
    state(Agents, Objects),
    (consume_all([Agents, Objects], 1, NumberOfMovements, Value, NumberOfChildren, 10) ->
        (write('Consume all for agent 1:'), nl,
         write('NumberOfMovements: '), write(NumberOfMovements), nl,
         write('Value: '), write(Value), nl,
         write('NumberOfChildren: '), write(NumberOfChildren), nl);
        (write('Failed to consume all for agent 1'), nl)).

test_consume_all_0 :-
    state(Agents, Objects),
    (consume_all([Agents, Objects], 0, NumberOfMovements, Value, NumberOfChildren, 8) ->
        (write('Consume all for agent 0:'), nl,
         write('NumberOfMovements: '), write(NumberOfMovements), nl,
         write('Value: '), write(Value), nl,
         write('NumberOfChildren: '), write(NumberOfChildren), nl);
        (write('Failed to consume all for agent 0'), nl)).

run_tests :-
    write('=== Running All Tests ==='), nl,
    test_state,
    nl,
    write('--- Testing agents_distance ---'), nl,
    test_agents_distance_01,
    test_agents_distance_12,
    nl,
    write('--- Testing number_of_agents ---'), nl,
    test_number_of_agents,
    nl,
    write('--- Testing value_of_farm ---'), nl,
    test_value_of_farm,
    nl,
    write('--- Testing find_food_coordinates ---'), nl,
    test_find_food_coordinates_0,
    test_find_food_coordinates_2,
    test_find_food_coordinates_4,
    nl,
    write('--- Testing find_nearest_agent ---'), nl,
    test_find_nearest_agent_0,
    test_find_nearest_agent_3,
    nl,
    write('--- Testing find_nearest_food ---'), nl,
    test_find_nearest_food_1,
    nl,
    write('--- Testing move_to_coordinate ---'), nl,
    test_move_to_coordinate_1,
    test_move_to_coordinate_3,
    test_move_to_coordinate_2_fail,
    nl,
    write('--- Testing move_to_nearest_food ---'), nl,
    test_move_to_nearest_food_1,
    test_move_to_nearest_food_0_fail,
    nl,
    write('--- Testing consume_all ---'), nl,
    test_consume_all_1,
    test_consume_all_0,
    nl,
    write('=== All Tests Completed ==='), nl.
