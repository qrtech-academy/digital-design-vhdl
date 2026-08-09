# Appendix B - Exercises

> **How to check your work.** Every exercise below that asks you to write a VHDL module ships a
> self-checking testbench under [`exercises/`](../exercises). Write your module in its
> `exercises/<module>/` directory, using the entity name and the **port order** the exercise
> specifies, then run it with GHDL - see [Appendix C](../../L02/appendix/c_testbenches.md) for the three
> commands.
>
> No FPGA board is needed for any exercise. The Quartus synthesis and board-programming steps are
> demonstrated during the lecture; your job afterwards is to get the VHDL right, and the testbench
> is how you confirm it.

## `variable` Versus `signal`

**1.** The broken `parity_gen` architecture from
[Appendix A.2](./a_variables_and_hardware.md#a2-variable-process-local-storage-with-an-immediate-update)
is reproduced below:

```vhdl
architecture broken of parity_gen is
signal parity_s: std_logic;
begin
    parity <= parity_s;

    process(bits) is
    begin
        parity_s <= '0';
        for i in bits'range loop
            parity_s <= parity_s xor bits(i);
        end loop;
    end process;
end architecture;
```

Assume:
* `bits` has the range `7 downto 0`.
* `bits = "10110110"`.
* `parity_s` holds `'0'` before the process begins.

**a)** Trace the process by hand.

For the initial assignment and every loop iteration, record:
* The current index `i`.
* The value of `bits(i)`.
* The value read from `parity_s`.
* The value scheduled for `parity_s`.
* Whether that scheduled assignment survives until the process suspends.

Remember:
* A signal assignment does not update the signal immediately.
* Assignments to the same signal during one process activation replace earlier
  scheduled assignments for the same simulation time.

**b)** Determine the final value assigned to `parity_s` after the process suspends.

Then:
* Calculate the correct XOR parity of `"10110110"` by hand.
* Compare it with the result from the broken architecture.
* Explain why repeatedly assigning to the signal does not create an
  accumulator.

**c)** Trace the variable-based `behaviour` architecture from the lecture's `parity_gen.vhd` file
using the same input.

For every loop iteration, record:
* The value of `bits(i)`.
* The value of `acc` before the XOR operation.
* The value of `acc` immediately after the XOR operation.

Confirm that:
* `acc` retains the result of each iteration for use by the next iteration.
* The final value assigned to `parity` is the correct XOR parity.

---

**2.** Write an entity named `min_of_two`.

The entity must have:

| Port | Direction | Type | Description |
|---|---|---|---|
| `a` | in | `std_logic_vector(3 downto 0)` | First value. |
| `b` | in | `std_logic_vector(3 downto 0)` | Second value. |
| `m` | out | `std_logic_vector(3 downto 0)` | The smaller of the two. |

Treat `a` and `b` as unsigned four-bit values.

Implement the circuit using a process:
* Include `a` and `b` in the sensitivity list.
* Declare a process-local variable to hold the smaller value.
* Compare `a` and `b` as unsigned numbers.
* Assign the variable exactly once during each process activation.
* Assign the variable to `m` after the comparison.

Use the facilities from `ieee.numeric_std` when performing the unsigned comparison, following
[L02 A.3](../../L02/appendix/a_larger_networks.md#a3-std_logic_vector-more-than-one-wire).

This exercise does not require a loop. Its purpose is to use a variable as temporary process-local
storage for something *other than* an accumulator: A.2's worked example builds a value up across
the iterations of a loop, which is the case a variable is usually introduced for, and it is easy to
come away thinking that is the only thing they are good for. Here the variable simply holds an
intermediate result for the few lines between computing it and using it, which is the more common
use of the two in real code.

![Module `min_of_two`](./images/min_of_two.png)

**Self-check:** name your entity `min_of_two`, with ports `a`, `b` (in) and `m` (out), all
`std_logic_vector(3 downto 0)`, declared in that order; its testbench is in
[`exercises/min_of_two/`](../exercises/min_of_two).

---

**3.** Write an entity named `ones_count8` that counts how many bits of an 8-bit input are set.

Exercise 1 had you trace the accumulator bug on paper and exercise 2 used a variable that was not
an accumulator at all. This one is the case A.2 is actually about: a value built up across the
iterations of a loop. It is the only exercise in the course where you write one.

The entity must have:

| Port | Direction | Type | Description |
|---|---|---|---|
| `bits` | in | `std_logic_vector(7 downto 0)` | The value to count over. |
| `ones` | out | `natural range 0 to 8` | The number of bits of `bits` that are `'1'`. |

Implement it using a single combinational process:
* Put `bits` in the sensitivity list.
* Declare a process-local `variable` for the running count, and set it to `0` at the top of every
  activation. A variable keeps its value between activations, so a count that is never cleared
  keeps growing.
* Loop over `bits'range`, adding `1` for each bit that is set.
* Assign the variable to `ones` once, after the loop.

Then answer, in a sentence each:
* Write the same thing with a `signal` accumulator instead, run the testbench, and record what it
  reports for the input `00000010`. Explain the number you get using the scheduling rule, not by
  guessing.
* The loop runs eight times. How many adders does this design put on the FPGA, and how many clock
  cycles does it take to produce an answer? If those two answers surprise you, reread
  [A.2](./a_variables_and_hardware.md#what-that-loop-is-not).
* `ones` is a `natural range 0 to 8` rather than a `std_logic_vector(3 downto 0)`. Both can hold
  the answer. What does the range buy you, and what would GHDL do if your count ever left it?

![Module `ones_count8`](./images/ones_count8.png)

**Self-check:** name your entity `ones_count8`, with input `bits` (`std_logic_vector(7 downto 0)`)
and output `ones` (`natural range 0 to 8`), declared in that order; its testbench is in
[`exercises/ones_count8/`](../exercises/ones_count8) and sweeps all 256 input values.

---

## A Module Worth Having on Its Own

**4.** Write the double-flop synchronizer as a module of its own, named `sync`.

You have already built this circuit. It is the first two flip-flops of
[L04's `button_sync`](../../L04/appendix/b_exercises.md), written inline there because at that
point it was the *idea* that mattered: an asynchronous input needs two flip-flops before anything
else may look at it. Here you pull those two out into a module, and the exercise is not the logic,
which you know, but everything around it.

Two things make it worth the second pass. The first is that a bare synchronizer is what most
asynchronous inputs actually need: `button_sync` adds an edge detector because a button press is an
event, but a serial line, a status flag from another clock domain, or a switch you only ever read
the level of needs the two flip-flops and nothing more. L08's serial receiver instantiates exactly
this on its `rx` pin. The second is that it takes **two generics**, and one of them is not a number.

| Generic | Type | Default | Description |
|---|---|---|---|
| `SIZE` | `natural range 1 to 15` | `1` | How many independent signals to synchronize, and therefore the width of both vector ports. |
| `PRESET` | `std_logic` | `'0'` | The value both stages take on reset. |

and these ports:

| Port | Direction | Type | Description |
|---|---|---|---|
| `clock` | in | `std_logic` | 50 MHz system clock. |
| `reset_s2_n` | in | `std_logic` | Active-low, **already synchronized** reset. A synchronizer does not synchronize its own reset; L04's `reset_sync` does that. |
| `async_in` | in | `std_logic_vector(SIZE - 1 downto 0)` | The asynchronous input or inputs, straight from outside the clock domain. |
| `sync_out` | out | `std_logic_vector(SIZE - 1 downto 0)` | The same signals, safe to use, two rising edges later. Each bit is synchronized independently. |

**a)** Implement it:
* Two internal `std_logic_vector(SIZE - 1 downto 0)` signals, one per stage.
* One process, sensitive to `clock` and `reset_s2_n`.
* On reset, drive both stages to `PRESET`, outside the clocked branch.
* On a rising clock edge, shift `async_in` through the two stages.
* Drive `sync_out` from the second stage with a concurrent assignment.

**b)** `PRESET` is a `std_logic` generic, which is the first one in this course that is not a
number, and it exists because the safe reset value depends on what the signal *means*. Only the
instantiating design knows that. Answer:
* `button_sync` synchronizes active-low buttons, so it would pass `'1'`. What would `'0'` claim
  about the buttons for the two cycles after every reset?
* A serial line idles high, so L08's receiver passes `'1'` too. What would `'0'` look like to a
  receiver watching for a start bit?
* Given both, why is the *default* `'0'` rather than `'1'`, and what does that say about who is
  responsible for getting it right?

**c)** This is also a question about what a generic costs. `SIZE` is `natural range 1 to 15` and
`PRESET` is `std_logic`, and both are fixed before synthesis runs. Using A.3's picture of what the
FPGA is actually made of, say how many flip-flops an instance at `SIZE = 4` uses, how many an
instance at `SIZE = 1` uses, and where in the built circuit `PRESET` ends up. Neither generic
appears as logic anywhere; say what happened to them instead.

**d)** Verify it with its testbench. It instantiates your module twice, once one bit wide with
`PRESET = '1'` and once three bits wide with `PRESET = '0'`, so a design that hard-codes either
generic fails. It checks that `sync_out` follows `async_in` after **exactly** two rising edges
rather than one or eventually, that each bit of a vector is synchronized on its own, and that reset
loads `PRESET` with no clock edge involved.

**Tip:** write the architecture for `SIZE = 1` in your head first, then check that every line is
already correct for a vector. The aggregate `(others => PRESET)` and a plain vector assignment both
work element-wise, so the generalization should cost no extra code.

![Module `sync`](./images/sync.png)

**Self-check:** name your entity `sync`, with generics `SIZE` (`natural range 1 to 15`, default
`1`) and `PRESET` (`std_logic`, default `'0'`), inputs `clock`, `reset_s2_n`, `async_in`
(`std_logic_vector(SIZE - 1 downto 0)`) and output `sync_out`
(`std_logic_vector(SIZE - 1 downto 0)`), declared in that order; its testbench is in
[`exercises/sync/`](../exercises/sync).

**Keep this file.** [L08](../../L08/README.md)'s serial receiver capstone instantiates it on the
`rx` pin, and asks you to copy it in.

---

## From VHDL to Hardware
The Quartus workflow is demonstrated on a real DE0-CV board during the lectures - first with the
braking assistant back in L01 - and written up in
[info/quartus_workflow.md](../../../info/quartus_workflow.md) for reference. You don't need Quartus
or a board yourself; the exercises below are about understanding what that workflow does to the
VHDL you write.

**5.** Answer each of the following, referring to
[info/quartus_workflow.md](../../../info/quartus_workflow.md) and what you saw demonstrated. One or
two sentences each.

**a)** A Quartus project needs a **top-level entity** selected before it will compile:
* What does the tool do differently with the top-level entity than with any other entity in the
  project?
* `min_of_two` from exercise 2 and its testbench are both valid VHDL. Why can only one of them
  ever be the top-level entity of an FPGA project?

**b)** Pin assignment connects a port name to a physical pin:
* Why must pins be assigned *before* compiling, rather than afterwards?
* What would `m` physically be connected to if you compiled `min_of_two` having assigned no pins
  at all?

**c)** Synthesis turns your architecture into gates on the chip:
* L02's `combo_logic` exercise had you write `x = ab + c'd` twice: once as one expression, and once
  with `c'd` named by an internal signal. What should synthesis produce for each, and why is your
  answer the same for both?
* Which of the two would you rather read six months from now?

**d)** Compilation produces warnings as well as errors:
* Why is "it compiled with no errors" a much weaker statement about an FPGA design than "it
  compiled with no errors" about a C program?
* Name one class of warning you would never ignore.

---

**6.** `parity_gen` from [Appendix A.2](./a_variables_and_hardware.md#a2-variable-process-local-storage-with-an-immediate-update)
is the worked example for this lecture, and it ships a reference testbench at
[`../parity_gen/parity_gen_tb.vhd`](../parity_gen/parity_gen_tb.vhd).

**a)** Before running anything, predict `parity` by hand for each of these inputs:
* `"00000000"`
* `"10110110"`
* `"11111111"`
* `"10000000"`

**b)** Run the reference testbench over the worked example and confirm your four predictions:

```bash
cd lectures/L05/parity_gen
ghdl -a --std=93 parity_gen.vhd parity_gen_tb.vhd
ghdl -e --std=93 parity_gen_tb
ghdl -r --std=93 parity_gen_tb --assert-level=error --stop-time=10ms
```

**c)** Take any one of those inputs and flip exactly one bit, leaving the other seven unchanged:
* What happens to `parity`?
* Explain why changing exactly one input bit must *always* invert the XOR-parity result, whichever
  bit you pick and whatever the starting value.
* This is the property that makes a parity bit able to detect a single-bit transmission error.
  What kind of error does it fail to detect, and why?

---

**7.** A colleague sends you this combinational decoder for review. It compiles, and Quartus
reports no errors.

```vhdl
architecture behaviour of level_decode is
begin
    process(sel) is
    begin
        case sel is
            when "00"   => leds <= "0001";
            when "01"   => leds <= "0010";
            when "10"   => leds <= "0100";
            when others => null;
        end case;
    end process;
end architecture;
```

**a)** Quartus emits `Warning: Inferred latch(es) for signal "leds"`. Using
[Appendix A.3](./a_variables_and_hardware.md#a3-what-the-fpga-actually-builds), explain what the tool
built and why. What did the VHDL ask for that combinational logic cannot do?

**b)** The author's defence is that `sel` is two bits, so `"11"` is the only value `when others`
can match, and the design never generates it. Give two separate reasons that argument does not
save them:
* one about what `sel` can actually hold, from
  [L01 A.4](../../L01/appendix/a_combinational_logic.md#a4-enough-vhdl-to-read-and-write-a-gate-circuit).
* one that would still apply even if `sel` really could only ever be `"00"`, `"01"` or `"10"`.

**c)** Fix it, in two different ways:
* by changing only the `when others` branch.
* by adding a single line *before* the `case` statement, leaving every branch untouched.

Which of the two would you rather maintain, and why? The second scales to a `case` with twenty
branches; the first does not.

**d)** This is a warning, not an error, and the design will often appear to work on the board.
Why does that make it more dangerous than an error rather than less?

---
