# L04 - Metastability and Synchronization

## Agenda
* Why an asynchronous input can break the clean edge detectors and registers built in L03.
* Metastability: what it is, and why it cannot simply be designed away.
* The double-flop synchronizer, and the assert-asynchronously, release-synchronously reset pattern.
* Reusing the same chain for edge detection, and what it does and does not do about bounce.
* Generics: one module serving several sizes.
* `led_toggle_sync` demonstrated on the DE0-CV, driven by a real, bouncing push button.
* Self-study: setup/hold timing detail (A.4), and what a real debounce adds (A.7).

---

## Lecture plan
Built live, in this order:
1. **The same LED toggle as L03, now with synchronizers, in CircuitVerse.** Two flip-flops in
   front of the button, two in front of the reset, and the edge detector behind them.
2. **`reset_sync` in VHDL.** Assert asynchronously, release synchronously.
3. **`button_sync` in VHDL.** The three-flop chain, with a `generic` so one file serves a design
   with one button and a design with two.
4. **`led_toggle_sync`.** The two subcomponents wired together, and the toggle logic that is all
   that is left of the original circuit.
5. **Onto the board.**

Before the synchronizer goes in, predict what a real, asynchronous button does to L03's edge
detector. That prediction is the reason for the whole lecture.

The walkthrough that opens the session is metastability itself. The argument worth holding on to
is why two flip-flops make the failure *unlikely* rather than impossible: that is the part that
does not survive being remembered as a rule of thumb.

Two parts of this lecture's material are read rather than presented. The setup/hold timing detail
in [A.4](./appendix/a_metastability_and_synchronization.md#a4-timing-intuition-why-almost-certainly-is-good-enough),
beyond the fact that the window exists and that violating it is what causes the trouble; and
[A.7](./appendix/a_metastability_and_synchronization.md#a7-what-real-hardware-debouncing-adds), on
what a real debounce circuit adds. Both are examined below and drilled by exercises 2 and 7, so
they are not optional.

---

## Before the lecture
* Read [Appendix A](./appendix/a_metastability_and_synchronization.md).
* Be comfortable with D flip-flops, clocking and edge detection from [L03](../L03/README.md); this
  lecture assumes all of it.
* This lecture also builds on
  [L02 A.6](../L02/appendix/a_larger_networks.md#a6-building-a-design-from-submodules): its worked
  example is composed from two subcomponents, and this lecture's A.8 adds the `generic` that
  lets one of them serve designs with different numbers of buttons.

## After the lecture
* Work through [Appendix B](./appendix/b_exercises.md).
* Read [`led_toggle_sync`](./led_toggle_sync/led_toggle_sync.vhd). Its `reset_sync` and
  `button_sync` subcomponents are exercises 8 and 9 rather than files in the repo, so do those
  first, copy your own into `led_toggle_sync/`, and then run its testbench.

---

## What you should be able to do afterwards
* Explain what metastability is, why an asynchronous input can cause it, and why two flip-flops
  make it unlikely rather than impossible.
* Apply the double-flop synchronizer to any asynchronous input, including the "assert
  asynchronously, release synchronously" pattern used for resets.
* Say why that chain doubles as a practical but incomplete debounce, and what a real one would add.
* Give a module a `generic`, override it with a `generic map`, write a port's width in terms of it,
  and judge when a generic earns its place rather than adding one on principle.

---

## Questions to test yourself
* What exactly happens when an asynchronous input to a flip-flop changes too close to an active
  clock edge?
* How does the double-flop synchronizer address that, and why is the *second* flip-flop's output
  the one that is safe to use?
* Why does the chain used here behave like a debounce circuit in CircuitVerse but not fully
  debounce a real button at `50 MHz`, and why is that a property of the clock period rather than
  of the circuit? What would you add to fix it?
* `button_sync` has a generic and `reset_sync` has none. What is the rule, and what would be wrong
  with giving `reset_sync` a `WIDTH` generic "for symmetry"?

---

## Reference
* [Appendix A](./appendix/a_metastability_and_synchronization.md) is the core material.
* [Appendix B](./appendix/b_exercises.md) contains the exercises.
* [L02 Appendix C](../L02/appendix/c_testbenches.md) covers running the exercises' testbenches
  under GHDL, including the multi-file `ghdl -a` line the composed exercises here need.
* Erik Pihl's video walkthrough of metastability and the double-flop synchronizer is on
  [YouTube](https://www.youtube.com/watch?v=KrssJRgF13I) as further, optional viewing.
* [nandland: Metastability](https://nandland.com/lesson-13-metastability/) and
  [VHDLwhiz: Metastability](https://vhdlwhiz.com/terminology/metastability/) cover the same
  concept from a slightly different angle, useful if Appendix A does not click on the first read.

---

## Next lecture
* `variable`: the one construct you have not met yet, and the sharp distinction between how it
  updates and how a `signal` does.
* Why the same accumulation written with a `signal` and with a `variable` gives two different
  answers, and which of the two is the bug.
* What the toolchain actually builds: LUTs and flip-flops, what limits a clock's speed, and the
  latch you infer by accident.

---
