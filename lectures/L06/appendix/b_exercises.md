# Appendix B - Exercises

> **How to check your work.** Every exercise below that asks you to write a VHDL module ships a
> self-checking testbench under [`exercises/`](../exercises). Write your module in its
> `exercises/<module>/` directory, using the entity name and the **port order** the exercise
> specifies, then run it with GHDL - see [Appendix C](../../L02/appendix/c_testbenches.md) for the
> three commands.
>
> No FPGA board is needed for any exercise. The Quartus synthesis and board-programming steps are
> demonstrated during the lecture; your job afterwards is to get the VHDL right, and the testbench
> is how you confirm it.

## Counters

**1.** A signal is declared as:

```vhdl
signal counter: natural range 0 to 1023;
```

**a)** How many bits wide is the register this synthesizes to?

**b)** What is the largest value `counter` can hold before it wraps back around to `0` on the next
increment?

**c)** Rewrite the declaration for a counter that instead needs to count from `0` up to `63`.

Follow the counter pattern in
[Appendix A.1](./a_counters_and_shift_registers.md#a1-from-registers-to-counters).

---

**2.** Trace a `natural range 0 to 3` counter by hand (no VHDL needed).

Assume:
* The counter starts at `2`.
* It is incremented once per clock edge, for five consecutive edges.
* There is no reset in between.

Record, clock edge by clock edge:
* The value held before the edge.
* The value captured on the edge.

Explain why the counter returns to `0` without any explicit "if the count reaches its maximum,
clear it" logic.

**Note:** this is the *synthesized* behaviour, the one that matters for hardware. A.1 flags the
simulation caveat that goes with it: GHDL range-checks a `natural range 0 to 3` signal, so a
simulation of this counter aborts on the wrap rather than rolling over. Trace it on paper as
hardware, and reach for a full-width `unsigned` if you ever need a counter that wraps in
simulation too.

---

**3.** Build the 4-bit counter from
[Appendix A.1](./a_counters_and_shift_registers.md#a1-from-registers-to-counters) by hand in
CircuitVerse, and use it to see overflow rather than take it on trust.

**a)** Build it:
* A 4-bit register: four D flip-flops sharing one clock.
* An adder, with the register's outputs on one input and a constant `1` on the other.
* The adder's sum wired back to the register's `D` inputs.
* Four output elements or LEDs, one per bit, so you can read the count.

**b)** Run it at a clock period of `1000 ms` and record what you see:
* Write down the sequence of counts over sixteen consecutive clock edges, starting from `0000`.
* Watch `carry_out` on the top adder as the count rolls from `1111` to `0000`:
  * On how many of the sixteen edges is it high?
  * What is connected to it?
* Explain, in one sentence, where that fifth bit goes, and why the register stores `0000` rather
  than `10000`.

**c)** Now reason about what you did *not* build:
* Point at the part of your drawing that decides the counter should return to `0000`.
* There isn't one. Say what is doing the work instead.
* What would you have to add to make it count `0` to `9` and then wrap? (Exercise 4 asks you to
  write exactly that in VHDL, so keep your answer.)

**d)** Change the width to three bits by removing the top flip-flop and narrowing the adder:
* Predict the new wrap point before you run it.
* Confirm it.
* State the rule connecting a counter's width to the value it wraps at.

**Save this circuit.** [L07](../../L07/README.md) builds its timer by adding two things to it - a
comparator and a clear - and starting from a counter you have already watched work is the whole
point of the exercise there.

---

**4.** Write an entity named `counter` that counts from `0` up to one below its radix, then wraps
back to `0`. With the default radix that is a decimal counter, `0` through `9`.

The entity has one generic:

| Generic | Type | Default | Description |
|---|---|---|---|
| `RADIX` | `natural range 1 to 2**16` | `10` | How many values the counter passes through before repeating. It counts `0` to `RADIX-1` inclusive, so `RADIX` is the length of the cycle, not the largest count. |

and these ports:

| Port | Direction | Type | Description |
|---|---|---|---|
| `clock` | in | `std_logic` | System clock. |
| `reset_s2_n` | in | `std_logic` | Active-low, **already-synchronized**: it comes from your `reset_sync` (L04 exercise 8), never straight from a pin. Asynchronous, so it clears with no clock edge involved. |
| `count` | out | `natural range 0 to RADIX-1` | The running count. `0` is a value it takes, so the range starts there: reset drives it to `0`, and it returns there on every wrap. |
| `tick` | out | `std_logic` | A one-cycle pulse on the edge where `count` wraps from `RADIX-1` back to `0`. |

Implement it using a single synchronous process:
* Include `clock` and `reset_s2_n` in the sensitivity list.
* On reset, set `count` to `0` and `tick` to `'0'`.
* On each rising clock edge:
  * Drive `tick` low by default.
  * When `count` has reached `RADIX-1`, wrap `count` to `0` and pulse `tick` high.
  * Otherwise, increment `count`.

Write the comparison against `RADIX-1`, never against `9`. The generic is the whole difference
between a module and a module you can use twice: `RADIX` is fixed before synthesis runs, so the
comparator it builds is no larger than a hard-coded one, and the counter's register is sized to
the radix you ask for. This is the same argument
[L04 A.8](../../L04/appendix/a_metastability_and_synchronization.md#a8-generics-one-module-several-sizes)
makes for `button_sync`'s `COUNT`, and the reason L07's `timer` takes its target as a generic
rather than as a constant.

Unlike the free wraparound of a `natural range 0 to 15` counter (A.1), a counter of arbitrary radix
needs an explicit comparison, because `RADIX-1` is not in general a power-of-two boundary. Notice
what happens when it is: with `RADIX = 16` the comparison is still written, but the hardware
underneath no longer needs it.

**Tip:** The process needs to read the running count (to compare it and to increment it), so hold
the count in an internal `signal count_s: natural range 0 to RADIX-1;`, run the logic on `count_s`,
and drive the output with `count <= count_s;` outside the process, exactly as `d_flip_flop.vhd`
uses `q_s` in L03. This is not a style choice: every `ghdl` command in this course passes
`--std=93`, and under VHDL-93 reading an `out` port does not compile at all. Later standards relax
that, which is why you may have seen it done elsewhere.

Follow the counter pattern in
[Appendix A.1](./a_counters_and_shift_registers.md#a1-from-registers-to-counters), and the
drive-low-then-pulse shape of `data_ready` in
[Appendix A.5](./a_counters_and_shift_registers.md#a5-worked-example-an-8-bit-serial-receiver).

![Module `counter`](./images/counter.png)

**Self-check:** name your entity `counter`, with generic `RADIX` (`natural range 1 to 2**16`,
default `10`), inputs `clock`, `reset_s2_n` and outputs `count` (`natural range 0 to RADIX-1`) and
`tick` (`std_logic`), declared in that order; its testbench is in
[`exercises/counter/`](../exercises/counter). It elaborates **two**
instances, one at `RADIX = 10` and one at `RADIX = 4`, and runs each through two full cycles,
checking that `tick` is a one-cycle pulse rather than a level and that it never fires part way
through. An architecture that quietly hard-codes `10` passes the first instance and fails the
second, which is the point of checking two.

---

## Shift Registers

**5.** An 8-bit SIPO shift register starts at `00000000` and uses the idiom from
[Appendix A.3](./a_counters_and_shift_registers.md#a3-serial-inparallel-out-sipo):

```vhdl
shift_reg <= shift_reg(6 downto 0) & serial_in;
```

It receives the serial bit stream `1, 0, 1, 1` (one bit per clock edge, in that order) over four
consecutive rising clock edges.

**a)** Write out the full 8-bit contents of `shift_reg` after each of the four clock edges.

**b)** After those four edges:
* Which four bits of `shift_reg` hold the received data?
* In what order do they appear, relative to the order the bits arrived in?

---

**6.** A 4-bit PISO register, following the idiom from
[Appendix A.4](./a_counters_and_shift_registers.md#a4-parallel-inserial-out-piso), is:
* Parallel-loaded with `parallel_in = "1010"` (`load = '1'` for one clock edge).
* Then shifted with `shift = '1'` for the next four clock edges.
* With `serial_in` held at `'0'` throughout.

Remember the direction from
[Appendix A.2](./a_counters_and_shift_registers.md#a2-shift-registers):
* bits move toward the MSB.
* `serial_out` is bit 3, the value about to leave.
* `serial_in` enters at bit 0.

**a)** Write out the register's contents and `serial_out` at each step, one line per clock edge:
* The line for the load edge, before any shifting.
* Then one line for each of the four shift edges.

**b)** In what order do the four loaded bits appear on `serial_out`, relative to their positions in
`parallel_in`?

**c)** What are the final contents of the register after all four shifts, and why?

**Tip:** You don't need real hardware to check exercises 5 and 6 by hand. Walk through them exactly
as you would trace a truth table: one clock edge, one line, at a time.

---

**7.** Implement the two useful shift-register configurations from this lecture in VHDL.

**a)** Write an entity named `sipo8`, a serial-in/parallel-out register.

The entity must have:

| Port | Direction | Type | Description |
|---|---|---|---|
| `clock` | in | `std_logic` | System clock. |
| `reset_s2_n` | in | `std_logic` | Active-low, **already-synchronized**: it comes from your `reset_sync` (L04 exercise 8), never straight from a pin. Asynchronous, so it clears with no clock edge involved. Clears the whole register, so `parallel_out` reads `"00000000"` while it is held low. |
| `serial_in` | in | `std_logic` | The incoming bit. |
| `parallel_out` | out | `std_logic_vector(7 downto 0)` | The register's contents. |

Follow the SIPO idiom from
[Appendix A.3](./a_counters_and_shift_registers.md#a3-serial-inparallel-out-sipo).

![Module `sipo8`](./images/sipo8.png)

**Self-check:** name your entity `sipo8`, with ports `clock`, `reset_s2_n`, `serial_in` (in) and
`parallel_out` (`std_logic_vector(7 downto 0)`, out), declared in that order; its testbench is in
[`exercises/sipo8/`](../exercises/sipo8).

**b)** Write an entity named `piso8`, a parallel-in/serial-out register.

The entity must have:

| Port | Direction | Type | Description |
|---|---|---|---|
| `clock` | in | `std_logic` | System clock. |
| `reset_s2_n` | in | `std_logic` | Active-low, **already-synchronized**: it comes from your `reset_sync` (L04 exercise 8), never straight from a pin. Asynchronous, so it clears with no clock edge involved. Clears the whole register, so `serial_out` reads `'0'` while it is held low. |
| `load` | in | `std_logic` | Capture `parallel_in` on the next rising edge. |
| `shift` | in | `std_logic` | Shift one position on the next rising edge. |
| `serial_in` | in | `std_logic` | The bit fed in at bit 0 on a shift. |
| `parallel_in` | in | `std_logic_vector(7 downto 0)` | The value captured on a load. |
| `serial_out` | out | `std_logic` | The register's top bit. |

Follow the PISO idiom from
[Appendix A.4](./a_counters_and_shift_registers.md#a4-parallel-inserial-out-piso):
* On a load edge (`load = '1'`), capture `parallel_in`.
* On a shift edge (`shift = '1'`), move every bit one position toward the MSB, feeding `serial_in`
  in at bit 0.
* Drive `serial_out` from bit 7, so a loaded byte leaves most-significant bit first.
* `load` takes priority over `shift` when both are high.
* With both low, the register **holds**: nothing moves and nothing is captured. Its testbench
  checks this, so a design that shifts unconditionally fails.

![Module `piso8`](./images/piso8.png)

**Self-check:** name your entity `piso8`, with ports `clock`, `reset_s2_n`, `load`, `shift`,
`serial_in`, `parallel_in` (`std_logic_vector(7 downto 0)`) and `serial_out` (out), declared in
that order; its testbench is
in [`exercises/piso8/`](../exercises/piso8). Keep this module:
[L08](../../L08/README.md)'s transmitter capstone (exercise 7) does not instantiate it, but it is
worth rereading there for the idiom, since that machine shifts the byte out inline.

Re-derive each idiom from the appendix rather than copying `serial_rx8`'s shift line.

**c)** For each of the four shift-register configurations, name one task it is the natural choice
for:
* SISO (serial-in/serial-out).
* SIPO (serial-in/parallel-out).
* PISO (parallel-in/serial-out).
* PIPO (parallel-in/parallel-out).

Follow the summary table in
[Appendix A.2](./a_counters_and_shift_registers.md#a2-shift-registers).

---

## Reading the Serial Receiver
The worked example, [`serial_rx8`](../serial_rx8/serial_rx8.vhd), ships a reference testbench. Run
it from the example's own directory before starting:

```bash
cd lectures/L06/serial_rx8
ghdl -a --std=93 serial_rx8.vhd serial_rx8_tb.vhd
ghdl -e --std=93 serial_rx8_tb
ghdl -r --std=93 serial_rx8_tb --assert-level=error --stop-time=10ms
```

**8.** Account for the receiver's behaviour, referring to
[Appendix A.5](./a_counters_and_shift_registers.md#a5-worked-example-an-8-bit-serial-receiver).

**a)** The bit stream `1, 0, 1, 1, 0, 0, 1, 0` arrives, one bit per enabled clock edge:
* What is on `data_out` in the cycle where `data_ready` pulses?
* Which arriving bit ends up in `data_out(7)`, and which in `data_out(0)`?

**b)** `shift_enable` goes low for three clock cycles after the fourth bit, then high again for the
remaining four:
* Does the receiver still produce the same byte? Explain what the bit counter does during the gap.
* What would go wrong instead if `shift_enable` gated only the shift register and not the counter?

**c)** Make each of the following changes to your own copy of `serial_rx8.vhd`, one at a time, and
**predict** what the reference testbench will report before you run it. Then run it and account for
the result:
* Change the shift line to the mirror-image direction,
  `shift_reg <= serial_in & shift_reg(7 downto 1);`.
* Remove the unconditional `data_ready <= '0';` from the top of the clocked branch.
* Change the bit-counter comparison from `BIT_WIDTH - 1` to `BIT_WIDTH - 2`, that is from 7 to 6.

Each of these is a real bug someone has shipped. For each one, say which of the testbench's checks
catches it, and what the failure would have looked like on a real serial link if nothing had caught
it.

---
