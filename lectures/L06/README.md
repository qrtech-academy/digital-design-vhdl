# L06 - Counters and Shift Registers

## Agenda
* Counters: a register, an adder and a constant `1`, and why wraparound comes for free.
* Shift registers: moving data one bit per clock edge, in one direction used consistently.
* Serial-in/parallel-out and parallel-in/serial-out, and which fits which job.
* An 8-bit serial receiver: a shift register plus a bit counter, knowing when a byte has arrived.
* Two demonstrations on the DE0-CV: a row of LEDs counting and wrapping, and a byte shifted in one
  button press at a time.

---

## Lecture plan
Built live, in this order:
1. **A 4-bit counter, in CircuitVerse.** A register, an adder, and a constant `1`. Run it past
   `1111` and watch it wrap.
2. **The same counter in VHDL.**
3. **A shift register in VHDL.** Traced one clock edge at a time first, on paper, before any of it
   is written.
4. **`serial_rx8`, live.** The shift register just written, plus the bit counter that tells it when
   a byte is done. The two halves of the lecture meeting in one module.
5. **Onto the board, twice.** First the counter, its top bits on a row of LEDs, slowed to something
   the eye can follow: watch it run up to all-ones and wrap back to zero on its own. Then
   `serial_rx8` with `shift_enable` driven by a push button instead of held high, so one press
   shifts one bit and the byte assembles across eight LEDs, most significant bit first.

Before the counter reaches `1111`, predict what it will show next, and then find the element in
the drawing that makes it happen. There isn't one, which is the point: nothing in the circuit
performs the wrap, and that is a consequence of the register's width rather than logic anybody
added.

[`serial_rx8`](./serial_rx8/serial_rx8.vhd) is the first design in the course whose correctness you
cannot check by eye at full speed: enabled continuously it swallows a byte in 160 ns. That is why
it ships a reference testbench, and why the board demonstration drives `shift_enable` from a button
instead. Slowing the *clock* would be the software instinct and the wrong move; the module already
has the control that lets you take one bit at a time.

---

## Before the lecture
* Read [Appendix A](./appendix/a_counters_and_shift_registers.md).

## After the lecture
* Work through [Appendix B](./appendix/b_exercises.md).

---

## What you should be able to do afterwards
* Build a 4-bit counter as a gate network, and explain, pointing at your own drawing, why nothing
  in it makes the count return to zero.
* Implement the same counter in VHDL, explain wraparound as a consequence of the register's bit
  width, and say why a simulator objects to a wrap the hardware performs happily.
* Implement a shift register in both SIPO and PISO configurations, know which fits which job, and
  know which direction this course shifts in and why sticking to one matters.
* Combine a counter with a shift register to detect that a complete word has arrived, and verify a
  clocked design by running its testbench.

---

## Questions to test yourself
* Why does a `natural range 0 to 15` counter return to `0` after `15` with no explicit "if at
  maximum, clear it" logic? What has to be true of the range? Which element performs the wrap?
* A VHDL simulator aborts on the wrap your CircuitVerse drawing performs without complaint. Which
  of the two is modelling the hardware, and what does that tell you about trusting either alone?
* What is the practical difference between a SIPO and a PISO shift register? Which would you reach
  for to receive a stream of serial bits, and which to drive a chain of LEDs from a fixed pattern?
* A shift register and a counter are both "N flip-flops sharing a clock". What differs is what
  feeds each flip-flop's input. Describe that difference for each.
* In `serial_rx8`, why is `data_ready` a one-cycle pulse rather than a level that stays high once a
  byte has arrived?
* Why does `shift_enable` have to gate the bit counter as well as the shift itself?
* The board demonstration drives `shift_enable` from a button rather than slowing the clock down.
  Why is slowing the clock the wrong answer, and what would break if the button were wired to
  `shift_enable` without passing through `button_sync` first?
* `data_ready` needs a flip-flop of its own before an LED can show it. Which earlier lecture's
  problem is that, in different clothes?

---

## Reference
* [Appendix A](./appendix/a_counters_and_shift_registers.md) is the core material.
* [Appendix B](./appendix/b_exercises.md) contains the exercises.
* Running the testbenches is covered in [L02 Appendix C](../L02/appendix/c_testbenches.md).
* [`serial_rx8`](./serial_rx8/serial_rx8.vhd) is A.5's receiver, and ships a reference testbench.
  A.7's board demonstration wraps it in [L04](../L04/README.md)'s `reset_sync` and `button_sync`,
  both unchanged, so it is a composition exercise as much as a receiver.

---

## Next lecture
* Timers: a counter with a target count, which is what turns clock ticks into real time.
* Built by adding exactly two things to the counter you drew here, a comparator and a clear, so
  keep that CircuitVerse project.
* The walking LED: this lecture's shift register, paced by that timer and started by a synchronized
  button, live-coded and run on the DE0-CV board.

---
