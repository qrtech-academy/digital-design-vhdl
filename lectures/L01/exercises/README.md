# L01 - Exercise solutions
> **Spoilers.** This file explains the solutions to the VHDL exercises in
> [Appendix B](../appendix/b_exercises.md). Try each exercise yourself first.

Each directory holds one module and its self-checking testbench. Exercise 1 is pen and paper, so it
has no directory here, and exercises 3, 4, 5 and 6 also have CircuitVerse or paper parts that are
not covered below.

| Exercise | Directory | Module |
|---|---|---|
| 2 | [`and_gate/`](./and_gate) | Two-input AND |
| 2 | [`nand_gate/`](./nand_gate) | Two-input NAND |
| 3 | [`xor3/`](./xor3) | Three-input XOR (parity) |
| 4 | [`majority3/`](./majority3) | At least two of three inputs are high |
| 5 | [`half_adder/`](./half_adder) | Adds two single bits |
| 6 | [`or_from_nand/`](./or_from_nand) | OR built from NAND only |
| 7 | [`adas/`](./adas) | The braking assistant from A.6 |

---

## Running the testbenches
Run every L01 exercise from the repository root:

```bash
make build MODULE=L01/exercises
```

Or run a single one from inside its directory, here `xor3`:

```bash
ghdl -a --std=93 xor3.vhd xor3_tb.vhd
ghdl -e --std=93 xor3_tb
ghdl -r --std=93 xor3_tb --assert-level=error --stop-time=10ms
```

Each module passes with `all checks passed!`. A failure stops the simulation and reports the inputs
it failed on.

---

## `and_gate` and `nand_gate`
```vhdl
x <= a and b;
```

```vhdl
x <= a nand b;
```

The two modules share an interface and differ only in the operator. The entity lists what is
visible from the outside, and the architecture describes what drives the output. Each assignment
describes a wire that follows its inputs all the time, not a statement that runs once.

`nand_gate` uses the `nand` operator rather than `not (a and b)`. The two are equivalent, but `nand`
states the intent directly.

---

## `xor3`
```vhdl
x <= a xor b xor c;
```

`xor` chains left to right, so this reads as `(a xor b) xor c`. Each `xor` flips the running result
when its new input is `1`, so the output ends up `1` exactly when an odd number of inputs are `1`.

| `a` | `b` | `c` | `x` |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 |
| 0 | 1 | 0 | 1 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 0 | 1 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 0 |
| 1 | 1 | 1 | 1 |

---

## `majority3`
```vhdl
x <= (a and b) or ((a xor b) and c);
```

The expression splits on whether `a` and `b` agree:
* **`a` and `b` are both `1`:** that is already two inputs, so `a and b` sets the output and `c`
  does not matter.
* **`a` and `b` are both `0`:** at most one input can be `1`, and both terms are `0`.
* **`a` and `b` differ:** they contribute exactly one `1`, so `c` decides. `a xor b` selects this
  case, and `and c` passes `c` through.

| `a` | `b` | `c` | `x` |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 0 |
| 0 | 1 | 1 | 1 |
| 1 | 0 | 0 | 0 |
| 1 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 |

This is a third form of the function, alongside the two equations in the exercise. Part b)'s
sum-of-products reading is `x = a'bc + ab'c + abc' + abc`, and the smaller form is
`x = ab + ac + bc`. All three compute the same function, and the testbench checks the function
rather than the network.

---

## `half_adder`
```vhdl
sum   <= a xor b;
carry <= a and b;
```

Adding two bits gives a result from `0` to `2`, which takes two bits to represent:

| `a` | `b` | `carry` | `sum` | Result |
|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 | 1 |
| 1 | 0 | 0 | 1 | 1 |
| 1 | 1 | 1 | 0 | 2 |

`sum` is `1` when exactly one input is `1`, which is `xor`. `carry` is `1` only when both are, which
is `and`. Each output port has its own concurrent assignment. The two lines are separate pieces of
wire, so their order does not matter and no process is needed.

---

## `or_from_nand`
```vhdl
signal a_n, b_n: std_logic;
...
a_n <= a nand a;
b_n <= b nand b;
x   <= a_n nand b_n;
```

The module is three NAND gates:
1. A NAND with both inputs tied together is a NOT, because `(aa)' = a'`. That gives `a_n` and `b_n`.
2. The third NAND combines them into `x = (a'b')'`.
3. De Morgan turns that into `x = a'' + b'' = a + b`, which is OR.

| `a` | `b` | `a_n` | `b_n` | `x` |
|---|---|---|---|---|
| 0 | 0 | 1 | 1 | 0 |
| 0 | 1 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 | 1 |
| 1 | 1 | 0 | 0 | 1 |

The internal signals name the two inverted inputs, so each line corresponds to one physical gate.
The same network also fits on one line, with each pair of parentheses as one gate:

```vhdl
x <= (a nand a) nand (b nand b);
```

---

## `adas`
```vhdl
signal adas_brake: std_logic;
...
adas_brake   <= sensor and camera and (not error);
engine_brake <= driver_brake or adas_brake;
```

Each line is one clause of the requirement in
[A.6](../appendix/a_combinational_logic.md#a6-the-lectures-circuit-a-braking-assistant):
* **`adas_brake`** is the assistance system's own decision. It needs an object in front of the
  vehicle (`camera`), that object approaching (`sensor`), and a system working as intended
  (`error = 0`).
* **`engine_brake`** brakes on that decision or on the driver's pedal.

`driver_brake` joins at the final OR, after the fault logic, so `error` can suppress the assistance
system but never the driver. That OR is the gate the safety requirement rests on.

Exercise 7 b) moves the pedal behind the fault logic:

```vhdl
engine_brake <= (driver_brake or (sensor and camera)) and (not error);
```

This gets four rows wrong: `i = 9`, `11`, `13` and `15`. All four have `driver_brake = 1` and
`error = 1`, so the driver is braking during a fault and the car does not brake. The testbench stops
at the first of them, `i = 9`.

---
