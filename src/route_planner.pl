%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Route Planning with Oracle Visiting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- dynamic actor_wikipedia_text/2.

% Main predicate
find_identity(ActorName) :-
    retractall(actor_wikipedia_text(_, _)),
    findall(A, actor(A), AllActors),
    my_agent(Agent),
    ailp_grid_size(N),
    Emax is ceiling(N*N/4),
    say('Starting identity search...', Agent),
    % Visit oracles 1-10 in order, refuel as needed
    visit_oracles_simple(1, AllActors, Agent, Emax, ActorName).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Simple Oracle Visiting Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Base case: tried all oracles
visit_oracles_simple(OracleNum, Actors, Agent, _Emax, ActorName) :-
    OracleNum > 10, !,
    length(Actors, Num),
    (Num =:= 1 ->
        Actors = [ActorName],
        atomic_list_concat(['Found: ', ActorName], Msg),
        say(Msg, Agent)
    ;
        ActorName = unknown,
        say('Could not determine identity', Agent)
    ).

% Base case: found the actor
visit_oracles_simple(_OracleNum, [Actor], Agent, _Emax, Actor) :- !,
    atomic_list_concat(['Found: ', Actor], Msg),
    say(Msg, Agent).

% Try to visit next oracle
visit_oracles_simple(OracleNum, Actors, Agent, Emax, ActorName) :-
    OID = o(OracleNum),
    length(Actors, NumActors),
    atomic_list_concat(['Oracle ', OracleNum, ', Candidates: ', NumActors], Msg),
    say(Msg, Agent),
    % Ensure we have enough energy
    get_agent_energy(Agent, Energy),
    Eask is ceiling(Emax/10),
    MinEnergy is Eask + 50,  % Need energy for query + navigation
    (Energy < MinEnergy ->
        say('Refueling...', Agent),
        (do_refuel(Agent, Emax) -> true ; true)
    ;
        true
    ),
    % Try to visit and query this oracle
    (visit_and_query(OID, Actors, Agent, Emax, NewActors) ->
        length(NewActors, NewNum),
        atomic_list_concat(['After query: ', NewNum, ' candidates'], Msg2),
        say(Msg2, Agent),
        NextNum is OracleNum + 1,
        visit_oracles_simple(NextNum, NewActors, Agent, Emax, ActorName)
    ;
        % Oracle failed, try next
        NextNum is OracleNum + 1,
        visit_oracles_simple(NextNum, Actors, Agent, Emax, ActorName)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Visit and Query Oracle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

visit_and_query(OID, Actors, Agent, Emax, FilteredActors) :-
    % Check if we have energy
    get_agent_energy(Agent, Energy1),
    Eask is ceiling(Emax/10),
    (Energy1 < Eask + 20 ->
        say('Low energy before navigation', Agent),
        do_refuel(Agent, Emax)
    ;
        true
    ),
    % Try to navigate to oracle
    say('Navigating to oracle...', Agent),
    catch(solve_task(find(OID), _Cost), _, fail),
    % Check energy after navigation
    get_agent_energy(Agent, Energy2),
    (Energy2 < Eask ->
        say('Low energy after navigation', Agent),
        do_refuel(Agent, Emax)
    ;
        true
    ),
    % Query oracle
    say('Querying oracle...', Agent),
    agent_ask_oracle(Agent, OID, link, Link),
    atomic_list_concat(['Got link: ', Link], Msg),
    say(Msg, Agent),
    % Filter actors
    include(actor_has_link(Link), Actors, FilteredActors),
    FilteredActors \= [].  % Must have at least one actor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Refueling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

do_refuel(Agent, _Emax) :-
    get_agent_position(Agent, Pos),
    % Try adjacent charger first
    (map_adjacent(Pos, _, Charger), Charger = c(_) ->
        say('Refueling at adjacent charger', Agent),
        agent_topup_energy(Agent, Charger),
        say('Refueled!', Agent)
    ;
        % Try to find any charger
        say('Searching for charger...', Agent),
        catch(
            (
                solve_task(find(c(_)), _),
                get_agent_position(Agent, NewPos),
                map_adjacent(NewPos, _, FoundCharger),
                FoundCharger = c(_),
                agent_topup_energy(Agent, FoundCharger),
                say('Refueled!', Agent)
            ),
            _,
            fail
        )
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Actor Link Checking with Caching
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

actor_has_link(L, A) :-
    % Check cache first
    (actor_wikipedia_text(A, WT) ->
        wt_link(WT, L)
    ;
        % Download and cache
        actor(A),
        catch(
            (
                wp(A, WT),
                assertz(actor_wikipedia_text(A, WT)),
                wt_link(WT, L)
            ),
            _,
            fail
        )
    ).

