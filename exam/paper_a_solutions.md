# Paper A - Solutions

Marks are shown per part. Method carries them: a correct derivation with a slip in it is worth more
than a correct answer with no working, and later parts consume earlier ones, so an error should be
followed through rather than penalised twice.

Where a part asks for VHDL, mark the **hardware described**, not the syntax. A listing with a
missing semicolon and the right circuit in it scores full marks; a listing that compiles and infers
a latch does not.

---

## Question 1 - A table, a network, and a module (12 marks)

### (a) 4 marks

**Straight off the table.** Four rows are `1`, so four AND-terms, each carrying every input directly
where it is `1` in that row and primed where it is `0`:

```text
X = A'BC' + AB'C' + ABC' + ABC
```

*(1 mark)*

**Simplified.** The term `ABC'` is needed three times, which the idempotent law `A + A = A` supplies
for free:

```text
X = A'BC' + AB'C' + ABC' + ABC' + ABC' + ABC        (idempotent, twice)
  = (A' + A)BC' + (B' + B)AC' + AB(C' + C)          (distributive)
  = 1·BC' + 1·AC' + AB·1                            (complement)
  = BC' + AC' + AB                                  (identity)
```

*(2 marks)*

**The gate count.**

| Form | Gates |
|---|---|
| `A'BC' + AB'C' + ABC' + ABC` | 3 NOT, 4 three-input AND, 1 four-input OR = **8** |
| `BC' + AC' + AB` | 1 NOT, 3 two-input AND, 1 three-input OR = **5** |

*(1 mark)*

Worth noticing and worth a comment rather than a mark: `X = AB + AC' + BC'` is the **majority vote**
of `A`, `B` and `C'`. Check it against the table row by row and every row agrees. That is the same
observation L01 A.2 makes when `A'B + AB'` turns out to be one XOR gate: reading a table gives you a
correct network, and recognizing the function gives you a smaller one.

Accept any correct simplification path. Do not require these particular law names, but do require
*some* justification per step: an answer that jumps from four terms to three with no working is a
remembered answer, not a derived one.

### (b) 3 marks

Both signals are active-low, so "asserted" means `0`:

```text
go = button_n' · enable_n'
```

*(1 mark)*

De Morgan, in the form `A'B' = (A + B)'`:

```text
go = (button_n + enable_n)'
```

which is a **NOR gate**, one gate for the whole function.
*(1 mark)*

```vhdl
go <= (not button_n) and (not enable_n);   -- the expression as derived
go <= not (button_n or enable_n);          -- the same thing after De Morgan
```

Synthesis produces **the same circuit for both**, and on the Cyclone V that circuit is not a NOR
gate either: it is one two-input LUT loaded with the table (Question 5c). The two lines are two
spellings of one function, and the tool does not care which you wrote.
*(1 mark)*

This is the everyday use of De Morgan the course leans on: an active-low signal meeting logic
written for active-high, which in a course where every button and every reset is active-low is most
of them.

### (c) 3 marks

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity gate_net is
    port(a, b, c: in  std_logic;
         x      : out std_logic);
end entity;

architecture behaviour of gate_net is
begin
    x <= (b and not c) or (a and not c) or (a and b);
end architecture;
```

*(2 marks: 1 for the entity with the ports in the stated order, 1 for an architecture matching the
candidate's own answer to (a))*

Naming the intermediate terms in internal signals is equally correct and synthesizes identically.

**What the clauses buy.** `std_logic` is not built into VHDL. It comes from the `std_logic_1164`
package in the `ieee` library, and so do the `and`/`or`/`not` operators as they apply to it. Without
those two lines the port types do not exist and the file does not analyze.
*(1 mark)*

Follow through an incorrect (a): an architecture that faithfully implements a wrong equation loses
nothing here.

### (d) 2 marks

**The concurrent assignment.** It describes a **wire**, or rather the gate driving one: a standing,
continuous relationship that holds at all times, exactly like the piece of hardware it stands for.
It is not executed once and it has no position in a sequence; `x` is `a or b` for as long as the
circuit exists. Two concurrent assignments in one architecture are two pieces of hardware operating
at the same time, not two steps.
*(1 mark)*

**The two values.** `'U'` is uninitialized: nothing has driven this signal at all since the
simulation began. `'X'` is unknown: two things are driving it and they disagree. Neither is a level
a synthesized wire can carry, so neither is a value your design computed - each is the simulator
telling you something is wrong, and the correct reaction is to find out what, not to work around the
symbol.
*(1 mark)*

---

## Question 2 - The map, the multiplexer, and the module used twice (14 marks)

### (a) 5 marks

The map, `AB` down the rows and `CD` across the columns, both in Gray-code order `00, 01, 11, 10`:

| `AB` \ `CD` | `00` | `01` | `11` | `10` |
|---|---|---|---|---|
| `00` | **1** |  |  | **1** |
| `01` |  | **1** | **1** |  |
| `11` |  | **1** | **1** |  |
| `10` | **1** |  |  | **1** |

*(1 mark for a correctly filled map in Gray-code order)*

**Two groups of four.**

| Group | Cells | Constant across the group | Term |
|---|---|---|---|
| The four corners | `0000`, `0010`, `1000`, `1010` | `B = 0`, `D = 0` | `B'D'` |
| The centre block | `0101`, `0111`, `1101`, `1111` | `B = 1`, `D = 1` | `BD` |

The corner group is the one that has to be seen: it wraps **both** ways, top-to-bottom and
left-to-right, which is legal precisely because the Gray-code ordering makes the last row adjacent
to the first and the last column adjacent to the first. A candidate who instead writes four groups
of two here has read the map as a grid rather than as a torus, and has lost the mark for this part
but nothing later.
*(2 marks: 1 per group, including the surviving variables)*

```text
X = B'D' + BD
```

*(1 mark)*

**The rest of the question.** Eight rows are `1`, so a direct L01-style reading gives **eight**
AND-terms of four literals each. `A` and `C` do not appear in the answer at all: the function does
not depend on them. And `X = 1` exactly when `B` and `D` are equal, so the whole thing is a single
**XNOR** gate on `B` and `D`.
*(1 mark)*

That last step is the same one L01 A.2 makes with `A'B + AB'`, and it is what the technique is for:
the map found a two-term equation, and recognizing the two-term equation found a one-gate circuit.

### (b) 4 marks

```vhdl
architecture behaviour of mux4 is
begin
    MUX_PROCESS: process(inputs, sel) is
    begin
        case (sel) is
            when "00"   => x <= inputs(3);
            when "01"   => x <= inputs(2);
            when "10"   => x <= inputs(1);
            when "11"   => x <= inputs(0);
            when others => x <= '0';
        end case;
    end process;
end architecture;
```

*(2 marks: 1 for the four branches mapping the right way round, 1 for a `process` with both `inputs`
and `sel` in the sensitivity list. Deduct nothing for a label, or for its absence.)*

**Why the `case` needs a process.** `case`, like `if` and `for`, is a **sequential** statement,
legal only inside a process. An architecture body holds concurrent statements: standing descriptions
of hardware, all active at once. A process is how a block of sequential statements is packaged up so
that it can be one of those concurrent statements.
*(1 mark)*

**What `when others` protects against.** It is a **language** requirement, not a defensive one. VHDL
insists a `case` cover every value of its selector's *type*, and `sel` is a `std_logic_vector`,
whose elements have nine values each rather than two, so `"00"`, `"01"`, `"10"` and `"11"` do not
make the `case` exhaustive. It is not a claim about the wire: a synthesized net carries a `0` or a
`1` and nothing else, and the other values belong to the simulator, where a signal sitting at `'U'`
or `'X'` is a bug rather than a level.
*(1 mark)*

An answer arguing that `when others` "catches an illegal selector on the board" has the wrong reason
and should get no more than half the mark, even though the line it writes is identical.

### (c) 3 marks

```vhdl
architecture structure of mux4 is
signal x_high, x_low: std_logic;
begin
    -- sel(0) chooses within each pair.
    mux2_high: entity work.mux2
        port map(inputs(2), inputs(3), sel(0), x_high);

    mux2_low: entity work.mux2
        port map(inputs(0), inputs(1), sel(0), x_low);

    -- sel(1) chooses between the two pairs.
    mux2_out: entity work.mux2
        port map(x_low, x_high, sel(1), x);
end architecture;
```

*(2 marks: 1 for three instances with unique labels and two internal signals, 1 for getting the
`a`/`b` order right against `mux2`'s `sel = '1'` selecting `a`)*

Check it against the specification one selector value at a time, which is the check worth writing
down: `"00"` takes `x_high` and within it `inputs(3)`; `"01"` takes `x_high` and `inputs(2)`; `"10"`
takes `x_low` and `inputs(1)`; `"11"` takes `x_low` and `inputs(0)`.

**The rest.** The FPGA ends up with **three** copies of `mux2`'s logic, exactly as writing the logic
three times would. Instantiating a module more than once saves source, not silicon.

And yes, this architecture and part (b)'s describe the same hardware, or near enough that the tool
will not distinguish them: both are a four-input multiplexer, and a fitter given either one packs it
into LUTs the same way. (b) describes the **intent** and lets the tool find the gates; (c) describes
the **structure** and hands the tool a wiring diagram. That gap is most of what a hardware
description language buys you.
*(1 mark)*

### (d) 2 marks

The testbench connects to the module **by position**, not by name, so the entity's port declaration
order is part of its interface. A wrong order fails in one of two ways, and neither says "wrong
order":

* **Different types or widths.** Analysis stops with a message like
  `can't associate "sel" with port "sel"`, pointing at the testbench's `port map` line. You find out
  at `ghdl -a`, immediately.
* **Same type**, several `std_logic` ports swapped, say. It analyzes and elaborates quite happily,
  then fails at run time as an ordinary assertion failure that reads exactly like a logic bug in the
  architecture. You find out at `ghdl -r`, after spending time in the wrong file.

*(1 mark per case, including when it is caught)*

The practical consequence, which is why the exercises spell their ports out in order: a testbench
that fails on the very first case it checks is a reason to reread the port order before hunting
through the architecture.

---

## Question 3 - What a clock edge does, and when an assignment happens (13 marks)

### (a) 3 marks

**The latch** is **level-sensitive**: while `enable` is high it is transparent and `Q` follows `D`
continuously; while `enable` is low it holds. It changes its output at any time during the entire
enabled window.

**The flip-flop** is **edge-triggered**: it samples `D` at the single *instant* the clock
transitions and holds that value for the rest of the period, whatever `D` does.
*(1 mark)*

**Why synchronous designs use the flip-flop.** Because the latch is transparent for a whole clock
phase, any glitch on `D` during that phase passes straight through, and guaranteeing data is stable
across an entire phase is far harder than guaranteeing it around one instant. Every flip-flop
changing at the same well-defined instants is also what makes a large circuit's timing analyzable:
you can reason one clock cycle at a time instead of tracking every signal continuously.
*(1 mark)*

**`D` rises and falls between two edges.** The latch follows it up and back down, so `Q` shows the
pulse (during whatever part of it the clock is high). The flip-flop shows **nothing at all**: no
edge happened while `D` was high, so `Q` never moves. Both are behaving correctly; they are
answering different questions.
*(1 mark)*

### (b) 4 marks

A signal assignment does not take effect when its line runs. It **schedules** a value, applied only
once the process suspends, so every read during the pass returns the value the signal held *coming
into* the edge. `c <= b` therefore reads the old `b`, not the one being scheduled on the line below.

| Edge | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| `a` | 1 | 0 | 1 | 1 | 0 | 0 |
| `b` after | **1** | **0** | **1** | **1** | **0** | **0** |
| `c` after | **0** | **1** | **0** | **1** | **1** | **0** |

*(2 marks for the table; 1 if `b` is right and `c` is shifted the wrong way or not at all)*

**The hardware.** Two flip-flops in a chain. Every signal assigned inside a clocked process becomes
a flip-flop, one bit each, and here `a` reaches `b` after one edge and `c` after two.
*(1 mark)*

**Swapping the lines changes nothing.** Neither assignment can observe the other's result, because
both read the pre-edge values and both take effect together when the process suspends. Order does
not matter between assignments to *different* signals in one clocked process, which is the opposite
of the sequential reading the word "process" invites, and it is why a chain of flip-flops can be
written in any order.
*(1 mark)*

Two related rules are worth a comment if a candidate volunteers them: assigning the **same** signal
twice in one pass keeps only the last assignment, and a `variable` behaves the other way round on
both counts, which is Question 5.

### (c) 3 marks

```vhdl
signal req_prev: std_logic;
...
    -- One gate: high for the single cycle where req is high and was not.
    req_edge <= req and not req_prev;

    REQ_PROCESS: process(clock, reset_n) is
    begin
        if (reset_n = '0') then
            req_prev <= '0';
        elsif (rising_edge(clock)) then
            req_prev <= req;
        end if;
    end process;
```

*(2 marks: 1 for the flip-flop holding the previous value with an asynchronous active-low reset, 1
for `current AND NOT previous` as the rising-edge form. A registered `req_edge` inside the process
is also correct hardware, one cycle later; accept it if the candidate says so.)*

**How long it is high.** Exactly **one clock cycle**: the one immediately after the transition,
because `req_prev` only catches up at the *next* edge, at which point `req` and `req_prev` agree
again and the gate goes low.

**Why `'0'` here.** The reset value has to be the signal's **idle** level, so that coming out of
reset does not look like a transition. `req` is active-high and idles low, so `req_prev` resets to
`'0'`. `led_toggle`'s buttons are active-**low** and idle at `1`, so its `button_prev_n` resets to
`"11"`; reset it to `"00"` and the circuit comes out of reset claiming both buttons are already held
down.
*(1 mark)*

### (d) 3 marks

**The rule.** `clock` is the only signal in the sensitivity list, unless the design has an
asynchronous reset, in which case that reset joins it and nothing else does.

**The reason.** The process has no business reacting to anything but the events that can change its
outputs. A flip-flop's output changes at a clock edge, and an asynchronously reset one also changes
the moment the reset is asserted, with no clock edge involved, so the reset has to be able to wake
the process on its own. Everything else the process reads is sampled *at* the edge and has no
business waking it.
*(1 mark)*

**Adding `d` to the list.** In **simulation**, the process now also runs whenever `d` changes; since
`rising_edge(clock)` is false on those runs, nothing is assigned, and the behaviour is unchanged. In
**hardware** nothing changes either: the sensitivity list is not synthesized. So this one costs
nothing but noise, and it is worth saying so plainly, because the reflex is to assume every
sensitivity-list mistake is fatal.
*(1 mark)*

**Leaving `reset_n` out.** Now the two disagree. In **simulation** the process only runs on `clock`
events, so the reset is no longer asynchronous: asserting it does nothing until the next clock edge,
and a reset asserted and released between two edges is missed entirely. In **hardware** the tool
reads the `if (reset_n = '0') then ... elsif (rising_edge(clock))` structure and builds the
asynchronous reset anyway, or refuses the process. Either way the simulator and the chip no longer
agree, which is worse than being wrong in one place.
*(1 mark)*

---

## Question 4 - The input you do not control (13 marks)

### (a) 3 marks

**Setup and hold** are the two halves of a window around the active clock edge: the **setup time**
is how long `D` must already be stable *before* the edge, and the **hold time** is how long it must
stay stable *after* it.

**What happens inside.** A flip-flop is built from cross-coupled gates that snap to `0` or `1` when
the clock samples. An input changing inside the window can leave that feedback loop balanced between
the two states, neither fully high nor fully low, for longer than expected: **metastability**. A
ball balanced on top of a hill rolls down eventually, but when it commits, and to which side, is not
predictable from the moment it was placed there, and while it is still balanced its position is not
a valid digital value at all.
*(1 mark)*

**Why an asynchronous input cannot be promised to miss the window.** Because you do not control when
it changes. A push button, an external reset, or a line from another clock domain changes when the
outside world decides to, with no fixed relationship to your clock, so no amount of design makes the
window unreachable.
*(1 mark)*

**What the actual failure is.** Not a wrong answer. Sampling a signal that genuinely was in the
middle of a transition and getting either level back is a legitimate outcome and is harmless: both
answers were true at some instant inside the window. The failure is the **delay before there is an
answer at all**, and specifically what happens if the unresolved voltage reaches downstream logic
before it settles, because then different gates can legitimately read it differently at the same
instant. One part of the circuit increments and another does not; a state machine lands in an
impossible state. The disagreement is the bug.
*(1 mark)*

An answer that says "it gives the wrong value" has missed the whole point of A.2 and scores nothing
for this third mark, however fluent the rest is.

### (b) 4 marks

```text
async_in
   │
   ▼
 [FF1] ──────► [FF2] ──────► synchronized, safe to use
   (may go        (extremely likely
   metastable)     to be stable)
```

Only **FF2's** output may be used elsewhere. FF1 is the flip-flop exposed to the asynchronous input,
so it is the one that may go metastable; its output has an entire clock period to settle before FF2
samples it, and by then it almost always has. FF1's output used directly is the unresolved node
itself, which is the failure in (a).
*(1 mark)*

**The terms.**

| Term | What it is |
|---|---|
| `t_r` | The resolution time a stage is given, roughly one clock period |
| `tau` | A property of the flip-flop: how fast a metastable value decays |
| `T_w` | A property of the flip-flop: the width of the window around the edge in which an input can provoke metastability at all |
| `f_clock` | The clock rate of the receiving domain |
| `f_data` | How often the asynchronous input actually changes |

*(2 marks, or 1 for naming three or four of the five)*

**Which input makes the case for a third stage.** The **10 MHz line**. It is `f_data` that separates
the two, and `1 Hz` against `10^7 Hz` is **seven orders of magnitude** in that term alone; `t_r`,
`tau`, `T_w` and `f_clock` are identical for both, because they are properties of the flip-flop and
the receiving clock, not of the input. So the case for a third stage is a question about the input,
not about the clock.

**What it costs.** One more clock cycle of latency, against a numerator that grows *exponentially*
with each added `t_r`. That asymmetry is why extra stages exist at all.
*(1 mark)*

### (c) 3 marks

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity reset_sync is
    port(clock, reset_n: in  std_logic;
         reset_s2_n    : out std_logic);
end entity;

architecture behaviour of reset_sync is
signal reset_s1_n, reset_s2_n_s: std_logic;
begin
    reset_s2_n <= reset_s2_n_s;

    process(clock, reset_n) is
    begin
        if (reset_n = '0') then
            reset_s1_n   <= '0';
            reset_s2_n_s <= '0';
        elsif (rising_edge(clock)) then
            reset_s1_n   <= '1';
            reset_s2_n_s <= reset_s1_n;
        end if;
    end process;
end architecture;
```

*(2 marks: 1 for both stages forced to `'0'` in the asynchronous branch, 1 for the clocked branch
shifting a constant `'1'` in rather than shifting `reset_n` in)*

An internal signal is needed only because an output port cannot be read back; a candidate who
assigns `reset_s2_n` directly and never reads it is equally correct.

**The pattern: assert asynchronously, release synchronously.**

* **Assert.** When `reset_n` drops, both stages are forced to `0` immediately, with no dependency on
  the clock. A reset that waited for a clock edge would defeat its own purpose: it has to take
  effect the instant it is needed, clock or no clock.
* **Release.** When `reset_n` returns to `1` the reset condition does not vanish everywhere at once.
  It shifts out through the two stages like any other asynchronous input, so the signal the design
  actually uses releases cleanly on a clock edge along with everything else.

*(1 mark for both halves)*

**Without the synchronous release**, in a design of a dozen flip-flops: the reset's rising edge
arrives at each of them at a slightly different time relative to the clock, so some leave reset on
one edge and some on the next, and for one cycle the design holds a combination of state that no
correct execution ever produces. `serial_rx8` is the concrete case the course gives: its shift
register and its bit counter are a dozen flip-flops between them, and a receiver that starts
counting a byte one cycle before it starts shifting one has been broken by its own reset.

### (d) 3 marks

**What is safe.** Each bit individually. Every bit gets a full clock period to resolve, so no
*single* bit is metastable when the receiving domain reads it. Metastability, per bit, is solved.

**What is not.** The bits are not safe **together**. Each one independently resolves to the old or
the new value on the same edge, so the receiver can sample a combination that was never on the bus.
The double-flop answer synchronizes **one bit**, and that word is the whole limit.
*(1 mark)*

**A concrete value.** The counter stepping from `0111` to `1000` changes all four bits at once. Each
synchronizer independently lands on the old or the new bit, so the receiver can read `1111`, or
`0000`, or any of the other fourteen combinations - values the counter held neither before nor after
the step.
*(1 mark)*

**The three fixes.**

* A **handshake**: the sender holds the bus still and raises a single-bit request, which *is* safe
  to synchronize; the receiver reads the stable bus and acknowledges.
* A **FIFO** with synchronized pointers, which is the same idea industrialized.
* **Gray coding** the counter, so that only one bit ever changes per step and there is no
  combination to get wrong.

Gray code is the one that removes the problem **by construction**: there is no instant at which two
bits are in flight, so a per-bit synchronizer can only return the old value or the new one, both of
which are values the counter really held. The other two work by making sure nobody looks while the
bus is moving.
*(1 mark)*

None of this is needed anywhere in this course, which never crosses a clock domain with a bus.
Knowing that the two-flop answer stops at one bit is the examinable part.

---

## Question 5 - The accumulator that isn't, and the latch nobody asked for (13 marks)

### (a) 4 marks

Two rules do all the work: a signal assignment **schedules** rather than applies, so every read
during the pass returns the value held *before the pass started*; and assigning the same signal more
than once in one pass keeps only the **last** assignment.

`bits'range` on `(7 downto 0)` runs high to low, and `bits = "01000000"`, so only `bits(6)` is
`'1'`.

| Step | `bits(i)` | Read from `any_s` | Scheduled | Survives? |
|---|---|---|---|---|
| `any_s <= '0'` | - | - | `'0'` | no |
| `i = 7` | `0` | `'0'` | `'0'` | no |
| `i = 6` | `1` | `'0'` | `'1'` | no |
| `i = 5` | `0` | `'0'` | `'0'` | no |
| `i = 4` | `0` | `'0'` | `'0'` | no |
| `i = 3` | `0` | `'0'` | `'0'` | no |
| `i = 2` | `0` | `'0'` | `'0'` | no |
| `i = 1` | `0` | `'0'` | `'0'` | no |
| `i = 0` | `0` | `'0'` | `'0'` | **yes** |

*(2 marks for the trace, of which 1 is for reading `'0'` in **every** row rather than the previous
row's scheduled value)*

`found` ends up `'0'`. The correct answer is `'1'`: `bits(6)` is set. Nine assignments were computed
and eight of them were thrown away.

**Why this is not an accumulator.** Every iteration reads the same frozen value, so no iteration can
see the previous one's result, and only the textually last assignment survives. The final value
depends on exactly two things: whatever `any_s` already held, and `bits(0)`. The loop is doing no
accumulating at all - it is computing the same expression eight times with a different last operand
and discarding all but one of the answers.
*(1 mark)*

**When it happens to be right.** The architecture computes `old_any_s or bits(0)` where the correct
answer is the OR of all eight bits. So:

* **Whenever `bits(0) = '1'` it is right**, unconditionally, because both expressions are then
  `'1'`. That is **half of all 256 inputs**.
* When `bits(0) = '0'` it is right only by luck: when the value it happened to be carrying already
  matches the correct answer.

That is what makes this bug dangerous rather than merely wrong. `"11111111"` passes. `"00000001"`
passes. Anything ending in a `1` passes. A smoke test of a few "obvious" inputs has a good chance of
reporting success, and the design fails on the ones nobody typed.
*(1 mark)*

A candidate who adds that in a real simulation `any_s` starts at `'U'` rather than `'0'`, so the
first pass propagates `'U'` and L01's "a signal sitting at `'U'` is a bug, not a value" fires
immediately, has understood more than the question asked and should be credited within the marks
available.

### (b) 3 marks

```vhdl
architecture behaviour of any_set is
signal any_s: std_logic;
begin
    found <= any_s;

    ANY_PROCESS: process(bits) is
        variable acc: std_logic;
    begin
        acc := '0';
        for i in bits'range loop
            acc := acc or bits(i);
        end loop;
        any_s <= acc;
    end process;
end architecture;
```

*(1 mark: a `variable`, assigned with `:=`, cleared at the top of every activation, handed to the
signal once at the end)*

**Clock cycles: zero.** This is a combinational process. The loop's bounds are fixed at elaboration,
so the synthesis tool **unrolls** it: the eight iterations become a chain of OR gates that all
settle within one propagation delay, in the same clock cycle. There is no counter for `i`, no
branch, and no iteration in time. The loop writes gates in three lines; it does not do eight things
in sequence.
*(1 mark)*

**Storage: none.** `acc` reads like a running total but never has to survive a clock edge. Each of
its values is simply the wire between two of those OR gates, which is exactly why a `variable` is
the right tool: it never outlives one pass.
*(1 mark)*

An answer of "eight clock cycles" is the C reading of the loop and scores nothing for the second and
third marks, however well the code is written.

### (c) 3 marks

A Boolean function becomes a **look-up table**: a tiny memory, loaded with the function's truth
table, which then computes it. Nothing becomes a gate.

The fabric is made of **LUTs and flip-flops**, one bit of clocked storage sitting beside each LUT.
On the DE0-CV's Cyclone V they are packaged as an **ALM**, holding a fracturable six-input LUT plus
four flip-flops, and the ALM is what the Quartus fitter report counts - which is why it talks about
ALMs rather than gates.
*(2 marks)*

**What the map bought.** On this board, in LUT count, nothing. A four-input function costs one LUT
whether you minimized it or not, because in every case it is the same block holding a different
table. What Question 2's map actually bought was the *knowledge* that `A` and `C` are irrelevant and
the function is one XNOR - which no amount of LUT packing would have told you, and which is the sort
of thing you need before you can tell whether a specification is the one you meant.

What minimization still buys anywhere: it is how you understand a circuit; it is exactly right for
the discrete-logic and ASIC flows Karnaugh maps were invented for; and reducing a function below the
LUT's input width is what stops it needing a second level of LUTs.
*(1 mark)*

### (d) 3 marks

**What the tool built: a latch**, one per bit of `leds`, exactly the D latch of L03 A.2.

**Why it had no choice**, in two steps:

1. VHDL requires a signal to keep its old value if nothing assigns a new one. The `when others`
   branch assigns nothing, so on that path the design has said `leds` must **remember** its previous
   value.
2. Remembering is not something combinational logic can do. The only element that can is a latch, so
   that is what gets built.

*(1 mark)*

**Two fixes.**

```vhdl
        when others => leds <= "0000";      -- assign on every path, in the branch
```

```vhdl
    leds <= "0000";                          -- a default before the case; every branch overrides it
    case sel is
        ...
```

*(1 mark for both)*

The second is the one to prefer, and the reason is maintenance rather than hardware: it scales to a
`case` with twenty branches and stays correct when somebody adds a twenty-first, whereas the first
has to be got right again every time the `case` grows. Both synthesize to the same combinational
logic.

**Why a warning is more dangerous than an error.** An error stops you. A warning does not, and the
design will often appear to work on the board, because the latch happens to be holding the right
value most of the time - so the bug ships, and it surfaces later as an intermittent fault in a
circuit that "compiled cleanly". "It compiled with no errors" promises a great deal less about an
FPGA design than the same sentence does about a C program.
*(1 mark)*

---

## Question 6 - Counting, shifting, and knowing when a byte has arrived (12 marks)

### (a) 4 marks

**After `15` it returns to `0`**, with nothing in the circuit saying to: no comparison, no reset
logic, no "if the count is at maximum" anywhere.

**The element that performs the wrap** is the adder's **carry-out**: the fifth bit. The adder
produced `10000`, the fifth bit had nowhere to go, and the four bits that survived are `0000`.
Discarding that bit *is* the wraparound - "the count wraps because it runs out of bits" is not a
figure of speech, and you can point at the bit it ran out of.
*(2 marks)*

**What has to be true of the range.** The upper bound must be `2^N - 1`. `0 to 15` wraps for free;
`0 to 9` does not, because `10` is not a power-of-two boundary, so a modulo-10 counter needs an
explicit comparison against `9` and an explicit clear.
*(1 mark)*

**Which is modelling the hardware.** The drawing and the chip. There is no sixteenth value for four
bits to take, so they land on `0000`. GHDL objects because `natural range 0 to 15` is a **promise
the designer made** and `16` breaks it; a range-constrained integer is a claim about the value, not
a description of a wire.

**The rule that follows** is not "trust the hardware". It is that anything you intend to verify
should say what it means: write the comparison out, the way `timer.vhd` and `serial_rx8.vhd` do, and
the drawing, the simulator and the chip all agree.
*(1 mark)*

### (b) 3 marks

`shift_reg(6 downto 0)` is everything except the top bit, moved up one place; the top bit falls off;
`serial_in` fills the vacated bit 0.

| Edge | `serial_in` | `shift_reg` after |
|---|---|---|
| - | - | `00000000` |
| 1 | `1` | `00000001` |
| 2 | `0` | `00000010` |
| 3 | `1` | `00000101` |
| 4 | `1` | `00001011` |

*(2 marks; 1 if the sequence is right but shifted the wrong way)*

The first bit sent is now at **bit 3**, and after eight edges it will be at **bit 7**: the
first-arriving bit ends up in the most significant position, which is what "most significant bit
first" means for this course's receivers.

The mirror image is

```vhdl
shift_reg <= serial_in & shift_reg(7 downto 1);
```

which moves every bit toward the **least** significant end, takes data in at bit 7 and drops it from
bit 0, and so leaves the first-arriving bit in bit 0. That is the least-significant-first order a
real UART uses. It reads almost identically at a glance, which is why the direction is worth
checking before assuming.
*(1 mark)*

### (c) 2 marks

| | Data in | Data out |
|---|---|---|
| **SIPO** | one bit per clock | all N bits at once |
| **PISO** | all N bits at once, loaded | one bit per clock |

**SIPO** to receive a stream of serial bits: it accumulates them and hands you the whole word.
**PISO** to drive a chain of LEDs from a fixed pattern: it takes the word and sends it out one wire.
*(1 mark)*

**What differs between the architectures**: almost nothing. The shift expression is **identical** -
same direction, same line of VHDL. PISO adds a `load` branch to distinguish loading a new parallel
value from shifting the existing one out, and taps `shift_reg(N-1)` as a serial output where SIPO
exposes the whole vector. The two names describe how you *wire up* a shift register, not two kinds
of hardware.
*(1 mark)*

### (d) 3 marks

**Why a pulse.** The event being reported is instantaneous: a byte has just completed. A level would
say "a byte completed at some point", which a consumer cannot count. `data_ready` is driven low
unconditionally at the top of the clocked branch and raised only on the edge completing a byte,
which is the same single-cycle shape as L03's edge detector.
*(1 mark)*

**What it requires of `data_out`.** That it **holds** its value afterwards. A consumer that misses
the pulse has missed the *event*, not the data, and the byte is still there. A real peripheral would
add a holding register or a small FIFO here so a slow consumer cannot lose data at all.
*(1 mark)*

**Why the board demonstration needed a flip-flop.** At 50 MHz, `data_ready` is high for 20 ns. No
LED can show that, so the demonstration adds one flip-flop that is set by the pulse and cleared by
reset, turning the event into a level a human can see.

**Whose problem that is.** L03's edge detector, run backwards. There the problem was turning a level
into a one-cycle event; here it is turning a one-cycle event back into a level. Pulse against level
is the same distinction both times, and it is why the extra flip-flop is not a hack.
*(1 mark)*

---

## Question 7 - The counter that watches for a number (10 marks)

### (a) 3 marks

**Timer against counter.** A counter answers "what is the current count?" A timer answers "has a
certain amount of time passed?" It is a counter plus two things: a **comparison** against a fixed
target, and a **clear** that makes it repeat.
*(1 mark)*

**As gates.** One **XNOR per bit**, each comparing a counter bit against the corresponding bit of
the target: an XNOR outputs `1` when its inputs are the same, so each one is a single-bit equality
test. Their outputs are combined by a single **AND**, whose output is `timeout`.

| Target width | Gates |
|---|---|
| 4 bits | 4 XNOR + 1 four-input AND = **5** |
| 26 bits | 26 XNOR + an AND combining 26 signals = **27**, or 51 with the AND built as a tree of 25 two-input gates |

Twenty-six bits is what counting to 50,000,000 needs, and 26 XNORs across 52 inputs is the drawing
the VHDL exists to avoid.
*(1 mark)*

**What insists on all four.** The AND gate. Three matching bits is not a match, and watching the
four XNOR outputs as the count runs makes that concrete: three of them are high on plenty of counts
that are not `1010`. The comparison is the AND, not the XNORs.
*(1 mark)*

### (b) 3 marks

**With the clear.** The counter runs `0` through `10` inclusive and is then forced back to `0`, so a
full cycle is `11` edges: `10 - 0 + 1 = 11`.

**Without it.** The comparator still fires when the count reads `1010`, but nothing resets the
counter, so it carries on `1011, 1100, 1101, 1110, 1111` and wraps to `0000` on its own - four bits,
sixteen states - and does not read `1010` again until sixteen edges have passed. So `timeout` fires
every **16** edges.
*(2 marks for both numbers with the arithmetic)*

**Which was asked for: 11.** Both are periodic; only one has the period you specified. And on a
4-bit counter the two are close enough to look like a rounding error, which is exactly why this is
worth checking rather than eyeballing.

**The off-by-one in general.** A counter running `0` through `TICK_COUNT` visits `TICK_COUNT + 1`
values, so the period is `TICK_COUNT + 1` clock cycles, and for an exact count you write
`TICK_COUNT = seconds * 50,000,000 - 1`. The round numbers the course quotes leave an error of
between 0.02 and 0.2 ppm, far below the board oscillator's own tolerance.
*(1 mark)*

### (c) 2 marks

The CircuitVerse `timeout` is a **combinational decode** of the count, so it is high during the
cycle the counter reads `1010`, and between edges it can **glitch**: while the counter bits skew on
a transition, the XNOR-and-AND network can momentarily see a match that never existed.

The VHDL `timeout` is **registered** inside the clocked process, so it is high one cycle later,
during the cycle `counter` reads `0`, and it cannot glitch at all: it comes straight off a
flip-flop.

Same period, different phase, different glitch behaviour.
*(1 mark)*

The distinction is exactly the one L08's **Moore-versus-Mealy** discussion turns on: an output
decoded combinationally from state bits can glitch while they skew, and what makes an output
glitch-free is registering it, the way `fsm_led`'s `LED_PROCESS` does. "Moore" on its own does not
mean glitch-free.
*(1 mark)*

### (d) 2 marks

**The rule broken: one clock, and everything else is an enable.** `timeout` is a signal produced by
logic, not a clock, and routing it into a clock port creates a second clock domain out of it.
*(1 mark)*

**What it costs.** A design with one clock is a design whose timing the tool can analyze; a design
with a logic-derived clock is not, so no meaningful Fmax exists for it. Everything downstream is now
asynchronous to everything else in the design, so every signal crossing back needs L04's
synchronizer machinery. On an FPGA it also either burns a global clock resource or, worse, routes a
clock over ordinary logic routing with skew nobody bounded. The course names this the single most
common mistake a programmer makes writing a baud generator.

**What to do instead.** Keep the one 50 MHz clock everywhere and use `timeout` as a one-cycle
**enable** on a flip-flop that runs on it - which is what `walking_led` does with the same pulse,
and what `fsm_led` does in `STATE_BLINK`.
*(1 mark)*

---

## Question 8 - A machine designed by hand, then written down (13 marks)

### (a) 5 marks

**State diagram.** Four states in a ring with fall-back arrows; `y = 1` in `S3` only, and marked on
the bubble rather than on any arrow, which is what makes it a Moore machine.

Every state has exactly two arrows out of it, one per value of `din`:

| From | `din = 0` | `din = 1` |
|---|---|---|
| `S0` (y=0) | `S0`, self-loop: a `0` matches nothing | `S1`: the first `1` |
| `S1` (y=0) | `S0`: `10` is not a prefix of `110` | `S2`: `11` seen |
| `S2` (y=0) | `S3`: `110` complete | `S2`, self-loop: still `11` |
| `S3` (**y=1**) | `S0`: fresh start | `S1`: fresh start, on this `1` |

Drawn, that is a ring `S0 -> S1 -> S2 -> S3 -> S0` for the advancing path, a self-loop on `S0` and
on `S2`, and a fall-back arrow from `S1` to `S0`. `y = 1` is written **on the `S3` bubble**, not on
any arrow, and that is what makes it a Moore machine.

*(2 marks: 1 for two arrows out of every state, 1 for `y` marked on `S3` alone)*

**State table**, `S0 = 00`, `S1 = 01`, `S2 = 11`, `S3 = 10`:

| Q1 | Q2 | din | Q1+ | Q2+ | y | Meaning |
|----|----|-----|-----|-----|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | `S0` stays: a `0` matches nothing |
| 0 | 0 | 1 | 0 | 1 | 0 | `S0` to `S1`: saw the first `1` |
| 0 | 1 | 0 | 0 | 0 | 0 | `S1` back to `S0`: `10` is not a prefix |
| 0 | 1 | 1 | 1 | 1 | 0 | `S1` to `S2`: saw `11` |
| 1 | 1 | 0 | 1 | 0 | 0 | `S2` to `S3`: `110` complete |
| 1 | 1 | 1 | 1 | 1 | 0 | `S2` stays |
| 1 | 0 | 0 | 0 | 0 | **1** | `S3` to `S0`, fresh start |
| 1 | 0 | 1 | 0 | 1 | **1** | `S3` to `S1`, fresh start on this `1` |

*(2 marks for all eight rows; 1 if the four `S0`/`S1` rows are right and the fall-backs are not)*

**`S2` on `din = 1`: stay in `S2`.** The last two bits seen are still `1, 1`, which is exactly what
`S2` means, so there is nowhere better to go: an input of `1, 1, 1, 0` must still report a match.
The fall-back and self-loop arrows are where these machines go wrong, not the forward ones.
*(1 mark)*

### (b) 3 marks

Maps with `{Q1, Q2}` down the rows in Gray-code order and `din` across:

**`Q1+`**

| `Q1Q2` \ `din` | `0` | `1` |
|---|---|---|
| `00` |  |  |
| `01` |  | **1** |
| `11` | **1** | **1** |
| `10` |  |  |

Two groups of two: the whole `11` row gives `Q1Q2`, and the `din = 1` column across the adjacent
rows `01` and `11` gives `Q2·din`.

```text
Q1+ = Q1Q2 + Q2·din  =  Q2(Q1 + din)
```

**`Q2+`**

| `Q1Q2` \ `din` | `0` | `1` |
|---|---|---|
| `00` |  | **1** |
| `01` |  | **1** |
| `11` |  | **1** |
| `10` |  | **1** |

One group of four: the entire `din = 1` column, in which only `din` is constant.

```text
Q2+ = din
```

**`y`**, which reads only the state, confirming this is a valid Moore machine:

```text
y = Q1Q2'
```

*(2 marks for the three equations, of which 1 is for `Q2+ = din` being spotted as a group of four
rather than written out as four terms)*

**The gates.** `Q1+` is one OR and one AND in the factored form, or two ANDs and an OR unfactored.
`Q2+` is a **wire**: `din` goes straight to the second flip-flop's `D` input, with no gate at all.
`y` is one AND with one input inverted. Two D flip-flops hold `{Q1, Q2}`, and that is the whole
machine: two flip-flops and three or four gates.
*(1 mark)*

### (c) 3 marks

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity seq_detect_110 is
    port(clock, reset_n: in  std_logic;
         din           : in  std_logic;
         y             : out std_logic);
end entity;

architecture behaviour of seq_detect_110 is
type state_t is (S0, S1, S2, S3);
signal reset_s2_n: std_logic;
signal state: state_t;
begin
    -- Moore output: reads the state and nothing else.
    y <= '1' when state = S3 else '0';

    reset_sync1: entity work.reset_sync
        port map(clock, reset_n, reset_s2_n);

    STATE_PROCESS: process(clock, reset_s2_n) is
    begin
        if (reset_s2_n = '0') then
            state <= S0;
        elsif (rising_edge(clock)) then
            case (state) is
                when S0 =>
                    if (din = '1') then state <= S1; else state <= S0; end if;
                when S1 =>
                    if (din = '1') then state <= S2; else state <= S0; end if;
                when S2 =>
                    if (din = '1') then state <= S2; else state <= S3; end if;
                when S3 =>
                    if (din = '1') then state <= S1; else state <= S0; end if;
                when others =>
                    state <= S0;
            end case;
        end if;
    end process;
end architecture;
```

*(2 marks: 1 for an enumerated `state_t` with a `case` covering every state and a `when others`, 1
for the transitions agreeing with the candidate's own state table)*

`reset_n` goes through `reset_sync` because this is a **top level** and owns the pin. `din` does
**not** get a synchronizer: it is synchronous serial data, already clocked by this clock, and
synchronizing it would only delay it and shift the sequence being detected. This is the same split
`seq_detect_mealy` makes.

**What the VHDL does not contain.** The **encoding** (`S0 = 00`, `S1 = 01`, ...) and the
**next-state equations** derived in (b). Both are gone. The synthesis tool decides the encoding, and
derives the gate-level logic from the `case` itself; it will re-encode freely, often to one-hot,
unless told otherwise. That is exactly the trade the lecture is about: you designed it by hand once
so that you know what the tool is doing, and then hand the tool the decision.
*(1 mark)*

Credit an answer that also notes `y <= '1' when state = S3 else '0';` is a Moore output that is
still combinationally decoded, so it can glitch briefly while the state bits skew; registering it
inside a second clocked process is what makes it glitch-free.

### (d) 2 marks

`to_next_state` is now high on **every clock cycle the button is held**, not once per press, and the
`case` advances the state on every one of them.

**The arithmetic.** At 50 MHz a press is 20 ns per cycle. A brisk 100 ms press is
`0.1 / 20e-9 = 5,000,000` clock cycles, so the machine takes 5,000,000 transitions around a
three-state ring. `5,000,000 mod 3 = 2`, so *that* press lands two states on - but nobody can hold a
button for exactly 100 ms, and one cycle either way changes the answer. The state it lands in is
decided by how long you happened to hold the button, measured to 20 ns, which from the user's point
of view is a coin toss.
*(1 mark)*

**The fix.** Edge-detect the synchronized level, which is what `button_sync`'s third flip-flop is
for: compare the current synchronized value against the previous one, giving a pulse high for
exactly one clock cycle per press. That is the `X` of the hand-designed machine and the
`button_edge_s2` of `fsm_led`, and it is why the machine's input has to be an event rather than a
level.
*(1 mark)*

---
