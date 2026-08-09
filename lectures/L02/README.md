# L02 - Larger Networks, Multiplexers and Submodules

## Agenda
* `process` and `case`: sequential statements inside otherwise parallel hardware.
* `std_logic_vector`: bundling several wires under one name, indexing and slicing.
* Multiplexers: a 4-to-1 mux, the smallest thing worth writing a `case` for.
* Karnaugh maps: why reading sum-of-products off a truth table rarely gives the smallest network.
* Submodules: writing a block once and instantiating it more than once.
* `hex_display` demonstrated on the DE0-CV: eight switches in, two hexadecimal digits out.
* Self-study: multiplexers at other sizes (A.4, A.5), and the 4-to-1 re-derived by hand in
  exercises 4 to 6.

---

## Lecture plan
Built live, in this order:
1. **A 4-to-1 multiplexer in VHDL.** Four inputs, a two-bit selector, four branches: the smallest
   thing worth writing a `case` for. `process`, `case` and vector indexing all arrive here.
2. **A Karnaugh map, worked end to end in CircuitVerse.** A.1's three-variable example: five
   `1` rows off the truth table, two groups on the map, and `X = AB + C` built as two gates. Small
   enough to derive and check live; exercise 9 scales the same technique up to a segment decoder.
3. **`display` in VHDL.** Step 1's `case`, with sixteen branches instead of four. The only new
   thing on screen is the segment table.
4. **`hex_display`.** Two instances of `display`, eight switches sliced into two halves.
5. **Onto the board.** Set the switches, read the hex digits.

Multiplexers at other sizes are read rather than presented, in
[A.4](./appendix/a_larger_networks.md#a4-multiplexers) and
[A.5](./appendix/a_larger_networks.md#a5-multiplexers-in-vhdl-process-and-case). Exercise 5 builds
the 2-to-1; exercises 4 and 6 re-derive the 4-to-1 you watched being written here, by hand and then
in VHDL, rather than copying it.

---

## Before the lecture
* Read [Appendix A](./appendix/a_larger_networks.md).
* Install GHDL, following [Appendix C](./appendix/c_testbenches.md), if you have not already. L01's
  exercises needed it too, and every exercise from here on that asks you to write a VHDL module
  does.

## After the lecture
* Work through [Appendix B](./appendix/b_exercises.md).

---

## What you should be able to do afterwards
* Derive a minimized equation from a Karnaugh map and turn it into a VHDL architecture.
* Read and write `std_logic_vector` ports and signals.
* Write a `process` with a correct sensitivity list and a `case` covering every input value.
* Build a design out of more than one entity with a positional `port map`, and say why
  instantiating a module twice puts two copies of its gates on the FPGA.
* Verify a module by running its testbench, and read a failed assertion.

---

## Questions to test yourself
* Given a truth table, can you derive its equation both directly and via a Karnaugh map? What is
  different about the two results?
* Why can a `case` statement not appear directly in an architecture body?
* What does `when others` protect you against, given that a selector "can only" be `0` or `1`?
* In `display1: entity work.display`, what does `display1` name, and what does `work.display`
  name? Could a second instance reuse the same label?
* `hex_display`'s architecture contains no logic at all. Where do the gates in the finished design
  come from?
* You instantiated `display` twice rather than writing its `case` twice. Does the FPGA end up with
  one copy of that logic or two? So what did you actually gain?
* This course always writes `port map` positionally. What breaks if an entity's ports are declared
  in a different order from the one its testbench expects, and when would you find out?

---

## Reference
* [Appendix A](./appendix/a_larger_networks.md) is the core material; submodules are
  [A.6](./appendix/a_larger_networks.md#a6-building-a-design-from-submodules), and that pattern is
  used by every multi-entity design in the rest of the course.
* [Appendix B](./appendix/b_exercises.md) contains the exercises.
* [Appendix C](./appendix/c_testbenches.md) is the course's guide to running testbenches, referred
  back to by every later lecture.
* [`gate_network`](./gate_network/gate_network.vhd) is A.2's minimized network in its collapsed
  one-line form; A.2 also prints the version that names the intermediate signal.
* [`mux_8to1`](./mux_8to1/mux_8to1.vhd) is A.5's worked multiplexer. The session does not walk
  through it, so read it alongside A.5 before starting exercises 5 and 6. Both ship a reference
  testbench.

---

## Next lecture
* Sequential logic: circuits that remember.
* The D latch, and the D flip-flop built from a pair of them.
* Clocking, and when a signal assignment actually takes effect.
* Edge detection: a button press that toggles an LED.

---
