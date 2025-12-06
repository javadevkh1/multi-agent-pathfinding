# Autonomous Agent Pathfinding System

A multi-agent pathfinding and coordination system implementing A* search, energy-aware route planning, Wikipedia API integration and distributed exploration algorithms.

## 🎯 Project Overview

This project implements three interconnected autonomous agent systems:

1. **A* Pathfinding with Energy Constraints** - Optimal pathfinding with resource management
2. **Intelligent Route Planning** - Multi-objective planning with API integration  
3. **Multi-Agent Maze Coordination** - Distributed exploration with shared knowledge

## 🚀 Key Features

### Part 1: A* Pathfinding
- **A* search algorithm** with Manhattan distance heuristic
- **Energy-aware pathfinding** with integrated refueling
- **Optimal pathfinding** for known targets, BFS fallback for unknown
- **Constraint handling** for obstacles and resource limits

### Part 2: Route Planning
- **Sequential task planning** with energy optimization
- **Wikipedia API integration** for data gathering
- **Caching strategy** to minimize HTTP requests
- **Error handling** for network and navigation failures

### Part 3: Multi-Agent Coordination ⭐
- **Two-phase strategy**: Exploration → Optimal pathfinding
- **Dead-end detection** to prevent redundant exploration
- **Shared knowledge system** via dynamic predicates
- **Scalable coordination** for 1-10 agents
- **A* pathfinding** once exit discovered

## 🛠️ Technologies

- **Prolog** (SWI-Prolog) - Logic programming for AI algorithms
- **HTTP/API Integration** - Wikipedia data retrieval
- **Web-based Visualization** - GridWorld browser interface

## 📊 Technical Highlights

### Algorithm Complexity
- A* search: O(b^d) with optimal heuristic
- Multi-agent coordination: O(n×m) where n=agents, m=cells
- Energy management: Integrated into search state

### Design Patterns
- **Two-phase architecture** (exploration → exploitation)
- **State space search** with constraint propagation
- **Shared memory model** for multi-agent coordination

## 🎓 Learning Outcomes

This project demonstrates:
- Implementation of classic AI algorithms (A*)
- Multi-agent system design
- Constraint satisfaction problem solving
- API integration and caching strategies
- Logic programming in Prolog

## 📁 Project Structure

```
├── src/
│   ├── pathfinding.pl              # A* implementation
│   ├── route_planner.pl            # Oracle visiting system
│   └── multi_agent_coordinator.pl  # Multi-agent maze solver
├── lib/
│   └── ailp/                       # GridWorld library
├── docs/
│   ├── ARCHITECTURE.md             # Technical documentation
│   └── TESTING.md                  # Test results
└── README.md                       # This file
```

## 🚀 Quick Start

### Prerequisites
- SWI-Prolog 8.4.3-1 or compatible
- Modern web browser
- Internet connection (for Part 2)

### Running the System

**Portfolio Mode** (uses `src/` files):
```bash
# From project root directory
# Note: "cw" is the command argument identifier used by the loader
swipl lib/ailp.pl -- cw part1    # Part 1: Pathfinding
swipl lib/ailp.pl -- cw part2    # Part 2: Route Planning
swipl lib/ailp.pl -- cw part3    # Part 3: Multi-Agent
```

Then in Prolog:
```prolog
% Part 1: Pathfinding
?- start, shell, setup, go(p(10,10)).

% Part 2: Route Planning  
?- start, shell, setup, identity.

% Part 3: Multi-Agent
?- start, join_game(As, 4), reset_game, start_game, solve_maze.
```

**Note**: The loader automatically detects and uses files from `src/` folder for portfolio use, or falls back to `cw_*.pl` files if present (academic submission format).

## 📈 Results

- **Part 1**: Optimal paths with 100% success rate
- **Part 2**: 70-90% actor identification success
- **Part 3**: Handles 1-10 agents with coordinated exploration

## 💡 Key Innovations

1. **Energy-integrated A***: Refueling as first-class search operation
2. **Two-phase multi-agent strategy**: Balances exploration vs exploitation
3. **Dead-end detection**: Prevents redundant exploration in mazes
4. **Wikipedia caching**: Reduces API calls by 80%+

## 🔧 Challenges Solved

1. **Energy Constraint Integration**: Embedding resource limits into A* search
2. **Multi-Agent Deadlock Prevention**: Ensuring agents don't block each other
3. **Unknown Environment Exploration**: Efficient exploration of hidden mazes
4. **API Rate Limiting**: Caching strategy for Wikipedia requests

## 📚 Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Detailed technical documentation
- **[TESTING.md](docs/TESTING.md)** - Test results and benchmarks

## 🎬 Demo

The system includes a web-based visualization that shows:
- Agent navigation with A* pathfinding
- Multi-agent exploration and coordination
- Route planning with energy management

## 🏆 Highlights

- **Sophisticated Multi-Agent Coordination**: Two-phase strategy with dead-end detection
- **Optimal Pathfinding**: A* algorithm with energy constraints
- **Real-World Integration**: Wikipedia API with intelligent caching
- **Scalable Design**: Handles 1-10 agents efficiently

---

**Note**: This was developed as part of an AI coursework project, demonstrating practical implementation of search algorithms and multi-agent systems.
