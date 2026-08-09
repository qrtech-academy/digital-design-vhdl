# Digital Design with VHDL
Repository for the course **Digital Design with VHDL**.

This course consists of eight lectures and is intended for software/embedded engineers who know
classical digital design and want to write VHDL. It takes you from a gate network on paper to a
design running on a real FPGA (a *field-programmable gate array*: a chip full of logic you
configure into the circuit you want, rather than one whose function was fixed when it was
manufactured).

**The subject is VHDL.** Gates, truth tables, Boolean algebra and Karnaugh maps are refreshed
rather than taught: they appear where the language needs them, and in L08 where the state machine
is designed by hand before it is written. See [Prerequisites](./info/README.md#prerequisites) for
what that assumes.

---

## About the Course
The course covers writing synthesizable VHDL for combinational and sequential hardware:
metastability and synchronization, counters, timers and finite state machines, each reasoned about
as a circuit first and then expressed in the language, running on a real FPGA.

Topics include:
* Combinational logic: gates, truth tables, Boolean algebra, and VHDL from the first lecture.
* Larger networks: Karnaugh maps, multiplexers, `process` and `case`.
* Sequential logic: registers, D flip-flops, clocking, and edge detection.
* Metastability and synchronization: asynchronous inputs, synchronizers, debouncing.
* The VHDL language: signals, variables, subcomponents, and generics.
* Counters, shift registers, and timers.
* Finite state machines: designed by hand, then written in VHDL, Moore and Mealy.

Wherever a circuit can usefully be drawn, it is drawn first: reasoned about as gates, then built
and simulated by hand in [CircuitVerse](https://circuitverse.org/simulator) before it's ever
written in VHDL. Every lecture that introduces a new kind of circuit draws one that way first. The
exception is L05, which is a language lecture with no new circuit in it; and once a kind of circuit
has been drawn, later designs of the same kind go straight into VHDL.

Verification works in three layers:
* **By hand, in CircuitVerse**, before any VHDL exists. You derive what the circuit should do, build
  it, and then simulate it yourself against that prediction - exhaustively, since the circuits are
  small enough for that to be cheap. Nothing automated checks this step, deliberately: predicting a
  behaviour and then confirming it is the skill the rest of the course is built on.
* **In the exercises**, you write the VHDL and check it with a provided self-checking testbench
  (`<module>_tb.vhd`, runnable with GHDL). Nearly every VHDL exercise ships one, so nearly every
  exercise can be completed and verified on a laptop; the handful that don't say so, and say how to
  check by hand instead.
* **In the lecture**, designs are synthesized in Quartus Prime Lite and run on a real Terasic
  DE0-CV board, demonstrated from the front. No participant needs a board of their own.

**Writing** testbenches is not a topic here - it's taught in the follow-on CAN Controller Design
course. This course only shows you how to run the ones provided. This course ends where
[CAN Controller Design](https://github.com/qrtech-academy/can-controller-design), a separate
follow-on course, begins.

---

## During the Course
During the lectures participants will:
* Realize a logic function by hand as a gate network, and simulate it in CircuitVerse.
* Translate that same gate network into synthesizable VHDL.
* Build sequential circuits from D flip-flops: registers, counters, shift registers, and timers.
* Guard every asynchronous input with a double-flop synchronizer before it reaches synchronous
  logic.
* Design a Moore state machine by hand - diagram, table, Karnaugh maps, gate network - then write
  the same kind of machine in VHDL, and learn to recognize a Mealy machine and what it costs.
* Follow each design through Quartus Prime Lite and onto a Terasic DE0-CV FPGA board, demonstrated
  live during the lecture.
* Verify their own VHDL after each lecture by running the provided self-checking testbenches.

Examples and exercises are small, complete circuits, such as:
* A gate network realizing a Boolean function, in CircuitVerse and in VHDL.
* A synchronized, edge-detected push button driving an LED.
* A free-running timer and a shift-register-driven LED pattern.
* A three-state Moore machine cycling an LED off/blinking/on, composed from a synchronizer and a
  timer.
* A two-state Mealy sequence detector, contrasted against the Moore machine it would take three
  states to write.

The course then closes on two exercises that are not small: a serial receiver and a serial
transmitter, each composed from modules you wrote in earlier lectures around a state machine you design
yourself, and each verified by a provided testbench.

---

## Learning Outcomes
After completing the course, participants should be able to:
* Realize a Boolean function as a gate network, and simulate it by hand in CircuitVerse.
* Read and write combinational and sequential VHDL: entities, architectures, signals, variables,
  and processes.
* Explain metastability and apply the double-flop synchronizer to any asynchronous input.
* Design and implement counters, shift registers, and timers in VHDL.
* Design a Moore state machine from a specification and implement it in VHDL, and recognize a Mealy
  machine on sight, knowing what its earlier output costs.
* Compose a design out of previously built modules - a reset synchronizer, a button synchronizer, a
  timer - rather than rewriting their logic.
* Explain how a VHDL design reaches an FPGA: synthesis, pin assignment, and programming the board
  in Quartus Prime Lite.
* Verify a VHDL design by running a self-checking testbench under GHDL.

---

## Written Examinations
Nothing in this course is marked. Assessment is the exercises after every lecture, the self-checking
testbench nearly every one of them ships, and the circuit you predict and then simulate by hand in
CircuitVerse before any VHDL exists - the first two of the three layers described above, each of
which checks a module you wrote or a behaviour you predicted beside it.

[`exam/`](./exam/README.md) holds two three-hour papers with worked solutions, and they check
something else: **your own skills and knowledge, on paper, with nothing in front of you.** Eight
questions each, one per lecture, mixing theory with VHDL you write out by hand and with designs that
compile cleanly and are wrong anyway.

**They are there for you to test yourself with after the course, and nothing more.** They gate
nothing, they are not a qualification, and no part of the course requires them. No design is built
from them and `make build` does not know they exist.

**Take one once the course is over**, after L08 and the two capstones. Both papers draw on all eight
lectures, so sitting one partway through examines material nobody has taught you yet, and the result
says more about how far you have read than about what you have understood.

---

## Structure

```text
Makefile     Entry point for the checks below; run `make help` for the target list.
ci/          Check scripts: GHDL build, vendored-copy drift, Markdown links, VHDL whitespace.
info/        Course info: prerequisites, instructor, course plan, per-lecture topic breakdown.
lectures/    Per lecture: README, appendix/, exercises/, and (in all but L07) a worked example;
             solutions/ appears as each lecture is delivered.
exam/        Two written papers and their solutions. Optional, and marked by nobody here.
diagrams/    Python sources for the generated figures, and the exercise entity definitions.
```

---

## Building
The root Makefile drives GHDL over the repo. A reference example whose subcomponents are all present
is analyzed, elaborated, and its testbench is run. Exercise directories ship only the testbench, not
the module you are asked to write and not the modules it reuses, which are ones you wrote in earlier
lectures and copy in yourself, so there is no top-level entity to elaborate. Those testbenches are
instead analyzed against a stub entity generated from `diagrams/exercises.py`, which checks the port
order, widths and types of a file we hand out without needing a solution to bind it to. The three
worked examples that themselves compose modules you write - `led_toggle_sync`, `fsm_led` and
`seq_detect_mealy` - are analyzed against those same stubs, which type-checks them but cannot
elaborate or simulate them.

That check cannot catch a wrong expected value in a testbench, only a wrong interface. So as each
lecture's solutions are published into its own `solutions/` directory, one `.vhd` per module, the
shipped testbench is elaborated and run against the real body instead, and so is any worked example
that composes it. No configuration: dropping in `blinker.vhd`, `reset_sync.vhd` and `timer.vhd` is
what makes `blinker`'s testbench start running, because those are the three modules it needs.
Anything not yet published keeps the stub check, and the line the build prints says which check each
exercise got.

```bash
make help                # List every target.
make build               # Build and simulate every example; check every exercise testbench.
make build MODULE=timer  # Build only the examples whose path contains "timer".
make lint                # Vendored copies identical, Markdown links resolve, no trailing whitespace.
make clean               # Remove GHDL work libraries and other generated files.
```

`ghdl`, `make` and `git` need to be installed and on PATH. On WSL/Ubuntu:

```bash
sudo apt -y update
sudo apt -y install git make ghdl
ghdl --version           # 3.x or newer; CI builds against 4.1.0
```

`python3` is optional. With it, exercise testbenches are checked against their entity, and run
against any published body, as described above; without it, they fall back to a syntax check.

---
