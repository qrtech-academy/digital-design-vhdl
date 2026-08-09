# L07 - Timers

## Agenda
* Timers: a counter that raises a flag once it reaches a target count.
* Turning clock ticks into real time, and the equality comparator that does it.
* The same timer in VHDL, made reusable by a `generic` rather than by rewiring.
* Composing a design out of pre-built modules instead of rewriting their logic.
* `walking_led` demonstrated on the DE0-CV: a single lit bit walking a row of LEDs.

---

## Lecture plan
Built live, in this order:
1. **A 4-bit timer, in CircuitVerse.** L06's counter, plus an XNOR equality comparator and the
   clear that makes it repeat. Watch `timeout` fire once every eleven edges, for exactly one edge.
2. **The same timer in VHDL,** as a reusable module with its target count as a `generic`.
3. **`walking_led`, live.** The timer just written, plus L04's `reset_sync` and `button_sync`
   unchanged, plus a loop to rotate the pattern. Almost no new logic: this one is about composing
   what already exists.
4. **Onto the board.**

Before the timer runs, predict which count `timeout` fires on, and why it is every eleven edges
rather than every ten. The off-by-one is the whole reason the module's generic is named
`TICK_COUNT` and not `PERIOD`.

`walking_led` is the payoff of the last four lectures: three modules, two of them carried unchanged
from L04 and one written today, composed into something you can watch from the back of the room.

---

## Before the lecture
* Read [Appendix A](./appendix/a_timers.md).
* Be comfortable with counters from
  [L06 A.1](../L06/appendix/a_counters_and_shift_registers.md#a1-from-registers-to-counters). A
  timer is a counter plus one comparison, and this lecture assumes the counter.

## After the lecture
* Work through [Appendix B](./appendix/b_exercises.md).

---

## What you should be able to do afterwards
* Explain what separates a timer from a plain counter, and why the difference is one comparison.
* Build a timer as a gate network: an equality comparator from one XNOR per bit, and the clear
  that makes it repeat rather than wrap.
* Implement a timer in VHDL as a reusable module, converting a period in seconds into a
  `TICK_COUNT`, and say why `timeout` is a one-cycle pulse rather than a level.
* Compose a design out of pre-built modules rather than rewriting them, and say why a button
  controlling a timer still has to pass through a synchronizer first.

---

## Questions to test yourself
* In what sense is a timer "just a counter with a comparison"?
* Why must the internal counter be cleared back to `0` on reaching its target, rather than left to
  keep counting?
* Why is `timeout` a single-cycle pulse rather than a level that stays high?
* In the CircuitVerse version, changing the target count means rewiring the comparator. What
  replaces that rewiring in the VHDL version, and when is its value fixed?
* Why is it still necessary to run a button through a synchronizer before using its edge to enable
  a timer, even though the button has nothing to do with counting?
* `walking_led` writes almost no logic of its own. Name the three modules it composes and which
  lecture each came from.

---

## Reference
* [Appendix A](./appendix/a_timers.md) is the core material.
* [Appendix B](./appendix/b_exercises.md) contains the exercises.
* [L02 Appendix C](../L02/appendix/c_testbenches.md) covers running the exercises' testbenches
  under GHDL, including the multi-file `ghdl -a` line `blinker` and `walking_led` need.
* [info/quartus_workflow.md](../../info/quartus_workflow.md) covers the Quartus project setup, pin
  assignment, compilation and programming used for the board demonstration.
* The `reset_sync` and `button_sync` synchronizers are unchanged from [L04](../L04/README.md), and
  are not re-explained here beyond a short recap.

---

## Next lecture
* Finite state machines, the last building block in the course, designed by hand first: state
  diagram, state table, Karnaugh-derived logic, and a gate network in CircuitVerse, exactly the way
  this lecture's timer was drawn before it was written.
* Then in VHDL, where an enumerated type and a `case` statement replace the state table and the
  Karnaugh maps entirely.
* A timer is itself a state machine with two states and a single purpose. L08 generalizes that to
  circuits with many states and many transitions between them.

---
