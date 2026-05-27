# Server Side Swift Scheduler
**Tech Stack:** Swift, Mach APIs	
- Developed a cooperative user-space task scheduler in Swift using actor isolation, implementing priority-based scheduling, timed and interrupt-driven blocking, and runtime metrics via Mach system calls

## Features
- Cooperative user-space scheduling; voluntarily yields to control and all switching is explicit
- Priority based task selection and aware scheduling loop 
- Actor-isolated scheduler core (Swift Concurrency)
- Custom lightweight task model, abstraction with step tracking and lifecycle states
- Timed blocking (tasks automatically re-enter queue when ready)
- Interrupt-driven blocking and signalling, supports external interrupt events
- Simulated I/O and blocking primatives
- Runtime execution metric tracking using Mach APIs and CPU usage metrics
- PID-based task identification 
