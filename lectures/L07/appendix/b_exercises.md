# Appendix B - Exercises

> **How to check your work.** Every exercise below that asks you to write a VHDL module ships a
> self-checking testbench under [`exercises/`](../exercises). Write your module in its
> `exercises/<module>/` directory, using the entity name and the **port order** the exercise
> specifies, then run it with GHDL - see [Appendix C](../../L02/appendix/c_testbenches.md) for the
> three commands.
>
> From this lecture on, designs reuse modules you wrote earlier, and those are not shipped a second
> time: each exercise says which of your own files to copy in and prints the `ghdl -a` line that
> needs them.
>
> No FPGA board is needed for any exercise. The Quartus synthesis and board-programming steps are
> demonstrated during the lecture; your job afterwards is to get the VHDL right, and the testbench
> is how you confirm it.

## Timers by Hand

**1.** Build a second timer by hand in CircuitVerse, following
[Appendix A.2](./a_timers.md#a2-building-a-timer-by-hand-in-circuitverse), but with a target count
of `TICK_COUNT = 12` instead of the appendix's `10`.

**a)** Retarget the comparator:
* Write `12` in 4-bit binary.
* The four XNOR gates stay exactly where they are. Say which of their constant inputs change, and
  to what.
* State, in one sentence, why an equality comparator built from XNORs needs no gate added, removed
  or rewired to compare against a different value.

**b)** Build it:
* Reuse your 4-bit counter and comparator from the lecture, changing only the constants.
* Set the clock period to `1000 ms` and confirm `timeout` fires once every thirteen clock edges,
  for exactly one edge each time.

**c)** Now remove the clear, so that `timeout` no longer forces the counter back to `0000`:
* Predict, before running it, how often `timeout` fires now.
* Run it and confirm.
* Explain the result in terms of the counter's own wraparound (L06 A.1).

**d)** Deliberately break the comparator: disconnect one XNOR's output from the AND gate and tie
that AND input high instead.
* Predict which counts now assert `timeout`, before simulating.
* Confirm by stepping the counter through a full cycle.
* This is what "three of the four bits match" looks like, and it is the most common way a
  hand-drawn comparator goes wrong.

**Tip:** counting `0` through `12` inclusive is thirteen edges, not twelve. Appendix A.1's note on
`TICK_COUNT + 1` is the same off-by-one, and it is worth getting straight here, where you can count
the edges by eye, rather than later at 50 MHz.

---

**2.** Answer each of the following in one or two sentences, referring to the `timer` module in
[Appendix A.3](./a_timers.md#a3-the-timer-module-in-vhdl):

**a)** Why is `timeout` a single-cycle pulse, rather than a signal that stays high once the target
count is reached?

**b)** While a running timer's `enable` input is held low, what happens to its internal counter from
one clock edge to the next: does it reset, pause, or keep counting?

**c)** Why does the `timer` take `reset_s2_n` (the synchronized reset) rather than the raw `reset_n`
as its reset input?

**d)** The CircuitVerse timer in exercise 1 needed rewiring to change its target count, while the
VHDL module needs no edit at all. What replaces the rewiring, and at what point is its value fixed?

---

## Timers in VHDL

**3.** The DE0-CV board's system clock is `50 MHz`. For each target below, calculate the
`TICK_COUNT` generic you would pass to the `timer` module from
[Appendix A.3](./a_timers.md#a3-the-timer-module-in-vhdl):

**a)** A `timeout` pulse once per second.
**b)** A `timeout` pulse every `250` ms.
**c)** A `timeout` pulse twenty times per second (`20 Hz`).

**Tip:** The relationship between a period and its tick count is:

```math
TICK\_COUNT = seconds \times 50{,}000{,}000 - 1
```

The `- 1` is the same off-by-one exercise 1 turned on: the counter runs `0` through `TICK_COUNT`
inclusive, so a period is `TICK_COUNT + 1` clock cycles, not `TICK_COUNT`.

---

**4.** Write the `timer` module itself, as an entity named `timer`.

It is built live during the lecture and printed in full in
[Appendix A.3](./a_timers.md#a3-the-timer-module-in-vhdl), so this is not a puzzle. Write it anyway,
without copying: every design from here to the end of the course instantiates this module, including
both capstones, and it is worth having built the thing you are about to reuse six times.

The entity has one generic:

| Generic | Type | Default | Description |
|---|---|---|---|
| `TICK_COUNT` | `natural` | `50_000_000` | Ticks to count before a timeout. One second at the DE0-CV's `50 MHz` clock, rounded: by exercise 3's rule the exact value is `49_999_999`, and 20 ns of error in a second is not worth the less readable constant. |

and these ports:

| Port | Direction | Type | Description |
|---|---|---|---|
| `clock` | in | `std_logic` | System clock. |
| `reset_s2_n` | in | `std_logic` | Active-low, already-synchronized reset. Asynchronous: it clears the counter and `timeout` with no clock edge involved. |
| `enable` | in | `std_logic` | Timer enable. While low the counter **holds** its value, and resumes from there rather than restarting. |
| `timeout` | out | `std_logic` | One-cycle pulse, asserted every `TICK_COUNT + 1` cycles while enabled. |

The architecture must:
* Declare the internal counter as `natural range 0 to TICK_COUNT`, so the register is sized by the
  generic rather than left unconstrained.
* Use one process, sensitive to `clock` and `reset_s2_n`, following the clocked-process template
  from [L03 A.6](../../L03/appendix/a_flip_flops_and_registers.md#a6-the-synchronous-process-template-in-vhdl).
* Clear both the counter and `timeout` on reset, outside the clocked branch.
* Drive `timeout` low unconditionally at the top of the clocked branch, and high only on the edge
  that clears the counter. That default-then-override is what makes the pulse exactly one cycle
  wide rather than two.

Then answer, in a sentence each:
* `enable = '0'` must **pause** the counter, not clear it. Suppose you cleared it instead. Predict
  what the reference testbench reports, and which of the two properties above it is measuring when
  it does. Then run it and see. (L08's `fsm_led` depends on the pause, which is why the testbench
  bothers.)
* The counter counts `0` through `TICK_COUNT` inclusive, so a period is `TICK_COUNT + 1` cycles.
  Where in your code is that "+ 1" actually written? It is not a literal anywhere.
* A.2's hand-drawn `timeout` is a combinational decode of the count; yours is registered. Both have
  the same period. Which cycle does each one fire on, and why does the difference matter for
  anything downstream that samples `timeout`?

![Module `timer`](./images/timer.png)

**Self-check:** name your entity `timer`, with generic `TICK_COUNT` (`natural`, default
`50_000_000`), inputs `clock`,
`reset_s2_n`, `enable`, and output `timeout`, declared in that order; its testbench is in
[`exercises/timer/`](../exercises/timer). It runs three full periods, so a one-shot passes nothing,
and pauses mid-count to confirm the count resumed rather than restarted.

**Keep this file.** Exercise 5 below reuses it, so does `walking_led` in exercise 6, and so do both
L08 capstones. Every later exercise that needs a timer asks you to copy this one in.

---

**5.** Write an entity named `blinker` that blinks an LED on and off once per second, by reusing the
`timer` module you just wrote rather than counting clock cycles itself.

The entity has one generic:

| Generic | Type | Default | Description |
|---|---|---|---|
| `TICK_COUNT` | `natural` | `25_000_000` | A half-second at the DE0-CV's `50 MHz` clock. Expose it as a generic rather than hard-coding the count, so a testbench can shorten the blink; the FPGA build just uses the default. |

and these ports:

| Port | Direction | Type | Description |
|---|---|---|---|
| `clock` | in | `std_logic` | System clock. |
| `reset_n` | in | `std_logic` | Active-low reset, raw from the outside world. Asynchronous: assert it and `led` goes out immediately, without waiting for a clock edge. |
| `led` | out | `std_logic` | Cleared to `'0'` while the reset is asserted, and left there until the first timeout after the reset is released. |

Note that this entity takes the **raw** `reset_n` rather than an already-synchronized
`reset_s2_n`. Synchronizing it is part of the exercise, and it is what
[L04 A.5](../../L04/appendix/a_metastability_and_synchronization.md#a5-synchronizing-a-reset-signal-assert-async-release-sync)
means by "exactly one module in a design is the exception": here that module is `blinker` itself.

The architecture must:
* Instantiate your `reset_sync` from [L04 exercise 8](../../L04/appendix/b_exercises.md), and use
  its `reset_s2_n` output as the reset for everything inside.
* Instantiate the `timer` module from
  [Appendix A.3](./a_timers.md#a3-the-timer-module-in-vhdl):
  * Pass your own `TICK_COUNT` generic straight through to the timer's `TICK_COUNT`.
  * Hold its `enable` input high.
* Toggle `led` in a synchronous process whenever the timer's `timeout` pulse fires.

Do not reimplement the counting logic, or the synchronizer, yourself.

Instead:
* Reuse `timer` and `reset_sync` unchanged, via a `generic map` and `port map`, following the
  composition pattern in [Appendix A.4](./a_timers.md#a4-composing-a-full-timer-circuit).
* Explain why a **half**-second timer period produces a **one**-second blink cycle (one full
  on-then-off period).

Then answer, in a sentence each:
* The LED must be off during reset, and the testbench checks that it goes off with no clock edge in
  between. Which half of the assert-async-release-sync pattern does that check, and which half does
  it not?
* Your `timer` is reset by `reset_s2_n`, two edges after `reset_n` is released. What would go wrong
  if you fed it the raw `reset_n` instead? Name the failure, not just the rule.

![Module `blinker`](./images/blinker.png)

**Self-check:** name your entity `blinker`, with generic `TICK_COUNT` (`natural`, default
`25_000_000`), inputs `clock`,
`reset_n`, and output `led`, declared in that order; its testbench is in
[`exercises/blinker/`](../exercises/blinker).
**Copy your own `reset_sync.vhd` and `timer.vhd` into that directory** before you build; neither
is shipped there, because you wrote both. It overrides `TICK_COUNT` with a small value and checks
that the LED toggles repeatedly, holds for exactly one timer period between toggles, and that the
first toggle arrives late by your synchronizer's two edges
(see [Appendix C](../../L02/appendix/c_testbenches.md)):

```bash
cd lectures/L07/exercises/blinker
cp ../../../L04/exercises/reset_sync/reset_sync.vhd .   # the two you wrote yourself
cp ../timer/timer.vhd .
ghdl -a --std=93 reset_sync.vhd timer.vhd blinker.vhd blinker_tb.vhd
ghdl -e --std=93 blinker_tb
ghdl -r --std=93 blinker_tb --assert-level=error --stop-time=10ms
```

---

## The Walking LED
A single lit LED walking along a row, one position per timer tick, started and stopped with a
button. It is built live during the lecture and written up in
[Appendix A.5](./a_timers.md#a5-fpga-implementation-a-walking-led-shift-register).

This is the payoff of the last four lectures, and it writes almost no logic of its own: three
modules, two of them carried unchanged from L04 and one written today, composed. Exercise 6 builds
it, and exercises 7 and 8 modify what you built.

**6.** Write an entity named `walking_led`.

Like the `timer` of exercise 4, it is built live during the lecture and printed in full in
[Appendix A.5](./a_timers.md#a5-fpga-implementation-a-walking-led-shift-register), so this is not
a puzzle either. Write it anyway, without copying: composing three modules you wrote yourself is
the whole point of the exercise, and the capstones in L08 ask for it again at twice the size.

The entity has two generics:

| Generic | Type | Default | Description |
|---|---|---|---|
| `LED_COUNT` | `natural` | `8` | How many LEDs the bit walks along. The row is this wide, and the walk wraps after this many steps. |
| `TICK_COUNT` | `natural` | `25_000_000` | Passed straight through to your `timer`, so the bit moves one position per timer period: a half-second step at the DE0-CV's `50 MHz` clock. |

and these ports:

| Port | Direction | Type | Description |
|---|---|---|---|
| `clock` | in | `std_logic` | System clock. |
| `reset_n` | in | `std_logic` | Active-low reset, raw from the outside world. Synchronizing it is your job, as it was in `blinker`. |
| `button_n` | in | `std_logic` | Active-low push button, raw. Each press starts or stops the walk. |
| `led` | out | `std_logic_vector(LED_COUNT-1 downto 0)` | The LED row. Exactly one bit is lit at any time; on reset it is bit `0`. |

The architecture composes three modules you have already written, and adds two processes:
* Instantiate your **`reset_sync`**, and use its `reset_s2_n` as the reset for everything else in
  the design, including the two instances below.
* Instantiate your **`button_sync`** with `generic map(1)`, for a one-cycle pulse per press. Its
  button ports are `COUNT`-bit vectors while `button_n` here is a scalar, so bridge the width with
  a one-element `std_logic_vector(0 downto 0)` in each direction. A.5 shows this.
* Instantiate your **`timer`** with your own `TICK_COUNT`, driving its `enable` from the
  shift-enable flag below and taking its `timeout` as the shift tick.
* A process toggling **`shift_enable`** on each button pulse, cleared to `'0'` on reset. The walk
  therefore starts stopped.
* A process holding the **shift register** that drives `led`: on reset, load a single lit bit at
  position `0` and clear the rest; on each timer `timeout`, rotate one step toward the MSB, wrapping
  the top bit back around into bit `0`. That is a PISO register (L06 A.4) with its own serial output
  wired back to its serial input, which is what turns a one-shot shift-out into an endless walk.

Then answer, in a sentence each:
* `shift_enable` drives the timer's `enable`, so stopping the walk stops the timer too. Exercise 4
  made you show that `enable` **pauses** the count rather than clearing it. What does a reader see
  on the board, on the press that restarts the walk, if your timer clears instead?
* `button_sync` is instantiated with `COUNT = 1` here and with `COUNT = 2` in L08's `fsm_led`, from
  the same file with no edit. What would you have had to write instead if the width were fixed in
  the module rather than passed as a generic?

![Module `walking_led`](./images/walking_led.png)

**Self-check:** name your entity `walking_led`, with generics `LED_COUNT` (`natural`, default `8`)
and `TICK_COUNT` (`natural`, default `25_000_000`), inputs `clock`, `reset_n`, `button_n`, and
output `led`, declared in that order; its
testbench is in [`exercises/walking_led/`](../exercises/walking_led). It overrides the generics
(`LED_COUNT = 4`, `TICK_COUNT = 3`) so a full lap takes a handful of clock cycles rather than two
seconds, and it checks the reset pattern, that nothing moves before the first press, and that the
shift count over a fixed window matches the pace the timer sets. Copy in the three modules it
composes first:

```bash
cd lectures/L07/exercises/walking_led
cp ../../../L04/exercises/reset_sync/reset_sync.vhd .   # the three you wrote yourself
cp ../../../L04/exercises/button_sync/button_sync.vhd .
cp ../timer/timer.vhd .
ghdl -a --std=93 reset_sync.vhd button_sync.vhd timer.vhd \
                 walking_led.vhd walking_led_tb.vhd
ghdl -e --std=93 walking_led_tb
ghdl -r --std=93 walking_led_tb --assert-level=error --stop-time=10ms
```

---

**7.** Make the following changes one at a time, re-running the testbench after each. Parts **a)**
and **b)** change only the testbench's constants - that they need no edit to your
`walking_led.vhd` at all is the point of them. Part **c)** is the one that touches the module.

**a)** Change the walking speed:
* Edit the `TICK_COUNT` constant in the **testbench** from `3` to `6`.
* It should still pass, and this time because the testbench adapts with you: its observation window
  is a fixed `PULSES * 6` cycles, and it derives the shift count it expects from `TICK_COUNT`, one
  shift per `TICK_COUNT + 1` cycles.
* Now find where that adaptation stops meaning anything. Keep raising `TICK_COUNT` past the window
  length and work out what the expected count becomes, and what the check is then actually
  proving. A test that passes for the wrong reason is worth being able to recognize.
* Then explain why changing the tick count cannot break the *design*, only slow it down.

**b)** Change the width:
* Edit the testbench's `LED_COUNT` constant from `4` to `8`.
* It should still pass, with no change to your `walking_led.vhd` at all. Explain what the module
  would have needed to look like for this to require an edit.

**c)** Load two lit bits on opposite sides of the register on reset (e.g. `"10001000"` for
`LED_COUNT = 8`), and let them walk in lockstep:
* Identify the single line in your `walking_led.vhd` you need to change.
* Before running anything, **predict** what the reference testbench will report.
* Then run it and see. Explain the result: is the design wrong, or is the testbench asserting
  something that is no longer the specification?

**Tip:** Both `LED_COUNT` and `TICK_COUNT` are generics, so parts **a)** and **b)** need no change
to the module's body at all. That is the entire point of a generic: one module, many sizes, no
edits.

---

**8.** The current design only ever walks in one direction (toward the MSB, wrapping the top bit
back around to the bottom). Modify your `walking_led.vhd` so that a **second** button reverses the
walking direction.

**a)** Add a second, synchronized button input:
* Route it through the same `button_sync` instance, passing `2` for its `COUNT` generic
  (`generic map(2)`, positionally, as everywhere else in this course).

**b)** Add a `direction` signal:
* Toggle it on the new button's edge, exactly the way `shift_enable` is toggled by the first button.

**c)** Make the rotation in `SHIFT_PROCESS` depend on `direction`:
* When `direction = '0'`, rotate toward the MSB (the course convention from
  [L06 Appendix A.2](../../L06/appendix/a_counters_and_shift_registers.md#a2-shift-registers), and
  what you wrote in exercise 6):

```vhdl
shift_reg <= shift_reg(LED_COUNT-2 downto 0) & shift_reg(LED_COUNT-1);
```

* When `direction = '1'`, rotate the other way, toward bit 0:

```vhdl
shift_reg <= shift_reg(0) & shift_reg(LED_COUNT-1 downto 1);
```

This is the one place in the course where a shift register deliberately runs against the course
convention: reversing direction is the entire point of the exercise. Note that the second
expression is exactly the mirror image L06 A.2 warns you to watch for in other people's code.

**d)** Your entity's ports have now changed: `button_n` is a two-bit vector rather than a single
bit.

* Explain why [`walking_led_tb.vhd`](../exercises/walking_led/walking_led_tb.vhd) can no longer be
  used against your version, and what precisely GHDL will complain about when you try.
* This is the ordinary cost of changing an interface, and it is worth feeling once: a testbench is
  written against a specific entity, and widening a port breaks every instantiation of it,
  including the ones you did not write.
* Describe, in prose, the sequence of presses you would use to convince yourself the design works,
  and what you would expect the LEDs to do at each step. That sequence is exactly what a testbench
  for the new entity would have to drive.

---
