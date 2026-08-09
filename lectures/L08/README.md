# L08 - State Machines

## Agenda
* Finite state machines: states, transitions, inputs and outputs.
* Hand-designing a Moore machine: state diagram, state table, Karnaugh-derived logic.
* State encoding as a design decision, and why the worked machine uses a Gray code.
* The same machine in VHDL: an enumerated type and the `case` transition pattern.
* Why Moore is the default here and in the follow-on CAN course.
* `fsm_led` demonstrated on the DE0-CV: buttons cycling the LED off, blinking, on.
* Self-study: Mealy machines (A.5), and `seq_detect_mealy` to read and run.

---

## Lecture plan
Built live, in this order:
1. **A Moore machine designed by hand.** Specification, state diagram, state table, then
   Karnaugh-derived next-state and output logic. No step skipped.
2. **The resulting gate network, in CircuitVerse.** Stepped through its state cycle by hand. At
   each step, predict the next state from the diagram before the clock is advanced.
3. **The same kind of machine in VHDL.** `fsm_led`, A.4's three-state LED controller: an enumerated
   `state_t` type and a `case`-statement process, replacing the state table and the Karnaugh maps
   entirely. A different, larger machine than step 1's, deliberately, so the correspondence you are
   watching is structural rather than a transcription.
4. **`fsm_led` onto the board.**

Step 3 is the payoff of step 1: every row you derived by hand in the state table becomes one branch
of a `case`, and seeing that correspondence is worth more than either step on its own.

[`fsm_led`](./fsm_led/fsm_led.vhd) is the machine steps 3 and 4 write and demonstrate: a
three-state LED controller composed from L04's synchronizer and L07's timer, written up in
[A.4](./appendix/a_state_machines.md#a4-the-same-machine-in-vhdl).

Mealy machines are read rather than presented, covered in
[A.5](./appendix/a_state_machines.md#a5-mealy-machines-the-one-cycle-difference) with
[`seq_detect_mealy`](./seq_detect_mealy/seq_detect_mealy.vhd) to read and run. They are examined
below, and exercise 4 has you write one.

Reading A.5 matters more than it might look. Everything presented is Moore, and Moore is the
default here and in the follow-on CAN course. A.5 is where you find out what the alternative costs
and buys, which is the only way that default becomes a choice rather than a habit.

---

## Before the lecture
* Read [Appendix A](./appendix/a_state_machines.md).
* This lecture assumes L02's Karnaugh maps and L03's flip-flops, and reuses L07's `timer`
  unchanged together with L04's synchronizer widened to two buttons.

## After the lecture
* Work through [Appendix B](./appendix/b_exercises.md). The first two are pen-and-paper,
  exercise 5 is reading and running the worked machine, and the rest are VHDL.
* Exercises 6 and 7 are the **course capstones**: the two halves of one serial link. The receiver
  composes L04's `reset_sync`, L05's `sync` and L07's `timer` around a state machine that does its
  own shifting; the transmitter needs only the first and the last of those, mirrored. Budget real
  time for them, and design each state diagram on paper before writing any VHDL.
  * Do the receiver first. It is the harder of the two, because it has to recover the bit timing
    it is given rather than define it.

---

## What you should be able to do afterwards
* Explain what a finite state machine is, and identify its states, transitions, inputs and outputs
  in a given circuit.
* Design a Moore machine by hand, from specification through state diagram and state table to
  Karnaugh-derived equations, and build the result in CircuitVerse.
* Model the same machine in VHDL with an enumerated `state_t` type and a `case` process.
* Recognize a Mealy machine on sight and say what its output costs and buys, one clock cycle of
  latency against one extra state, and why Moore is the default here and in the CAN course.
* Compose a state machine with previously built subcomponents rather than rewriting them. By the
  capstone that means three earlier lectures' modules around a machine that is the only new logic,
  drawing on the shift and counter idioms of one more.

---

## Questions to test yourself
* What makes a circuit a state machine, rather than just a register with some logic around it?
* In the hand-designed machine, what exactly is `X`, and why must it be a one-cycle pulse rather
  than the button's level?
* Why is that machine's state encoding a Gray code? What could go wrong with an ordinary binary
  count?
* A counter and a shift register are technically state machines too. What distinguishes them from
  the machine designed here?
* Which signals is a Moore output allowed to depend on, and a Mealy output? Given a single line of
  VHDL driving an output, how do you tell which you are looking at?
* In A.5's comparison, why does the Moore version need an extra state, and why does its output lag
  the Mealy version's by exactly one clock cycle?
* In `fsm_led.vhd`, why does `LED_PROCESS` only ever read `state`, never `button_edge_s2` or
  `button_n` directly? What would change if it did?
* Why is `din` in `seq_detect_mealy` not passed through a synchronizer, unlike `reset_n`?
* What does `when others` buy you in a state-transition `case`, given that `state_t` has only the
  values you declared?
* In the capstone receiver, why does the timer run at sixteen times the baud rate rather than once
  per bit, and why does sampling in the middle of a bit make the design tolerate a transmitter
  whose clock is slightly different from yours?
* The capstone transmitter uses a whole-bit timer and needs no mid-bit anything. What does it have
  that the receiver doesn't, that makes the difference?

---

## Reference
* [Appendix A](./appendix/a_state_machines.md) is the core material.
* [Appendix B](./appendix/b_exercises.md) contains the exercises, including the two capstones.
* Running the testbenches is covered in [L02 Appendix C](../L02/appendix/c_testbenches.md). The
  capstones instantiate three earlier modules and two respectively, so their `ghdl -a` lines name
  several files at once; each exercise prints the command it needs.
* The modules the capstones reuse are worth having open alongside them:
  [L04](../L04/README.md)'s `reset_sync`, [L05](../L05/README.md)'s `sync` and
  [L07](../L07/README.md)'s `timer`. L06's `serial_rx8` and `piso8` are worth rereading for the
  shift idiom, though neither is instantiated: the capstones shift inside their own state
  machines.
* [info/quartus_workflow.md](../../info/quartus_workflow.md) is the toolchain reference behind the
  board demonstration in A.6.

---

## Next lecture
This is the final lecture of **Digital Design with VHDL**. Over eight lectures the course moved
from gates and Karnaugh maps, through registers, metastability, and the VHDL language, to counters,
shift registers and timers, and now finite state machines, at every step reasoning about a circuit
by hand before writing it in synthesizable VHDL and watching it run on a real FPGA. Every pattern
built along the way, the double-flop synchronizer, the `process`/`case` coding style, and now the
Moore state machine, was reused again in this lecture's own examples, and carries forward unchanged
into whatever you build next.

This course ends where a separate, follow-on course begins:
[CAN Controller Design](https://github.com/qrtech-academy/can-controller-design), which designs a
real CAN bus controller's receive and transmit logic as VHDL state machines, running on the same
FPGA, built directly on the Moore/Mealy foundation from this lecture. It is also where you learn to
*write* the testbenches this course only had you run.

---
