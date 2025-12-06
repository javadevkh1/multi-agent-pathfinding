%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% A* Search with Energy Management
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Main predicate: Accomplish a given Task and return the Cost
solve_task(Task, Cost) :-
    my_agent(A),
    get_agent_position(A, StartPos),
    get_agent_energy(A, StartEnergy),
    ailp_grid_size(N),
    Emax is ceiling(N*N/4),
    % Use A* search with energy tracking and refueling
    solve_task_astar(Task, StartPos, StartEnergy, Emax, Path),
    % Execute the path
    agent_do_moves(A, Path),
    length(Path, Cost).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% A* Search with Energy Management
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Node structure: node(Pos, GCost, FCost, PathReversed, Energy, ChargersUsed)
solve_task_astar(Task, StartPos, StartEnergy, Emax, Path) :-
    % Determine target position if possible (for better heuristic)
    (Task = go(TPos), ground(TPos) -> TargetHint = TPos ; TargetHint = unknown),
    % Initialize: node(Position, G-cost, F-cost, Path-reversed, Energy, Chargers-used)
    heuristic(StartPos, Task, TargetHint, H0),
    StartNode = node(StartPos, 0, H0, [], StartEnergy, []),
    % A* search
    astar([StartNode], Task, TargetHint, Emax, [], Path).

% A* search loop: found goal
astar([Node|_], Task, _, _, _, Path) :-
    Node = node(Pos, _, _, PathRev, _, _),
    achieved(Task, Pos),
    !,
    reverse(PathRev, Path).

% A* search loop: expand node
astar([Node|Agenda], Task, TargetHint, Emax, Visited, Path) :-
    Node = node(Pos, _, _, _, _, _),
    % Generate successors
    findall(
        Succ,
        generate_successor(Node, Task, TargetHint, Emax, Visited, Succ),
        Successors
    ),
    % Insert successors into agenda and continue
    insert_nodes(Successors, Agenda, NewAgenda),
    astar(NewAgenda, Task, TargetHint, Emax, [Pos|Visited], Path).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Successor Generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate successor by moving to adjacent empty cell
generate_successor(Node, Task, TargetHint, _Emax, Visited, Successor) :-
    Node = node(Pos, G, _, PathRev, Energy, ChargersUsed),
    Energy > 0,
    % Find adjacent empty cell
    map_adjacent(Pos, NextPos, empty),
    \+ member(NextPos, Visited),
    \+ member(NextPos, PathRev),
    % Calculate new costs
    NewEnergy is Energy - 1,
    G1 is G + 1,
    heuristic(NextPos, Task, TargetHint, H),
    F1 is G1 + H,
    Successor = node(NextPos, G1, F1, [NextPos|PathRev], NewEnergy, ChargersUsed).

% Generate successor by refueling at adjacent charger
generate_successor(Node, Task, TargetHint, Emax, _Visited, Successor) :-
    Node = node(Pos, G, _, PathRev, Energy, ChargersUsed),
    Energy < Emax,
    % Find adjacent charger we havent used yet
    map_adjacent(Pos, _ChargerPos, Charger),
    Charger = c(_),
    \+ member(Charger, ChargersUsed),
    % Refuel (no position change, no path change, but energy maxes out)
    heuristic(Pos, Task, TargetHint, H),
    F1 is G + H,
    Successor = node(Pos, G, F1, PathRev, Emax, [Charger|ChargersUsed]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Heuristic Function (Manhattan Distance)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For go(Pos) tasks where position is known
heuristic(CurrentPos, go(TargetPos), TargetPos, H) :-
    ground(TargetPos),
    !,
    map_distance(CurrentPos, TargetPos, H).

% For all other cases (unknown target or find tasks), use 0 (becomes BFS)
heuristic(_, _, _, 0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Goal Achievement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

achieved(find(Obj), Pos) :-
    map_adjacent(Pos, _, Obj), !.

achieved(go(TargetPos), Pos) :-
    Pos = TargetPos, !.

achieved(go(TargetPos), Pos) :-
    var(TargetPos),
    TargetPos = Pos, !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Agenda Management
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Insert nodes into agenda maintaining F-cost ordering
insert_nodes([], Agenda, Agenda).
insert_nodes([Node|Nodes], Agenda, Result) :-
    insert_node(Node, Agenda, Agenda1),
    insert_nodes(Nodes, Agenda1, Result).

% Insert single node in sorted position
insert_node(Node, [], [Node]) :- !.
insert_node(Node, [H|T], [Node,H|T]) :-
    Node = node(_, _, F1, _, _, _),
    H = node(_, _, F2, _, _, _),
    F1 =< F2,
    !.
insert_node(Node, [H|T], [H|Rest]) :-
    insert_node(Node, T, Rest).

