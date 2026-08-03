# Appendix A - Combinational Logic

## A.1 Digital signals and logic gates
A digital signal takes one of two values, `0` or `1`, rather than the continuous range an analog
signal uses. Anything close enough to `0` or `1` is read as exactly `0` or `1`, so small amounts of
electrical noise change nothing. That noise immunity is why almost all modern computation, from
microcontrollers to FPGAs, is digital.

A **logic gate** has one or more single-bit inputs, one single-bit output, and a fixed Boolean
function between them.

**Combinational logic**, this lecture's topic, produces outputs from the current inputs alone, with
no memory. **Sequential logic** (L03) depends on the current inputs *and* on state stored in
flip-flops.

Every basic 2-input gate, plus the unary `NOT`:

| A | B | AND |  OR | NAND | NOR | XOR | XNOR |
| - | - | :-: | :-: | :--: | :-: | :-: | :--: |
| 0 | 0 |  0  |  0  |   1  |  1  |  0  |   1  |
| 0 | 1 |  0  |  1  |   1  |  0  |  1  |   0  |
| 1 | 0 |  0  |  1  |   1  |  0  |  1  |   0  |
| 1 | 1 |  1  |  1  |   0  |  0  |  0  |   1  |

| A | NOT A |
| - | :---: |
| 0 |   1   |
| 1 |   0   |

Worth internalizing straight from the tables:
* `NAND`, `NOR` and `XNOR` are the inverses of `AND`, `OR` and `XOR`.
* `XOR` is `1` when the inputs differ. Beyond two inputs this generalizes to **odd parity**: `1`
  when an odd number of inputs are `1` ([Appendix B](./b_exercises.md), exercise 3).
* Any Boolean function can be built from `AND`, `OR` and `NOT`, and also from `NAND` alone or `NOR`
  alone.

---

## A.2 Boolean algebra notation
Three operators, mapping directly onto the gates above:

| Gate | Boolean algebra notation |
|---|---|
| AND | multiplication: `A` **AND** `B` is written `AB` |
| OR | addition: `A` **OR** `B` is written `A + B` |
| NOT | prime: **NOT** `A` is written `A'` |

A function written as an OR of AND-terms, such as `X = AB' + CD`, is in **sum-of-products** form.

Every truth table reads off into sum-of-products directly:
1. Find every row where the output is `1`.
2. For each, write one AND-term containing every input: directly if it is `1` in that row, primed
   if it is `0`.
3. OR those terms together.

For example:

| A | B | X |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

Row `AB = 01` contributes `A'B` and row `AB = 10` contributes `AB'`, giving `X = A'B + AB'`. Check
it against the table: that is `XOR`, so the same network is one `XOR` gate rather than two `AND`
gates, two `NOT` gates and an `OR`.

### The laws, as a reminder
You have met these. They are here so the course has one notation for them and so the later
appendices can cite them, not because they need teaching:

| Law | With OR | With AND |
|---|---|---|
| Identity | `A + 0 = A` | `A · 1 = A` |
| Null | `A + 1 = 1` | `A · 0 = 0` |
| Idempotent | `A + A = A` | `A · A = A` |
| Complement | `A + A' = 1` | `A · A' = 0` |
| Absorption | `A + AB = A` | `A(A + B) = A` |
| De Morgan | `(A + B)' = A'B'` | `(AB)' = A' + B'` |

**De Morgan is the one this course leans on**, less for minimization than as a rule about moving an
inversion through a gate: an `OR` with both inputs inverted *is* a `NAND`, and an `AND` with both
inputs inverted *is* a `NOR`. It is why a `NAND` gate can build anything, which
[Appendix B](./b_exercises.md) exercise 6 has you write in VHDL, and it comes back every time an
active-low signal meets logic written for active-high. In a course where every reset and every
button is active-low, that is often.

That gap between a straightforward sum-of-products reading and the smallest network is what a
**Karnaugh map** closes, and [L02](../../L02/README.md) works one end to end. Not because the
technique is new to you, but because the minimized equation is what gets written in VHDL, and L08
derives its state machine's next-state logic exactly this way.

---

## A.3 Building and simulating a circuit in CircuitVerse
[CircuitVerse](https://circuitverse.org/simulator) is a free, browser-based logic simulator. Every
gate network in this course is built and tested there by hand before it is written in VHDL:
1. Open the simulator and start a new project.
2. Place an **input** element per input signal and an **output** element per output, renamed to
   match your variables.
3. Place the gates your equation calls for, from the *Gates* panel.
4. Wire it up one gate at a time, following your derived equation. You should already know exactly
   which gates you need before you open the simulator, which is why A.2 comes first.
5. Toggle each input and confirm the output matches your truth table for **every** row.
6. Save via `Project -> Save Online`, or `Project -> Download as image/data` for a re-importable
   `.cv` file.

**Step 5 is not optional, and nothing else does it for you.** Three rules make it a check rather
than a formality:
* **Exhaustive, not spot-checked.** Two inputs is four rows, three is eight. At these sizes there is
  no excuse for sampling. For the sequential circuits later on this becomes "step the clock and
  check at every edge", the same discipline applied to time.
* **Derive first, simulate second.** Draw the circuit and *then* decide what it should do, and you
  will read your expectations off the simulation, which proves nothing.
* **A mismatch is information.** It says the drawing and the equation disagree, and one of them is
  wrong.

Every hardware bug you will chase is found by predicting a behaviour and then checking it. Doing it
by hand on a four-gate circuit is how you learn to do it on one you cannot see all at once.

Once the design is VHDL, a self-checking testbench takes over that job. Every worked example and
every exercise ships one; you run them rather than write them, as covered in
[L02 Appendix C](../../L02/appendix/c_testbenches.md).

---

## A.4 Enough VHDL to read and write a gate circuit
VHDL describes hardware, not a sequence of instructions. Every statement below runs concurrently
and continuously, exactly like the gates it describes. The language arrives as it is needed; this
section is enough for a simple combinational circuit.

Every VHDL module has two parts:
* An **entity**, the black-box view: the ports, and nothing about what happens inside.
* An **architecture**, the implementation behind it.

That split is a contract, not ceremony. The entity is everything another design needs in order to
use this module, which is what lets one design instantiate another without reading it, and lets you
rewrite an implementation without touching what depends on it. The shape is a header beside a source
file, or an interface beside its class; the difference is that VHDL enforces it for every module,
with no way to skip the interface or leak the implementation through it.

Take `or_gate`: inputs `a`, `b`, output `x`, and `x = a or b`.

```vhdl
entity or_gate is
    port(a, b: in std_logic;
         x   : out std_logic);
end entity;
```

![Entity `or_gate`](./images/or_gate_entity.png)

`std_logic` is the single-bit signal type. It is not built into VHDL but comes from the
`std_logic_1164` package, which is why every file in this course opens with:

```vhdl
library ieee;
use ieee.std_logic_1164.all;
```

It has nine values rather than two, because real hardware needs more than true and false:
* `'0'` and `'1'`: driven low and driven high. The only two you will write in this course.
* `'Z'`: high-impedance, nothing driving the line at all.
* `'U'`: uninitialized, what a signal holds before anything assigns it.
* `'X'`: unknown, what a simulator shows when two things drive one signal and disagree.
* `'-'`, `'W'`, `'L'`, `'H'`: don't-care and weak-drive values, rarely written by hand.

Recognizing the seven you will not write still matters: they are how a simulator tells you something
is wrong. A signal sitting at `'U'` or `'X'` is a bug, not a value.

The architecture fills in the box:

```vhdl
architecture behaviour of or_gate is
begin
    x <= a or b;
end architecture;
```

![Architecture `or_gate`](./images/or_gate_arch.png)

Together they form the complete module:

![Module `or_gate`](./images/or_gate_module.png)

`x <= a or b;` is A.2's Boolean algebra almost verbatim: VHDL's `and`, `or`, `not` and `xor` work
directly on `std_logic`, so any equation you derived by hand becomes VHDL with barely any
translation.

The assignment is **concurrent**. It is not executed once; it holds continuously, like a wire
between real gates.

The keyword `signal` declares an internal wire inside an architecture, as opposed to an externally
visible port. You use one in exercise 7 to name an intermediate result rather than nesting it
inline, and [L02](../../L02/README.md) leans on the same idea throughout.

---

## A.5 The complete module: `or_gate`
A.4's pieces together make a complete, synthesizable file. This is the whole of
[`or_gate.vhd`](../or_gate/or_gate.vhd), and it is a real design that synthesizes and runs on the
DE0-CV.

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity or_gate is
    port(a, b: in  std_logic;
         x   : out std_logic);
end entity;

architecture behaviour of or_gate is
begin
    x <= a or b;
end architecture;
```

* The `library`/`use` clauses pull in `std_logic`.
* `entity` declares the outside: two inputs, one output.
* `architecture` implements the inside, as one concurrent assignment.

That is the smallest complete VHDL design there is, and the shape never changes. Every module in
this course, up to the state machines in [L08](../../L08/README.md), is this same
`library`/`entity`/`architecture` skeleton. What grows is the architecture body, never the frame.

**Checking your work.** `or_gate` ships [`or_gate_tb.vhd`](../or_gate/or_gate_tb.vhd), which drives
all four input combinations and checks the output:

```bash
cd lectures/L01/or_gate
ghdl -a --std=93 or_gate.vhd or_gate_tb.vhd
ghdl -e --std=93 or_gate_tb
ghdl -r --std=93 or_gate_tb --assert-level=error --stop-time=10ms
```

No output beyond a final note means every check passed. Testbenches are covered properly in
[L02 Appendix C](../../L02/appendix/c_testbenches.md); for now, treat these three commands as how
you confirm a module works.

---

## A.6 The lecture's circuit: a braking assistant
The lecture builds a different circuit from `or_gate`, live, so you see the same path walked twice:
once here in writing, and once on something you have not already read the answer to.

The requirement: **the car brakes if the driver brakes, or if the assistance system decides to.**
The assistance system decides to when either detector sees something, unless it is reporting a
fault, in which case it is not trusted to brake at all.

| Port | Direction | Meaning |
|---|---|---|
| `driver_brake` | in | The driver is on the brake pedal. |
| `sensor` | in | The proximity sensor sees an obstacle. |
| `radar` | in | The radar sees an obstacle. |
| `error` | in | The assistance system is reporting a fault. |
| `engine_brake` | out | Apply the brakes. |

Three clauses decide the whole structure between them:
* either detector is enough on its own, and neither is trusted more than the other.
* a fault does not raise an alarm; it *suppresses* the assistance system's ability to brake.
* the driver can always brake, including when the assistance system is faulty and doing nothing.

That last one is a safety requirement, and it is the one to hold on to when you derive the network:
the pedal is not an input to the assistance logic, it bypasses it. Work out what changes if the
pedal is fed through the fault logic instead, and you have found the bug the structure exists to
prevent.

### The truth table
Sixteen rows, in the order a four-bit counter would produce them. `adas_brake` is not a port; it is
the assistance system's own decision, shown as an intermediate column so you can see where the
structure comes from.

| `driver_brake` | `sensor` | `radar` | `error` | `adas_brake` | `engine_brake` |
|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 0 | 1 | 0 | 0 |
| 0 | 0 | 1 | 0 | 1 | 1 |
| 0 | 0 | 1 | 1 | 0 | 0 |
| 0 | 1 | 0 | 0 | 1 | 1 |
| 0 | 1 | 0 | 1 | 0 | 0 |
| 0 | 1 | 1 | 0 | 1 | 1 |
| 0 | 1 | 1 | 1 | 0 | 0 |
| 1 | 0 | 0 | 0 | 0 | 1 |
| 1 | 0 | 0 | 1 | 0 | 1 |
| 1 | 0 | 1 | 0 | 1 | 1 |
| 1 | 0 | 1 | 1 | 0 | 1 |
| 1 | 1 | 0 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 | 0 | 1 |
| 1 | 1 | 1 | 0 | 1 | 1 |
| 1 | 1 | 1 | 1 | 0 | 1 |

The bottom half is entirely `1`: once `driver_brake` is set nothing else changes the answer. That is
what "overrides everything" looks like in a table.

### Before the lecture
Everything above is the specification. The derivation, the gate network, and the VHDL are what the
lecture builds live, and it is worth arriving with your own answer to compare against rather than
one you have already read. So, from the table above:
* Read a sum-of-products equation for `engine_brake` straight off it, the way A.2 did.
* Simplify it by hand. The requirement is three clauses long, so the minimal network is a great deal
  smaller than the row-by-row reading gives you. Work out how much smaller before you are told.
* Count the gates your simplified equation needs, and write the number down.
* Sketch the network, and decide which single gate the safety argument above rests on.

Bring those four answers to the session. Being wrong about any of them is worth more than not having
guessed, because you will know exactly which step to re-examine when the live derivation reaches it.
That is A.3's "derive first, simulate second" applied to a circuit you have not built yet, and it is
the habit the rest of the course is built on. Afterwards you write the VHDL yourself, in
[Appendix B](./b_exercises.md) exercise 7, and a testbench decides whether your equations and A.6's
truth table agree.

### Why there is a testbench for it
Sixteen combinations is few enough to check by hand once. It is not few enough to check every time
somebody edits the file, which is the situation every module in this course is in from here on.

A **testbench** is a second VHDL file that does the checking. It is not part of the design and never
reaches the FPGA: it drives the inputs through every case, works out what the output should have
been, compares, and reports. For `adas`, written alongside it in the lecture, that is a loop over
the sixteen combinations restating the braking rule independently.

*Independently* is the important word. A testbench that read its expected answer out of the design
would agree with it by construction, including when the design is wrong. Restating the requirement
separately is what turns it into a check.

That is why almost every directory in this repository has a `_tb.vhd` beside the module: it is how
you can be handed a module, change it, and know within a second whether you broke it.
[L02 Appendix C](../../L02/appendix/c_testbenches.md) covers running them; you are not asked to write
one anywhere in this course.

---
