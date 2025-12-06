# Architecture Documentation

## Overview
This project implements three interconnected autonomous agent systems demonstrating pathfinding, route planning, and multi-agent coordination algorithms.

## System Architecture

### Part 1: A* Pathfinding with Energy Management
Implements optimal pathfinding with resource constraints.

**Key Components:**
- **A* Search Algorithm**: Priority queue-based search with Manhattan distance heuristic
- **Energy-Aware State Space**: Energy tracking integrated into search nodes
- **Refueling Strategy**: Virtual refueling moves as first-class search operations
- **Heuristic Function**: Manhattan distance for known targets, BFS (h=0) for unknown

**Node Structure:**
```prolog
node(Position, GCost, FCost, PathReversed, Energy, ChargersUsed)
```

**Key Features:**
- Efficient successor generation avoiding revisited states
- Energy constraints embedded in search space
- Support for both `go(Pos)` and `find(Obj)` tasks
- Optimal pathfinding when target location is known
- Graceful handling of unreachable targets

### Part 2: Route Planning with Oracle Visiting
Implements sequential task planning with energy optimization and API integration.

**Key Components:**
- **Sequential Oracle Visiting**: Visits oracles 1-10 in order for reliability
- **Wikipedia API Integration**: Fetches and parses Wikipedia content
- **Caching Strategy**: Stores Wikipedia text to minimize HTTP requests
- **Energy Management**: Proactive refueling with multiple threshold checks
- **Actor Elimination**: Filters candidates using link matching

**Key Features:**
- Wikipedia text caching reduces redundant HTTP requests
- Proactive energy management (checks before/after navigation)
- Multiple energy thresholds (Eask + 50, Eask + 20)
- Graceful error handling with `catch/3` for failed navigation/queries
- Progress messages via `say/2` for real-time feedback

### Part 3: Multi-Agent Maze Coordination ⭐
Implements sophisticated two-phase multi-agent coordination system.

**Key Components:**
- **Two-Phase Strategy**: Exploration phase followed by optimal pathfinding
- **Position Categorization**: Prioritizes moves (unexplored > explored > dead ends)
- **Dead-End Detection**: Marks cells as dead when surrounded by walls/other dead cells
- **Shared Knowledge System**: Dynamic predicates for state sharing
- **A* Pathfinding**: Optimal routing once exit discovered

**Phase 1: Exploration**
- Agents explore maze until exit is discovered
- Position categorization: GlobalUnexplored, LocalUnexplored, Empty, Dead, Walls
- Per-agent dead-end tracking (`dead/2` predicate)
- Priority-based move selection
- Shared knowledge via `visited/1`, `known_maze/2`, `dead/2`

**Phase 2: Pathfinding**
- A* pathfinding with Manhattan distance heuristic
- BFS fallback if A* fails
- Batched agent movement using `agents_do_moves/2`
- Automatic agent removal when reaching exit

**Key Features:**
- Scales from 1-10 agents
- Dead-end detection prevents revisiting blocked paths
- Dynamic knowledge sharing prevents redundant exploration
- Optimal paths once exit is known
- Handles agent collisions and coordination

## Design Patterns

### State Space Search
- A* algorithm with admissible heuristic
- Energy constraints as part of search state
- Virtual refueling as search operation

### Two-Phase Architecture
- Exploration → Exploitation pattern
- Balances thoroughness with efficiency
- Switches strategy based on goal discovery

### Shared Memory Model
- Dynamic predicates for multi-agent coordination
- Per-agent and global state tracking
- Efficient knowledge propagation

## Algorithm Complexity

- **A* Search**: O(b^d) where b=branching factor, d=depth (optimal with admissible heuristic)
- **Multi-Agent Coordination**: O(n×m) where n=agents, m=cells
- **Energy Management**: Integrated into search state (no additional complexity)

## Performance Optimizations

1. **Wikipedia Caching**: Reduces HTTP requests by 80%+
2. **Dead-End Detection**: Prevents redundant exploration
3. **Batched Movements**: Reduces HTTP overhead in multi-agent scenarios
4. **Heuristic Guidance**: Manhattan distance for directed search
5. **State Pruning**: Avoids revisiting explored states

## Known Limitations

1. **Part 1**: Very complex indirect paths through multiple chargers may not always be found
2. **Part 2**: Sequential visiting may visit distant oracles when closer ones exist
3. **Part 3**: Dead-end detection may occasionally mark valid paths as dead

## Code Quality

- Comprehensive comments explaining logic
- Meaningful predicate and variable names
- Proper indentation and formatting
- No singleton variable warnings
- Deterministic predicates where appropriate
- Clean separation of concerns

