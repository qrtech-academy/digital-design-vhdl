# L03 - Sequential Logic

## Agenda
* Why combinational logic alone cannot remember anything, and what "state" means in a circuit.
* The D latch and the D flip-flop, and why synchronous designs are built from the flip-flop.
* Clocking: period, frequency, and rising versus falling edges.
* The synchronous process template in VHDL, and when a signal assignment actually takes effect.
* Edge detection: turning a level into a one-cycle pulse.
* `led_toggle` demonstrated on the DE0-CV: a button press that toggles an LED and holds it.
* Self-study: registers as flip-flops in parallel (A.5), and `d_flip_flop` on its own (A.8).

---

## Lecture plan
Built live, in this order:
1. **A D latch, in CircuitVerse.** Cross-coupled gates, transparent while enabled.
2. **A D flip-flop, from a pair of them.** The same circuit, now changing only on an edge.
3. **An edge-detected LED toggle, in CircuitVerse.** One button: one flip-flop remembers the
   previous button state, a second holds the LED, and a falling edge on the button toggles it.
4. **The same circuit in VHDL, for two buttons at once.** The synchronous process template, twice
   over, with the single wires of step 3 widened into 2-bit vectors so one process serves both
   buttons. That widening is the whole difference between the drawing and the module.
5. **Onto the board.** `led_toggle` through Quartus onto the DE0-CV: press the button, watch the
   LED hold its new state until the next press.

Steps 3 to 5 are written up in
[Appendix A.9](./appendix/a_flip_flops_and_registers.md#a9-worked-example-edge-detected-led-toggle).

Two predictions worth making before each simulation runs:
* for the latch, what `Q` does when `enable` goes low while `D` is still changing.
* for the flip-flop, what `Q` does when `D` changes *between* two clock edges.

[`d_flip_flop`](./d_flip_flop/d_flip_flop.vhd) is also written up on its own, in
[Appendix A.8](./appendix/a_flip_flops_and_registers.md#a8-worked-example-a-d-flip-flop-in-vhdl),
with a reference testbench. It is read rather than presented: the session builds the flip-flop as
part of the toggle circuit instead, which is the same module arriving with something to do.

---

## Before the lecture
* Read [Appendix A](./appendix/a_flip_flops_and_registers.md).

## After the lecture
* Work through [Appendix B](./appendix/b_exercises.md). Its first two exercises are the latch and
  the flip-flop, which is where the two predictions above are worth confirming rather than taking
  on trust.

---

## What you should be able to do afterwards
* Say why sequential logic exists, explain the functional difference between a D latch and a D
  flip-flop, and why synchronous designs are built almost entirely from the flip-flop.
* Read and write the synchronous process template, and recognize a register as several flip-flops
  sharing a clock, reset and enable.
* Say when a signal assignment takes effect: `<=` schedules rather than applies, so two
  assignments in one clocked process build a chain, and their order makes no difference.
* Build an edge detector from a flip-flop and a gate, and say exactly what signal it produces and
  for how long.

---

## Questions to test yourself
* What is the functional difference between a D latch and a D flip-flop, and under what condition
  does each change its output?
* Why do synchronous circuits update their state on a single clock edge instead of continuously
  reacting to their inputs?
* Given a signal and a flip-flop holding its value from one cycle earlier, how do you combine them
  into a pulse that is high for exactly one clock cycle when the signal rises?
* Why must `clock` be the only signal in a flip-flop process's sensitivity list, unless the design
  has an asynchronous reset?
* A clocked process contains `b <= a;` and then `c <= b;`. After one clock edge, what does `c`
  hold, and why is it not `a`? What changes if you swap the two lines, and why?

---

## Reference
* [Appendix A](./appendix/a_flip_flops_and_registers.md) is the core material.
* [Appendix B](./appendix/b_exercises.md) contains the exercises.
* Running the testbenches is covered in [L02 Appendix C](../L02/appendix/c_testbenches.md). This is
  the first lecture whose exercises need it for a clocked design, so it is worth rereading before
  you start `register4`.

---

## Next lecture
* Why the raw button feeding this lecture's edge detector can drive a flip-flop into an undefined,
  unstable state, and why that is a different kind of problem from anything here.
* The double-flop synchronizer, and what it does and does not do about a bouncing button.
* The same LED toggle, rebuilt so it is actually safe on real hardware.

---
