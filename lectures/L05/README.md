# L05 - Variables and the Hardware Underneath

## Agenda
* `variable`: process-local storage, updated immediately where a `signal` schedules.
* Why the same accumulation gives two different answers depending on which you reach for.
* What an FPGA is physically made of: look-up tables and flip-flops, and nothing that is a gate.
* The critical path and Fmax, and the latch you infer by accident.
* Self-study: L04's double-flop synchronizer extracted as a generic module (exercise 4), and
  what a generic costs in the hardware Quartus builds.
* `parity_gen` demonstrated on the DE0-CV: the LED toggles whenever exactly one switch changes.

---

## Lecture plan
Built live, in this order:
1. **`parity_gen` with a `signal` accumulator.** Written the way a programmer would write it, then
   traced by hand, one loop iteration at a time, to the wrong answer.
2. **`parity_gen` with a `variable`.** The same loop, traced the same way, to the right one.
3. **What Quartus made of it.** What it actually built, how fast it says the design will run, and
   an inferred-latch warning produced on purpose.
4. **Onto the board.** `parity_gen` on the DE0-CV: eight switches in, one LED out, toggling every
   time exactly one switch changes.

Step 1 is the point of the lecture. The code looks correct, simulates without complaint, and is
wrong, and the only way to see why is to trace it rather than read it.

---

## Before the lecture
* Read [Appendix A](./appendix/a_variables_and_hardware.md).
* Nothing new is assumed beyond L01-L04. Every construct except `variable` has already appeared in
  a design you have written.

## After the lecture
* Work through [Appendix B](./appendix/b_exercises.md), which includes two written exercises about
  what the toolchain does to your VHDL, and a code review of a design that compiles cleanly and is
  wrong anyway.

---

## What you should be able to do afterwards
* Say what separates a `signal` from a `variable`, predict the different result each produces from
  the same code, and choose between them deliberately.
* Explain what an FPGA is physically made of, why two different-looking descriptions of the same
  circuit produce the same hardware, and why a Karnaugh map buys less here than on discrete logic.
* Explain what limits a design's clock frequency, and why adding registers can make a design
  faster rather than slower.
* Recognize an inferred latch from its warning, say what caused it and fix it, and say why "it
  compiled with no errors" promises less for an FPGA design than for a C program.

---

## Questions to test yourself
* A `signal` is assigned twice, to different values, in one pass through a `process`. What ends up
  on it, and when does that update actually happen?
* Same question for a `variable`.
* Why does accumulating across a loop with a `signal` give a different, usually wrong, result?
* Nothing on an FPGA becomes a gate. What does a Boolean function become instead, and why does a
  four-input function cost the same whether or not you minimized it first?
* What is the critical path, and why can adding flip-flops make a design run faster?
* A combinational `case` assigns its output in three branches out of four. What does the synthesis
  tool build for the fourth, and why is that the only thing it *can* build?
* Why is an inferred latch a warning rather than an error, and why does that make it more
  dangerous rather than less?

---

## Reference
* [Appendix A](./appendix/a_variables_and_hardware.md) is the core material: `variable` versus
  `signal` with the `parity_gen` worked example, then LUTs and flip-flops, the critical path and
  Fmax, and the latch you infer by accident.
* [Appendix B](./appendix/b_exercises.md) contains the exercises.
* [info/quartus_workflow.md](../../info/quartus_workflow.md) is the toolchain reference behind this
  lecture's demonstrations. No exercise requires you to have Quartus or a board.
* Testbenches are covered in [L02 Appendix C](../L02/appendix/c_testbenches.md).

---

## Next lecture
* Counters and shift registers: the first designs whose state advances on its own, rather than
  tracking an input the way L03's and L04's registers do.
* Built from L03's clocked-process idiom, with this lecture's scheduling rule doing the real work:
  a shift register is a chain of signals that all update together, which is exactly why it shifts
  instead of collapsing.

---
