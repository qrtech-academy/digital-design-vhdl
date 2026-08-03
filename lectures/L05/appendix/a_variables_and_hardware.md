# Appendix A - Variables and What the Hardware Builds

## A.1 What this lecture is about
Every construct you need in order to describe hardware, you have already used: `entity` and
`architecture` in L01, `std_logic_vector`, `process` and `case` in L02, the clocked process and the
scheduling rule in L03, subcomponents and generics in L02 and L04.

Two things are left, and they are the two hardest to work out on your own:
* The first is `variable`, the one construct the course has not needed until now:
  * It looks like a signal and behaves nothing like one, and the difference is exactly the kind
    that produces a design which simulates plausibly and is quietly wrong.
  * A.2 works through the case where it bites.
* The second is what any of this actually becomes:
  * Since L01 you have taken it on trust that the synthesis tool builds the circuit you
    described. It does, but not out of anything you would recognize.
  * A.3 opens the box. An FPGA turns out to contain no gates at all, which is why L02's Karnaugh
    maps bought you less than they seemed to. Your clock has a speed limit, and something specific
    sets it. And a `case` with a branch missing will quietly hand you a memory element nobody
    asked for.

Neither section answers "is my logic right?" You have been answering that since L01. They answer the
two questions after it: is this what I meant, and will it fit and run.

---

## A.2 `variable`: process-local storage with an immediate update
A `variable` is declared inside a `process`, between `process(...)` and `begin`. The critical
difference from a `signal`: variable assignment uses `:=` and takes effect
**immediately**, so the very next statement that reads it sees the updated value, exactly like an
assignment in C. There is no scheduling, none of the wait-until-the-process-suspends delay that
L03 A.6 spelled out for signals, and no "last assignment wins".

| | `signal` (`<=`) | `variable` (`:=`) |
|---|---|---|
| Declared | Architecture's declarative part | Process's declarative part |
| Visible from | Anywhere in the architecture | Only within its own process |
| Update timing | Scheduled: applied when the process next suspends | Immediate: applied before the next statement |
| Repeated assignment in one pass | Only the last one survives; earlier ones are discarded | Every one takes effect, in order |

### Why this actually matters: an XOR-parity generator
An entity computing the XOR-parity of an 8-bit input, `'1'` if `bits` has an odd number of set bits:

```vhdl
entity parity_gen is
    port(bits  : in  std_logic_vector(7 downto 0);
         parity: out std_logic);
end entity;
```

Coming from software, the first instinct is to accumulate the running XOR in a loop, using a signal
as the accumulator:

```vhdl
-- Don't do this: shown to demonstrate why it doesn't work.
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

Trace one pass, using the scheduling rule from
[L03 A.6](../../L03/appendix/a_flip_flops_and_registers.md#a6-the-synchronous-process-template-in-vhdl):
every read of `parity_s` returns whatever it held *before this pass started* (call it `old_parity`),
and only the last assignment survives.
* `parity_s <= '0';` schedules `'0'`. Not yet applied.
* `i = 7` (`bits'range` on `(7 downto 0)` runs high-to-low): reads `parity_s`, gets `old_parity`,
  because the `'0'` has not applied. Schedules `old_parity xor bits(7)`, discarding the `'0'`.
* `i = 6`: reads `parity_s`, again `old_parity`. Schedules `old_parity xor bits(6)`, discarding the
  previous one.
* ...and so on for every iteration...
* `i = 0`, the last statement in the pass: still reads `old_parity`, schedules
  `old_parity xor bits(0)`, discarding everything before it.
* The process suspends and `parity_s` becomes `old_parity xor bits(0)`, the only one of nine
  scheduled assignments that survived.

The result depends only on `bits(0)` and on whatever `parity_s` happened to already hold. Seven
iterations and the initial `'0'` were computed and thrown away. This is not a corner case: it is what
a signal-as-accumulator *always* does, because every iteration reads the same frozen value and only
the textually last assignment is kept.

The same computation with a `variable`:

```vhdl
architecture behaviour of parity_gen is
signal parity_s: std_logic;
begin
    parity <= parity_s;

    PARITY_PROCESS: process(bits) is
        variable acc: std_logic;
    begin
        acc := '0';
        for i in bits'range loop
            acc := acc xor bits(i);
        end loop;
        parity_s <= acc;
    end process;
end architecture;
```

Now `acc := '0'` applies immediately; `i = 7` reads `'0'`, XORs in `bits(7)` and updates `acc` at
once; `i = 6` reads that just-updated value, and so on through every iteration. The loop ends with
`acc` holding the true XOR of all eight bits, and `parity_s <= acc;` schedules that one correct
value, the only assignment to `parity_s` in the pass.

This is the on-disk worked example: [`parity_gen/parity_gen.vhd`](../parity_gen/parity_gen.vhd).

### What that loop is not
It is not eight steps the hardware performs one after another. This is where a C background misleads
hardest, so it is worth stating outright:
A `for` loop whose bounds are fixed at elaboration is **unrolled** by the synthesis tool. Those
eight iterations become eight XOR gates in a chain, all settling within one propagation delay, in
the same clock cycle. There is no counter for `i`, no branch, no iteration in time. The loop writes
eight gates in three lines; it does not do eight things in sequence.

That is also why `acc`, which reads like a running total, costs no storage at all. It never has to
survive a clock edge: each of its values is just the wire between two of those XOR gates. A
`variable` is the right tool precisely because it never outlives one pass.

The same goes for `bits'range`. The `'range` **attribute** gives the index range of `bits`, here
`7 downto 0`, so the loop covers every bit without writing the bounds twice. It is resolved at
elaboration, like everything else in the loop header, which is exactly why the tool can unroll it.
`for i in 0 to 1 loop` in L03's `led_toggle.vhd` means the same thing: both bits get their own gates
and both update in the same cycle.

### The rule of thumb
* Use a `variable` for a scratch computation consumed entirely within one pass: loop accumulators,
  temporary swaps, intermediate values handed off to a signal at the end, exactly like `acc`.
* Use a `signal` for anything another process or the outside world reads, and anything that must
  hold its value across separate passes (a counter, or a shift register's stored bits, both in L06).

A variable *can* retain its value between passes through the same process, behaving like static
local storage rather than a fresh local each time, so it is possible to build state with one. But
because its updates are immediate rather than scheduled, it behaves differently from a signal used
the same way, particularly for anything modelling a chain of registers stepping one stage per clock
edge. If state genuinely needs to persist and be read by other logic, reach for a `signal`: the
scheduled-update semantics is what makes L06's counters and shift registers work.

---

## A.3 What the FPGA actually builds

### The two things the fabric is made of
An FPGA is not a blank slate onto which gates are etched. It is a fixed grid of identical small
blocks, manufactured before anybody wrote your VHDL, and "synthesis" is working out how to configure
them so they behave like the circuit you described. Two matter here:
* A **look-up table**, or **LUT**: a tiny memory, typically four to six inputs and one output. Load
  it with the truth table of any Boolean function of those inputs and it computes that function.
  This is the honest answer to "what does a gate become on an FPGA": nothing becomes a gate. A
  four-input LUT computes `a and b`, `a xor b or (c and not d)`, or any other function of up to four
  inputs at exactly the same cost, because in every case it is the same block holding a different
  table.
* A **flip-flop**: one bit of clocked storage, sitting next to each LUT.

On the DE0-CV's Cyclone V these come packaged together as an **ALM**, holding a fracturable
six-input LUT, usable as one six-input function or two smaller ones, plus four flip-flops. That is
the unit the Quartus fitter report counts, which is why it talks about ALMs rather than gates.

That is nearly the whole story. `register4` becomes four flip-flops, `mux_8to1` a handful of LUTs,
and L08's state machine LUTs feeding the flip-flops that hold the state.

It also explains something from L02 that would otherwise look like a broken promise:
The course had you minimize expressions with Karnaugh maps to save gates, then never mentioned the
saving again. On an FPGA a four-input function costs one LUT whether you minimized it or not.
Minimization still matters: it is how you understand a circuit, it is exactly right for the
discrete-logic and ASIC flows K-maps were invented for, and reducing a function below the LUT's
input width is what stops it needing a second level of LUTs. But on this board it usually buys you
nothing, and it is better to know that than to wonder.

### Why a clock has a speed limit
Signals take time to get through a LUT and along the wires between blocks. That **propagation
delay** is why a clock cannot go arbitrarily fast.

Picture the shape every design in this course has, a flip-flop, some combinational logic, another
flip-flop:
* On a rising edge the first presents a new value, which has to travel through every LUT and wire
  between the two and *settle* before the next edge arrives.
* If it has not, the second flip-flop captures a value that is still changing, and the design does
  the wrong thing reliably and mysteriously.

So the clock period has to cover three things:
* The first flip-flop's **clock-to-Q** delay: the time between the edge and its output actually
  changing.
* The **combinational delay** through the LUTs and wires between the two.
* The second flip-flop's **setup time**.

The slowest such path is the **critical path**, and one over that total is the **Fmax**.

Quartus computes Fmax for you, in the timing analyzer stage of
[the Quartus workflow](../../../info/quartus_workflow.md), but only if you tell it what the clock
is. That means an `.sdc` constraints file with a `create_clock` on the `50 MHz` input. Without one
the analyzer has no period to compare anything against, so it reports every path as unconstrained
and gives you no Fmax at all. Separately, a design that "fails timing" is one where some path turned
out slower than the period you did declare.

**None of that is part of this course.** You will not write an `.sdc`, read a timing report, or meet
a design that fails timing, because every design here fits inside 20 ns with room to spare. It is
worth knowing the step exists and what it needs, so that you recognize it the first time a design of
yours gets close to the limit.

Two consequences worth carrying forward:
* **Deep combinational logic costs you speed, not the number of flip-flops.** Chaining a long
  expression between two registers lengthens the critical path; splitting it so part of the work
  happens on one cycle and the rest on the next shortens it. That trade, more registers for a faster
  clock, is the single most common move in high-speed digital design.
* **`50 MHz` is a 20 ns budget.** That is the number every path in your design is racing against,
  and it is a lot of time at these speeds.

### The latch you get by accident
L03 built a D latch, showed it was transparent while enabled, then set it aside in favour of the
flip-flop. Here it comes back uninvited.

[L02 A.5](../../L02/appendix/a_larger_networks.md#a5-multiplexers-in-vhdl-process-and-case)
required a `when others` on every `case`, and gave the language's reason: a `case` has to cover
every value of its selector's type. The general rule behind it is that a combinational `process`
must assign its output on *every* path through it, and that reason is now sayable:
* VHDL requires a signal to keep its old value if nothing assigns a new one.
* If some path through your process leaves `x` unassigned, you have said `x` must *remember* its
  previous value on that path, and remembering is not something combinational logic can do.
* So the tool builds the only thing that can: a latch, exactly the one from L03 A.2.

That is an **inferred latch**, and it is almost never what anybody meant. It is a warning rather
than an error, the design will often appear to work, and the message is worth recognizing:

```text
Warning: Inferred latch(es) for signal "x"
```

The fix is never to add a latch on purpose. It is to assign the signal on every path, which is the
rule you were already following.

---

## A.4 Looking ahead
Nothing in L06 to L08 introduces a new idiom. Counters, shift registers and timers all hold state
across clock edges using
[L03's clocked process](../../L03/appendix/a_flip_flops_and_registers.md#a6-the-synchronous-process-template-in-vhdl)
and the scheduling rule above, and L08's state machines add only an enumerated type and a `case` on
it. What changes is what the state is used for.

Two things to watch for. L06's `serial_rx8` is the first design whose correctness you cannot check
by eye on an LED, which is where the provided testbenches stop being a formality. And
[L04's generic](../../L04/appendix/a_metastability_and_synchronization.md#a8-generics-one-module-several-sizes)
goes to work immediately: L07's `timer` uses one for its tick count, and `walking_led` instantiates
that timer alongside `reset_sync` and `button_sync`, writing almost no logic of its own.

---
