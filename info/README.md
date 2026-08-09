# Course Information

## Instructor
Erik Pihl ([erik.axel.pihl@gmail.com](mailto:erik.axel.pihl@gmail.com))

---

## Prerequisites
The subject of this course is **VHDL**, not digital design. Participants are expected to arrive
already comfortable with:
* Logic gates and truth tables, and reading a sum-of-products equation off a table.
* Boolean algebra: the basic identities and De Morgan's laws.
* Karnaugh maps, for functions of three or four variables.
* Registers, D flip-flops, and what a clock edge does.
* State machines as a concept: states, transitions, and the difference between Moore and Mealy.

None of that is taught from scratch. It is refreshed where the language needs it, briefly, and
mostly in the appendices: L01 restates gate and Boolean notation so the course has one convention,
L02 works a Karnaugh map end to end in the lecture because minimization is what motivates the VHDL
that follows, and L08 designs one state machine by hand before writing it, because seeing the state
table become a `case` statement is the point of the lecture.

What the course does teach from nothing is the language and the toolchain: `entity` and
`architecture`, signals and variables, processes, generics, subcomponents, synthesis in Quartus,
and simulation with GHDL.

No programming language beyond general software fluency is assumed. Familiarity with C or a
similar language helps, since several explanations contrast VHDL's semantics with it.

---

# Course Plan - Digital Design with VHDL

| Week | Lecture | Topic |
|------|---------|------|
| 1 | L01 | Combinational logic and first VHDL |
| 3 | L02 | Larger networks, multiplexers and submodules |
| 5 | L03 | Sequential logic |
| 7 | L04 | Metastability and synchronization |
| 9 | L05 | Variables and the hardware underneath |
| 11 | L06 | Counters and shift registers |
| 13 | L07 | Timers |
| 15 | L08 | State machines |

---

## Lecture Content

### L01 - Combinational Logic and First VHDL
From a truth table to a working gate network, in CircuitVerse and in VHDL.

Topics include:
* Logic gates and truth tables
* Boolean algebra and sum-of-products
* Building and simulating gate networks in CircuitVerse
* `entity`, `architecture`, `std_logic`, and the concurrent signal assignment
* One complete module, the braking assistant, taken through Quartus onto the DE0-CV

---

### L02 - Larger Networks, Multiplexers and Submodules
Minimizing a network, the first constructs that need a process, and the first design built from
more than one entity.

Topics include:
* `process` and `case`, introduced on a live 4-to-1 multiplexer
* `std_logic_vector`: bundling wires, indexing and slicing
* Multiplexers, from 2-to-1 to 8-to-1
* Karnaugh maps, worked end to end
* Translating a minimized network into VHDL, with internal signals
* Submodules: `entity work.<name>`, positional `port map`, and slicing a wide port
* A two-digit hexadecimal 7-segment display in VHDL, with one digit optionally realized as a gate
  network by hand
* Running self-checking testbenches with GHDL

---

### L03 - Sequential Logic
Storing state: registers, D flip-flops, and clocking.

Topics include:
* The D latch and the D flip-flop
* Registers built from flip-flops
* Clocking: rising/falling edge, clock period
* Edge detection

---

### L04 - Metastability and Synchronization
Making an asynchronous input safe to use in a synchronous system.

Topics include:
* Why asynchronous inputs cause metastability
* The double-flop synchronizer
* Debouncing a push button
* Timing intuition: setup/hold, and why "double flop" is enough
* Generics: one module serving several sizes

---

### L05 - Variables and the Hardware Underneath
The one construct left, and what the toolchain does with all of it.

Topics include:
* `signal` versus `variable`, and the XOR parity generator that tells them apart
* What an FPGA is physically made of: look-up tables and flip-flops
* The critical path, Fmax, and what puts a speed limit on a clock
* The latch you infer by accident, and why it is only a warning

---

### L06 - Counters and Shift Registers
Building blocks for anything that needs to count or move bits.

Topics include:
* Counters, and wraparound as a consequence of bit width
* Shift registers (serial-in/parallel-out, parallel-in/serial-out)
* An 8-bit serial receiver: a shift register plus a bit counter

---

### L07 - Timers
A counter with a target count, drawn by hand before it is written.

Topics include:
* Timers, built from counters
* Building one as a gate network in CircuitVerse, and watching it tick
* The `timer` module in VHDL, and its `TICK_COUNT` generic
* Composing a timer and two synchronizers: the walking LED on the DE0-CV

---

### L08 - State Machines
Designed by hand first, then expressed in the language.

Topics include:
* States, transitions, inputs and outputs
* State diagrams, state tables, and Karnaugh-derived logic
* Realizing the machine as a gate network in CircuitVerse
* Enumerated state types and the `case` transition pattern
* Moore machines throughout; Mealy covered briefly, in VHDL only
* FPGA demonstration
* The two course capstones, completed as self-study after the final lecture: an 8-bit serial
  receiver and transmitter, each composed from modules written in earlier lectures around a state
  machine the participant designs. Budget roughly 10 to 15 hours for the pair

---

## Course Material

### Literature
The course material consists of:
* Lecture notes
* VHDL and CircuitVerse examples
* Exercises completed after the lectures
* A self-checking testbench for every worked example and for nearly every VHDL exercise, so nearly
  every exercise can be verified on a laptop; the handful that ship none say so, and say how to
  check by hand instead. Participants run these; writing them is the follow-on CAN Controller
  Design course's subject

---

### Software

**What each participant needs**, on an ordinary laptop, with no hardware of any kind:
* **[CircuitVerse](https://circuitverse.org/simulator)** - Free, browser-based logic simulator used
  to build and simulate every circuit by hand before it's written in VHDL. Nothing to install
* **[GHDL](https://github.com/ghdl/ghdl)** - Free, open-source VHDL analyzer and simulator, used to
  run the self-checking testbenches that verify the exercises:
  * on WSL/Ubuntu, `sudo apt -y install ghdl`
  * running testbenches is covered in
    [L02 Appendix C](../lectures/L02/appendix/c_testbenches.md)

**What the instructor needs**, for the demonstrations given from the front:
* **[Quartus Prime Lite](https://www.intel.com/content/www/us/en/software-kit/711791/intel-quartus-prime-lite-edition-design-software-version-20-1-for-windows.html)** - Intel/Altera's free FPGA design tool, used to synthesize VHDL and program the FPGA board
* **Cyclone V Device Support** - Add-on package for Quartus Prime Lite, required for the DE0-CV
  board's FPGA
* A **Terasic DE0-CV FPGA board** (device `5CEBA4F23C7N`) - The target hardware for the worked
  examples that end on hardware

No exercise in this course requires Quartus, an FPGA board, or any hardware. Installing and
configuring Quartus, and the DE0-CV workflow itself (new project → pin assignment → compile →
program the board), are written up in [quartus_workflow.md](./quartus_workflow.md), which is
instructor-facing for the same reason.

---
