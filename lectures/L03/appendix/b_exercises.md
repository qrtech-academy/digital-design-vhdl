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

## D Latch
**1.** Build the first circuit in this course that can *remember* something.

Everything you have built so far has been combinational: the outputs follow the inputs, and the
moment the inputs change the outputs change with them. A latch is the smallest departure from
that. It has a data input `D` and a control input `enable`, and it has two outputs, `Q` and its
complement `Qn`. While `enable` is high the latch is **transparent**: `Q` simply follows `D`, and
it looks like a wire. The interesting part is what happens when `enable` goes low. The latch
**locks**, holding whatever `D` was at that instant, and from then on `D` can do what it likes
without `Q` noticing. That held value is one bit of memory, and it is built out of nothing but the
gates you already know, wired so that the output feeds back into the input.

`Qn` is not decoration. The feedback loop is what makes the circuit remember, and the two outputs
are what feed each other: `Q` is computed from `Qn` and `Qn` from `Q`. Build it and you can see
the loop; that is the point of drawing it by hand before you ever meet the VHDL.

Use the equations from
[Appendix A.2](./a_flip_flops_and_registers.md#a2-the-d-latch):

```math
Q = (D' \cdot enable + Qn)'
```

```math
Qn = (D \cdot enable + Q)'
```

**a)** Realize the corresponding gate network:
* Draw the network by hand.
* Recreate and simulate it in
  [CircuitVerse](https://circuitverse.org/simulator).

**b)** Test the transparent and locked states:
* Set `enable = 1`:
  * Change `D`.
  * Observe what happens to `Q` and `Qn`.
* Set `enable = 0`:
  * Change `D` again.
  * Observe what happens to `Q` and `Qn`.
* Explain the difference between the two cases.

**c)** Cycle `D` and `enable` through the following combinations twice:
* `00`
* `01`
* `10`
* `11`

Confirm that you observe both cases:
* The latch locks after being transparent with `D = 1`.
* The latch locks after being transparent with `D = 0`.

Explain how the value of `Q` depends on the value of `D` at the instant `enable` changes from
`1` to `0`.

---

## D Flip-Flop
**2.** Extend the D latch from exercise 1 into a D flip-flop, following
[Appendix A.3](./a_flip_flops_and_registers.md#a3-the-d-flip-flop).

The flip-flop must have:
* Inputs:
  * `clock`
  * `reset_n`
  * `D`
  * `enable`
* Outputs:
  * `Q`
  * `Qn`

The reset signal is:
* Asynchronous:
  * It takes effect without waiting for a clock edge.
* Active-low:
  * Setting `reset_n = 0` must force `Q` to `0` immediately.

**Tip:**
* The reset has to do two things in each of the two internal latches, not one:
  * Feed an active-high `reset` (`reset_n` through a NOT gate) into the NOR
    gate that produces `Q`. This forces `Q` low without waiting for a clock
    edge.
  * `AND` `reset_n` into the AND gate that produces that latch's `D` and
    `enable` product. This frees `Qn` to go high.
  * Gating only the `Q` feedback path is not enough: with `enable = 1` and
    `D = 1` it leaves `Qn` low, and a low `Qn` is exactly what holds `Q`
    high, so the reset would do nothing.
* Drive the enable inputs of the two internal latches using:
  * `clock`
  * The inverse of `clock`
* Follow Appendix A.3 for how the external `enable` input controls whether the
  flip-flop accepts a new value.

**a)** Realize the corresponding gate network:
* Draw the network by hand.
* Recreate and simulate it in CircuitVerse.
* Set the clock period to `1000 ms`.
  * This is slow enough to observe the behaviour by eye.

**b)** Test the clocked behaviour:
* Change `D` during the high phase of the clock.
* Change `D` during the low phase of the clock.
* Observe `Q` and `Qn`.
* Confirm that the outputs change only on the active clock edge, never between
  clock edges.

Explain how the two internal latches work together to produce edge-triggered
behaviour.

**c)** Test the asynchronous reset:
* First set `Q = 1`.
* Assert the reset by setting `reset_n = 0`.
* Observe whether `Q` resets:
  * Immediately.
  * At the next clock edge.

Explain the result by referring to the difference between an asynchronous
signal and a synchronous signal.

---

## Registers
**3.** Write a complete VHDL entity named `register4`: four flip-flops side by side, sharing one
clock, one reset, and one enable.

This is the exercise where the flip-flop stops being a curiosity and becomes a building block.
A single D flip-flop stores one bit, which is not much use on its own; what a design actually
wants is somewhere to keep a *number*. Put four flip-flops in a row, wire the same clock to all of
them, and you have a four-bit register. Nothing about the individual flip-flop changes. Only the
width does.

The part worth paying attention to is how little the VHDL has to change to say that. You are
writing the same synchronous process template from
[Appendix A.6](./a_flip_flops_and_registers.md#a6-the-synchronous-process-template-in-vhdl) that
you already used for one bit, with `std_logic_vector(3 downto 0)` in place of `std_logic`. There
is no loop, no repetition, no four copies of anything. That is not a shortcut the language is
offering you; it is a fact about the hardware, and part **c)** below asks you to say why.

The entity must have:

| Port | Direction | Type | Description |
|---|---|---|---|
| `clock` | in | `std_logic` | System clock. |
| `reset_n` | in | `std_logic` | Asynchronous, active-low. Clears the register to `"0000"`. |
| `enable` | in | `std_logic` | `'0'` retains the current value; `'1'` captures `d` on the next rising edge. |
| `d` | in | `std_logic_vector(3 downto 0)` | The value to capture. |
| `q` | out | `std_logic_vector(3 downto 0)` | The stored value. |

Write the process out yourself rather than copying the
[worked D flip-flop example](../d_flip_flop/d_flip_flop.vhd). Typing it is how the template stops
being something you recognize and starts being something you can produce from memory, and you will
be writing it in every remaining lecture of this course.

**a)** Write the entity and the synchronous process, adapting the template from a single bit to a
four-bit vector.

**b)** Check it with the testbench, as described at the top of this appendix.

**c)** Explain why the same template scales from one flip-flop to four without any structural
change, while a four-bit *counter* could not simply be four one-bit counters side by side. What is
different about the two cases?

![Module `register4`](./images/register4.png)

**Self-check:** name your entity `register4`, with ports `clock`, `reset_n`, `enable`, `d`
(`std_logic_vector(3 downto 0)`) and `q` (`std_logic_vector(3 downto 0)`), declared in that order;
its testbench is in [`exercises/register4/`](../exercises/register4).

---

## Edge Detection
**4.** Construct a circuit that toggles an LED once for every sampled rising
edge of a button signal.

Follow:
* [Appendix A.7](./a_flip_flops_and_registers.md#a7-edge-detection)
* [Appendix A.9](./a_flip_flops_and_registers.md#a9-worked-example-edge-detected-led-toggle)

The circuit must have:
* Inputs:
  * `button`
  * `clock`
  * `reset`
* Output:
  * `led`

For this exercise, `reset` is active-high, unlike the reset used in the worked
example. It is still **asynchronous**, like every reset in this course: assert it
and `led` clears immediately, without waiting for a clock edge. In the template
from A.6 that means the reset branch stays outside the `rising_edge(clock)` test,
and only the polarity of the test changes.

**Tip:** Use two flip-flops:
* One flip-flop stores the previous sampled value of `button`.
  * Use this value to detect a rising edge.
* One flip-flop stores the current state of `led`.
  * Toggle it only when a rising edge is detected.

**a)** Realize the corresponding gate network:
* Draw the network by hand.
* Recreate and simulate it in CircuitVerse.
* Set the clock period to `1000 ms`.

**b)** Test the edge detector:
* Hold `button` high for several consecutive clock cycles.
* Confirm that `led` toggles exactly once.
* Confirm that it does not toggle once per clock cycle.

Explain which stored signal prevents the circuit from repeatedly detecting the
same high level as a new rising edge.

---

**5.** Implement the circuit from exercise 4 in VHDL.

**a)** Create an entity named `led_toggle_single` with:

| Port | Direction | Type | Description |
|---|---|---|---|
| `clock` | in | `std_logic` | System clock. |
| `reset` | in | `std_logic` | Asynchronous, and **active-high**, unlike every other module in this course. Assert it and `led` clears without waiting for a clock edge, so the reset branch belongs outside the `rising_edge(clock)` test. |
| `button` | in | `std_logic` | Toggles `led` once per press. |
| `led` | out | `std_logic` | The LED state. |

Note the single-bit types: the worked example uses `std_logic_vector` ports for two buttons and two
LEDs, and this one drives a single pair.

Do not copy [`led_toggle.vhd`](../led_toggle/led_toggle.vhd) directly.

Instead:
* Re-derive the two clocked processes yourself:
  * One process stores the previous value of `button`.
  * One process stores and toggles the current value of `led`.
* Derive the edge-detection equation for:
  * A rising edge.
  * An active-high button.
* Use the rising-edge equation from Appendix A.7:

```math
edge = current \cdot previous'
```

Do not use the falling-edge equation from the worked example, which uses an active-low button.

**b)** Verify the design with its testbench (see the note at the top of this appendix).

The testbench drives the same sequence you would exercise by hand on a board:
* It asserts `reset` and checks `led` is cleared.
* It raises `button` and checks `led` toggles exactly once.
* It **holds `button` high** for several more clock cycles and checks, after every one of them,
  that `led` does *not* toggle again.
* It releases and presses again, and checks the second press toggles `led` once more - back off,
  since the first press had turned it on.
* It releases and presses a third time, so the LED is lit when the reset arrives.
* It asserts `reset` with `led` lit and **no clock edge following**, and checks `led` clears
  anyway. This is the one that fails if you put the reset inside the `rising_edge(clock)` branch.

That third check is the one that fails if your edge detector is wrong:
* An `led` that toggles on every clock cycle while the button is held means you drove the toggle
  from `button`'s **level** rather than from its edge.
* Re-read the equation above: `edge` is high only when `button` is high *now* and its stored
  previous value is low.

![Module `led_toggle_single`](./images/led_toggle_single.png)

**Self-check:** name your entity `led_toggle_single`, with ports `clock`, `reset`, `button` (in)
and `led` (out), declared in that order; its testbench is in
[`exercises/led_toggle_single/`](../exercises/led_toggle_single). Note `reset` is **active-high**
here, unlike the worked example.

---
