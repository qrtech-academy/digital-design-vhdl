# L01 - Combinational Logic and First VHDL

## Agenda
* Logic gates and truth tables, and why digital logic tolerates noise that analog cannot.
* Boolean algebra: reading a sum-of-products equation straight off a truth table.
* Building and simulating a gate network by hand in CircuitVerse.
* VHDL from the first lecture: `entity`, `architecture`, `std_logic`, and the concurrent
  assignment.
* The braking assistant demonstrated on a DE0-CV FPGA board, from Quartus to switches and an LED.
* Self-study: `or_gate`, taken from truth table to complete module in A.4 and A.5.

---

## Lecture plan
Built live, in this order:
1. **A braking assistant as a gate network, in CircuitVerse.** Four gates, derived from a
   requirement and its truth table, then simulated against it.
2. **The same network in VHDL.** `entity`, `architecture`, an internal `signal`, and two
   concurrent assignments.
3. **The assistant demonstrated on the board.** Through Quartus and pin assignment onto a DE0-CV,
   with the four inputs on switches and the brake output on an LED: flick the switches and watch
   the car decide to brake.
4. **Its testbench**, if there is time: what one is, and why nearly every directory here has one.

One circuit, from a requirement to running hardware, written up in
[Appendix A.6](./appendix/a_combinational_logic.md#a6-the-lectures-circuit-a-braking-assistant).
Everything else is reading or exercises, including [`or_gate`](./or_gate/or_gate.vhd), which
[A.4](./appendix/a_combinational_logic.md#a4-enough-vhdl-to-read-and-write-a-gate-circuit) and
[A.5](./appendix/a_combinational_logic.md#a5-the-complete-module-or_gate) take end to end in
writing.

---

## Before the lecture
Read [Appendix A](./appendix/a_combinational_logic.md). Nothing to install for the lecture itself;
you will need GHDL for the exercises, following [L02 Appendix C](../L02/appendix/c_testbenches.md).

## After the lecture
Work through [Appendix B](./appendix/b_exercises.md).

---

## What you should be able to do afterwards
* Derive a sum-of-products equation from a truth table, then build and simulate the network in
  CircuitVerse.
* Apply De Morgan to move an inversion through a gate, and use it to realize a function in a gate
  set that does not contain the operator you started with.
* Read and write a combinational VHDL module, an `entity` with `std_logic` ports and an
  `architecture` driving its output, and say why VHDL separates the two.
* Explain why a concurrent assignment describes a wire rather than a statement that runs once, and
  why a signal sitting at `'U'` or `'X'` is a bug rather than a value.
* Run a provided testbench and tell whether your module passed.

---

## Questions to test yourself
* What is the difference between an `entity` and an `architecture`, and why does VHDL separate
  them?
* Why is `x <= a or b;` not "a statement that runs once"? What does it describe instead?
* In the braking assistant, the driver's pedal is ORed in last rather than passing through the
  fault logic. What breaks if you wire it the other way?

---

## Reference
* [Appendix A](./appendix/a_combinational_logic.md) is the core material.
* [Appendix B](./appendix/b_exercises.md) contains the exercises.
* [CircuitVerse](https://circuitverse.org/simulator): the browser-based simulator used throughout
  this course to build and test every circuit by hand before it is written in VHDL.
* [info/quartus_workflow.md](../../info/quartus_workflow.md): the Quartus/DE0-CV toolchain. The
  board work is demonstrated for you; you need neither Quartus nor hardware.

---

## Next lecture
* Karnaugh maps: finding the *smallest* gate network, not just a correct one.
* `std_logic_vector`, `process` and `case`.
* Submodules, demonstrated on a two-digit hexadecimal display driven by eight switches.
* Self-checking testbenches: verifying your own VHDL without a board.

---
