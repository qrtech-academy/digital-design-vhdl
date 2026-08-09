# Appendix B - Exercises

> **How to check your work.** Exercise 1 is a short pen-and-paper warm-up on notation this course
> uses throughout; it needs no VHDL, GHDL, or board, and states what a good answer covers.
>
> From exercise 2 on, every exercise that asks you to write a VHDL module ships a self-checking
> testbench under [`exercises/`](../exercises). Write your module in its `exercises/<module>/`
> directory, using the entity name and the **port order** the exercise specifies, then run it with
> GHDL - see [Appendix C](../../L02/appendix/c_testbenches.md) for the three commands.
>
> No FPGA board is needed for any exercise. The Quartus synthesis and board-programming steps are
> demonstrated during the lecture; your job afterwards is to get the VHDL right, and the testbench
> is how you confirm it.

## Truth Tables and Gates
**1.** A function of two inputs `A`, `B` and one output `X` has the truth table below:

| A | B | X |
|---|---|---|
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

**a)** Derive the sum-of-products equation for `X` directly from the truth table (Appendix A,
A.2). Two rows have `X = 1`, so you get two AND-terms.

**b)** Simplify it algebraically. Factor out what the two terms share, and apply
`A + A' = 1` and `1 · B' = B'` from A.2. You should end up with a single literal.

**c)** Your answer to **b)** says something about `A`. What? Which single gate from A.1's table
computes the function, and what happens to the `A` input when you draw it?

**d)** Build that single-gate version in CircuitVerse and confirm it reproduces every row of the
truth table above. Leave the `A` input unconnected, or simply leave it out of the drawing; **b)**
is the justification for doing so.

---

## Entities and Architectures
**2.** Write two small gates as complete VHDL modules, `and_gate` and `nand_gate`.

Neither gate is the point, and you should not expect either to be difficult. The point is that this
is where an entity and an architecture stop being something you read in A.4 and become something
you write, and that the two halves are worth writing in that order.

Both entities have the same ports:

| Port | Direction | Type |
|---|---|---|
| `a` | in | `std_logic` |
| `b` | in | `std_logic` |
| `x` | out | `std_logic` |

**a)** Write the `entity` declaration for `and_gate`, and nothing else. In VHDL a module's
interface is a thing you can write down and reason about before any implementation exists at all,
which is the habit this part exists to build. Identify the required ports, the direction of each,
and the type of each.

**b)** Add an `architecture` implementing the AND gate with a single concurrent signal assignment.

**c)** Now write `nand_gate`: the same interface with an inverted output, using VHDL's `nand`
operator directly. Do **not** write `not (a and b)`.

The two are equivalent as Boolean algebra, and on an FPGA they make no difference at all, because
both end up in the same lookup table. It matters on the kind of hardware exercise 6 below is about,
where NAND is the gate you physically have and everything else has to be built from it. Writing
what you mean, and letting the tools decide what it costs, is the habit; reaching past an operator
the language already gives you is the thing to avoid.

![Module `and_gate`](./images/and_gate.png)

![Module `nand_gate`](./images/nand_gate.png)

**Self-check:** name your entities `and_gate` and `nand_gate`, each with ports `a`, `b` (in) and
`x` (out), declared in that order; their testbenches are in
[`exercises/and_gate/`](../exercises/and_gate) and
[`exercises/nand_gate/`](../exercises/nand_gate), and each checks all four rows of the
corresponding truth table.

---

**3.** An XOR gate has three inputs, `a`, `b`, `c`, and one output, `x`. The output is `1` whenever
an odd number of the inputs are `1` (the 3-input XOR, or parity, function).

**a)** Write the truth table for `x` over all eight combinations of `a`, `b`, `c`, and confirm it
matches the "odd number of `1`s" description.
**b)** Implement the gate in VHDL, as a module of your own with an entity whose ports are three
`std_logic` inputs and one `std_logic` output, and an architecture that drives `x` with a single
concurrent assignment (Appendix A, A.4 shows the entity/architecture pattern and notes that VHDL's
`xor` operator works directly on `std_logic`; A.5 shows a complete module end to end).
**c)** Build the same gate in CircuitVerse and confirm it reproduces every row of your truth table.

**Tip:** `xor` chains left-to-right, so the whole architecture body is a single line, `x <= a xor b
xor c;`, with no internal `signal` or intermediate gates needed.

![Module `xor3`](./images/xor3.png)

**Self-check:** name your VHDL entity `xor3`, with ports `a`, `b`, `c` (in) and `x` (out), declared
in that order; its testbench is in [`exercises/xor3/`](../exercises/xor3), and A.5 lists the three
commands that run it.

---

**4.** A **majority gate** has three inputs, `a`, `b`, `c`, and one output, `x`. The output is `1`
whenever *at least two* of the three inputs are `1`.

This is the circuit behind a triple-redundant vote: three sensors report the same measurement, and
the system acts on whatever answer two of them agree on, so a single failed sensor cannot decide
anything on its own.

**a)** Write the truth table for `x` over all eight combinations of `a`, `b`, `c`.

**b)** Derive the sum-of-products equation for `x` directly from the truth table (Appendix A, A.2):
* Four rows have `x = 1`, so you get four AND-terms.
* Each term includes all three inputs, primed where that input is `0` in its row.

**c)** Implement the gate in VHDL, as a module of your own:
* An entity with three `std_logic` inputs and one `std_logic` output.
* An architecture driving `x` with a single concurrent assignment, translating your four AND-terms
  directly (Appendix A, A.4).

**d)** Build the same network in CircuitVerse and confirm it reproduces every row of your truth
table.

**Tip:** Write the equation out on paper before you open either the editor or CircuitVerse. Four
three-input AND-terms plus one four-input OR gate is a lot of wiring to correct after the fact.

**Looking ahead:** count the gates your equation needs, then convince yourself by inspection that
`x = ab + ac + bc` computes the same function with three two-input AND gates instead of four
three-input ones. Sum-of-products gave you a *correct* network, not the *smallest* one; finding the
smaller one systematically, rather than by staring at it, is what
[L02](../../L02/README.md) is for.

![Module `majority3`](./images/majority3.png)

**Self-check:** name your VHDL entity `majority3`, with ports `a`, `b`, `c` (in) and `x` (out),
declared in that order; its testbench is in [`exercises/majority3/`](../exercises/majority3) and checks all
eight rows. Either equation passes it - the testbench checks the function, not which network you
chose.

---

**5.** Write a **half adder**: `sum` and `carry` from two single bits. You know the circuit; the
reason it is here is that it is the first module in the course with **two outputs**, and that is a
VHDL question rather than a logic one.

**a)** Implement it, with two concurrent assignments and no internal `signal`.

Two outputs does not mean two entities, two architectures, or a process. Each output port is driven
by its own concurrent assignment, and the two are not steps that happen in an order: they describe
two separate pieces of wire, both live all the time. If you find yourself reaching for a process
to "return" two values, that instinct is the software one, and A.4's "a concurrent assignment
describes a wire" is the correction.

**b)** Build it in CircuitVerse and confirm both outputs, so you have seen the two-output shape as
a drawing before you meet it as an entity with several `out` ports in L02.

**Looking ahead:** this is the cell [L06](../../L06/README.md)'s counter is built from. The 4-bit
adder there is four of these chained carry-to-carry, and the counter is that adder with its output
fed back to its input, which is why the wraparound needs no logic of its own.

![Module `half_adder`](./images/half_adder.png)

**Self-check:** name your entity `half_adder`, with ports `a`, `b` (in) and `sum`, `carry` (out),
declared in that order; its testbench is in [`exercises/half_adder/`](../exercises/half_adder) and
checks `sum` and `carry` separately, so a design that has one right and the other wrong is told
which is which.

---

## Universal Gates
**6.** Appendix A.1 states that any Boolean function can be built using only `NAND` gates. This
exercise makes you prove it to yourself for the three operators you have been using.

**a)** Derive the `OR` case on paper before you build anything, because De Morgan
([A.2](./a_combinational_logic.md#the-laws-as-a-reminder)) gives it to you directly. Start from
`(A'B')'` and apply the law; you should arrive at `A + B`. Now read that expression back as a
circuit: what is `A'B'` with an inversion on its output, and how many `NAND` gates is the whole
thing?

**b)** In CircuitVerse, build each of the following from `NAND` gates and nothing else, confirming
each against its truth table in A.1 as you go:
* `NOT a`: one NAND gate is enough, if you feed the same signal to both of its inputs.
* `a AND b`: one NAND gate, followed by the `NOT` you just built.
* `a OR b`: the network you derived in **a)**. Check your gate count against what you predicted.

**c)** Write the `OR` version in VHDL, as a module of your own:
* An entity with two `std_logic` inputs and one `std_logic` output.
* An architecture driving `x` with a single concurrent assignment.
* Use only VHDL's `nand` operator:
  * no `or`, no `and`, no `not` anywhere in the expression.

**d)** Explain why this matters in practice. Consider that a chip fabrication process has to
physically implement every gate type it offers, and that `NAND` is the cheapest gate to build in
CMOS.

**Tip:** VHDL's `nand` operator does not chain the way `and` and `or` do: `a nand b nand c` is not
legal. Parenthesize every NAND explicitly, which is what you want here anyway, since each pair of
parentheses is one physical gate in your CircuitVerse drawing.

![Module `or_from_nand`](./images/or_from_nand.png)

**Self-check:** name your VHDL entity `or_from_nand`, with ports `a`, `b` (in) and `x` (out),
declared in that order; its testbench is in [`exercises/or_from_nand/`](../exercises/or_from_nand)
and checks it against all four rows of the `OR` truth table.

---

## Putting It Together
**7.** Write the braking assistant from
[Appendix A.6](./a_combinational_logic.md#a6-the-lectures-circuit-a-braking-assistant) in VHDL.

A.6 had you derive its equations, count its gates and sketch its network *before* the session, and
the session then built it live. This is where you write it yourself, and where a testbench decides
whether your reading of the requirement matches the one in A.6's truth table.

The entity must have:

| Port | Direction | Type | Description |
|---|---|---|---|
| `driver_brake` | in | `std_logic` | The driver is on the brake pedal. |
| `sensor` | in | `std_logic` | The proximity sensor sees an obstacle. |
| `radar` | in | `std_logic` | The radar sees an obstacle. |
| `error` | in | `std_logic` | The assistance system is reporting a fault. |
| `engine_brake` | out | `std_logic` | Apply the brakes. |

**a)** Implement it from **your own** equations rather than from what was on screen. If the two
disagree, that disagreement is the most useful thing this exercise can give you, and the testbench
will tell you which of them the truth table agrees with.

Use two concurrent assignments and one internal `signal`:
* The signal holds the assistance system's own decision, before the driver's pedal is considered.
* This is the first exercise in the course with an internal signal, and it is the reason the
  keyword exists: a name for an intermediate result, so each line still reads like the clause of
  the requirement it came from.

**b)** Now break it deliberately, in the specific way A.6 warns about. Feed `driver_brake` *through*
the fault logic instead of letting it bypass:

```vhdl
engine_brake <= (driver_brake or sensor or radar) and (not error);
```

That is one gate simpler, and it looks reasonable. Run the testbench against it and answer:
* Which input combination does it fail on first, and what is physically happening in the car at
  that moment?
* How many of the sixteen rows does it get wrong, and what do they all have in common?
* The failing rows are exactly the ones the safety requirement was written for. What does that tell
  you about the value of a truth table you derived from a requirement, as opposed to one you read
  off a circuit you had already built?

![Module `adas`](./images/adas.png)

**Self-check:** name your entity `adas`, with inputs `driver_brake`, `sensor`, `radar`, `error` and
output `engine_brake`, declared in that order; its testbench is in
[`exercises/adas/`](../exercises/adas) and checks all sixteen rows of A.6's truth table.

---
