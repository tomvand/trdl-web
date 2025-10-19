# Design

## SOL Solution

### REQ-SOL Requirements

1. The full game shall run in the browser (desktop and mobile).
2. The railway interlocking logic shall be able to run on a microcontroller. Rationale: to allow reuse for model railways.
3. The train simulation logic should be able to run on a microcontroller. Rationale: playable handheld hardware.
4. The train simulation logic shall be a replaceable module. Rationale: to support simulation and model railways.
5. The game shall support multiple screens.
6. The game shall support touch controls.
7. The game shall visually fit on a tablet. The game may fit on a phone.

Coverage table:

### DSN-SOL Design choices

1. The solution shall consist of the following systems:
  - Launcher. This system is responsible for starting and initializing all other systems.
  - Frontend. This system performs in-browser rendering and UI functions.
  - Train simulation. This system simulates the movement of trains and trackside elements.
  - Interlocking. This system simulates all interlocking logic.
  - Configuration. There shall be one shared configuration file for all systems. Rationale: these systems are tightly linked.
  - Timetable. This is used by both the train simulation and interlocking (ARS).
2. The following modules for train simulation shall be available:
  - Full simulation. To make the game playable on any device.
  - ~~Koploper integration. To make the game interact with a model railway without having to do full control.~~ (Future version?)
  - ~~Full model railway control.~~ (Future version?)
3. Elements shall be designed down to a level where they can be implemented in 1 or 2 days max.

About the programming language. This cannot be chosen freely because of the platform requirements. There is a tradeoff between choosing the best language for each platform, or choosing a single language for all platforms. My familiarity with languages is also something to take into account. Performance is not really relevant given the slow required update rate (1Hz is sufficient for simulation, 10Hz is more than enough). So ease of development may be the major factor in this decision.

The languages C, C++, Rust and Lua can be used on all platforms, although I'm not 100% sure on the status of lua in the browser. Of these languages, Lua is high-level while C, C++ and Rust are more low-level in comparison. C++ and Rust support most high-level concepts, in C this is more difficult or verbose.

For Lua, I could not find commonly-used runtimes (though they exist, given the number of web consoles), but there also seems to be some Lua-to-Javascript transpilers. The advantages of Lua are obvious, the downside is that I would need two different toolchains, perhaps even three if I want to test natively on my dev setup.

According to ChatGPT, Fengari is a mature and accepted interpreter for Lua 5.3 in the browser. Wasmoon is a Lua 5.4 interpreter in WASM, though with less JS interop (which I do not expect to be a problem, as the interop can be kept simple). Transpilers do not seem to have the desired maturity. Emscripten-based interpreters are available but I can't judge the maturity and JS interop seems to be clumsy. Based on these considerations, Lua 5.3 seems to be a realistic option using Fengari or Wasmoon.

I personally find C++ difficult to use because it has too many features, which makes it difficult to write idiomatic code. I would be more comfortable writing C-like C++, but I'm not sure if that is a good idea. I have professional experience in C and feel a lot more comfortable there than in C++, but the memory management is even more sensitive to errors. Because of the availability of Lua and Rust, I will not use C or C++.

I have no experience in Rust. It seems to have all the features I want, from a unified toolchain to memory safety to reasonably high-level mechanisms. But the learning curve will be pretty steep since I have 0 prior experience. Because of the importance of development time, and the low performance requirements, I will use Lua in favor of Rust.

4. Systems that run on all platforms (browser, microcontroller) shall be written in: Lua
5. Systems that run only in the browser shall be written in: Lua (+JS glue code)
6. Systems that run only on the microcontroller shall be written in: Lua (+ C or C++ glue code, TBD)

TODO: editor?
TODO: GSM-R / Telerail?
TODO: defects and repairs?

Coverage table:

### INT-SOL Integration

- The following interactions take place between the launcher and configuration:
  1. The launcher instructs the configuration on the configuration file to load.
  2. The launcher manages the lifetime of the configuration.
- The following interactions take place between the launcher and timetable:
  1. The launcher instructs the timetable on the timetable file to load.
  2. The launcher instructs the timetable on the saved state to load.
  3. The launcher commands the timetable to save its state.
  4. The launcher manages the lifetime of the timetable.
- The following interactions take place between the launcher and frontend:
  1. The launcher connects the frontend to the other systems.
  2. The launcher commands the frontend to initialize.
  3. The launcher manages the lifetime of the frontend.
- The following interactions take place between the launcher and train simulation:
  1. The launcher connects the train simulation to the other systems.
  2. The launcher instructs the train simulation about the saved state, if available.
  3. The launcher commands the train simulation to initialize.
  4. The launcher commands the train simulation to save its state.
  5. The launcher manages the lifetime of the train simulation.
- The following interactions take place between the launcher and interlocking:
  1. The launcher connects the interlocking to the other systems.
  2. The launcher instructs the interlocking about the saved state, if available.
  3. The launcher commands the interlocking to initialize.
  4. The launcher commands the interlocking to save its state.
  5. The launcher manages the lifetime of the interlocking.

- The following interactions take place between the frontend and train simulation:
  1. The frontend can query train details (consist, timetable, shunting instructions, state).
  2. The frontend can change the timetable and shunting instructions of trains.
- The following interactions take place between the frontend and interlocking:
  1. The interlocking reports the state of interlocking elements to the frontend.
    - Track sections
    - Switches
    - Signals
    - Other controls: locks, ground frames, signal lighting, point heating, ...
  2. The frontend can send commands to the interlocking.
- The following interactions take place between the train simulation and interlocking:
  1. The train simulation sends track occupancy events to the interlocking.
  2. The interlocking sets the state of switches and signals.

TODO: does frontend command routes or individual switches and signals?

Coverage table:

---

### REQ-CONF

1. It should be possible to generate most of the configuration file automatically from ProRail GIS data.

Coverage table:
