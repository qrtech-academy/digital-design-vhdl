# Appendix B - Exercises
> **How to check your work.** Every exercise below that asks you to write a VHDL module ships a
> self-checking testbench under [`exercises/`](../exercises). Write your module in its
> `exercises/<module>/` directory, using the entity name and the **port order** the exercise
> specifies, then run it with GHDL - see [Appendix C](./c_testbenches.md) for the three commands.
>
> No FPGA board is needed for any exercise. The Quartus synthesis and board-programming steps are
> demonstrated during the lecture; your job afterwards is to get the VHDL right, and the testbench
> is how you confirm it.

## Karnaugh Maps
**1.** Derive a minimized equation for `X` from the Karnaugh map below, then realize the
corresponding gate network and simulate it in CircuitVerse:

| ABC | X |
|-----|---|
| 000 | 1 |
| 001 | 1 |
| 010 | 0 |
| 011 | 0 |
| 100 | 1 |
| 101 | 1 |
| 110 | 0 |
| 111 | 0 |

**Tip:** Lay `AB` down the rows in Gray-code order (`00, 01, 11, 10`) and `C` across the columns,
exactly as in the Appendix A.1 worked example, before you start grouping `1`s.

---

**2.** Derive a minimized equation for `X` from the Karnaugh map below, then realize the
corresponding gate network and simulate it in CircuitVerse:

| ABCD | X |
|------|---|
| 0000 | 0 |
| 0001 | 1 |
| 0010 | 0 |
| 0011 | 1 |
| 0100 | 0 |
| 0101 | 0 |
| 0110 | 0 |
| 0111 | 0 |
| 1000 | 0 |
| 1001 | 1 |
| 1010 | 0 |
| 1011 | 1 |
| 1100 | 1 |
| 1101 | 0 |
| 1110 | 1 |
| 1111 | 0 |

**Tip:** With four variables, put two of them (in Gray code) on each axis, so you get a 4x4 grid.
Groups can still wrap around every edge of the grid, not just left-right; remember to check the
top/bottom wraparound too.

---

## Circuits in VHDL
**3.** A gate network has:
* Four inputs, `ABCD`.
* Three outputs, `XYZ`.

It is given by the truth table below:

| ABCD | XYZ |
|------|-----|
| 0000 | 001 |
| 0001 | 010 |
| 0010 | 001 |
| 0011 | 011 |
| 0100 | 100 |
| 0101 | 110 |
| 0110 | 100 |
| 0111 | 111 |
| 1000 | 101 |
| 1001 | 110 |
| 1010 | 101 |
| 1011 | 111 |
| 1100 | 000 |
| 1101 | 010 |
| 1110 | 000 |
| 1111 | 011 |

**a)** Treat `X`, `Y`, and `Z` as three separate single-output functions of `ABCD`, and derive a
minimized equation for each via a Karnaugh map.
**b)** Realize the resulting gate network and simulate it in CircuitVerse; confirm all three
outputs against the truth table above.
**c)** Implement the design in VHDL, in a module of your own with four `std_logic` inputs and three
`std_logic` outputs ([L01 Appendix A.4](../../L01/appendix/a_combinational_logic.md#a4-enough-vhdl-to-read-and-write-a-gate-circuit)
and Appendix A.2 show the pattern for turning a derived equation into concurrent VHDL assignments).
**d)** Run the testbench (see the note at the top of this appendix) and confirm all 16 rows pass.

If a row fails, the assertion message names the input combination:
* Go back to the Karnaugh map for whichever of `X`, `Y`, `Z` is wrong.
* A single wrong output on a single row is nearly always one mis-grouped `1` in one map.

**Tip:** Two of the three outputs here turn out to depend on only one or two of the four inputs
once minimized. Don't assume every output needs all four.

![Module `xyz_logic`](./images/xyz_logic.png)

**Self-check:** name your VHDL entity `xyz_logic`, with ports `a`, `b`, `c`, `d` (in) and
`x`, `y`, `z` (out), declared in that order; its testbench is in
[`exercises/xyz_logic/`](../exercises/xyz_logic) and checks all 16 rows of the truth table above.

---

## Multiplexers
**4.** A 4-to-1 multiplexer has:
* Four data inputs, `A`-`D`.
* Two selector bits, `S[1:0]`.
* One output, `X`.

Take the selector to name its data input directly: `S[1:0] = "00"` selects `A`, `"01"` selects `B`,
`"10"` selects `C`, and `"11"` selects `D`. That is the mapping exercise 6 implements.

**a)** Write out the multiplexer's truth table (four rows, one per selector combination).
**b)** Derive the sum-of-products equation for `X` in terms of `A`-`D` and `S[1:0]` (Appendix A.4 works the same way for the
8-to-1 case; halve it here).
**c)** Build and simulate the network in CircuitVerse, and confirm `X` follows each data input in
turn as you change `S[1:0]`.

Keep your answer: exercise 6 below implements this exact circuit in VHDL, once A.5 has given you
the `process` and `case` statements it needs.

---


**5.** [Appendix A.5](./a_larger_networks.md#a5-multiplexers-in-vhdl-process-and-case) writes the
2:1 multiplexer using a `case` statement. Write the same circuit again with an `if`/`else`
instead, and confirm for yourself that the two describe identical hardware.

Write an entity named `mux2` with:

| Port | Direction | Type | Description |
|---|---|---|---|
| `d0` | in | `std_logic` | Data input. |
| `d1` | in | `std_logic` | Data input. |
| `sel` | in | `std_logic` | Selector. |
| `x` | out | `std_logic` | The selected data input. |

The selector routes the data input whose number it names:
* `sel = '0'` selects `d0`.
* `sel = '1'` selects `d1`.
* Note this is the opposite way round from
  [Appendix A.5](./a_larger_networks.md#a5-multiplexers-in-vhdl-process-and-case)'s
  `case` example, which selects its *second* input `b` on `'0'`. Which input a selector value names
  is a convention, not a rule, so read it off the specification every time rather than assuming.

Implement the multiplexer using a process-based architecture:
* Include `d0`, `d1`, and `sel` in the sensitivity list.
* Use an `if`/`else` statement on `sel`.
* Assign `x` in every branch.
* Do not use:
  * A conditional concurrent assignment (`x <= d1 when sel = '1' else d0;`).
  * A `with...select` statement:
    * a concurrent form of `case` this course doesn't cover.
    * mentioned only so you don't reach for it if you've met it elsewhere.

![Module `mux2`](./images/mux2.png)

**Self-check:** name your entity `mux2`, with ports `d0`, `d1`, `sel` (in) and `x` (out), declared
in that order; its testbench is in [`exercises/mux2/`](../exercises/mux2) and checks all eight
combinations of the three inputs.

---

**6.** Extend exercise 5 into a 4:1 multiplexer named `mux4`.

This is the circuit you derived, drew, and simulated by hand in exercise 4 above. Re-derive the
`case` branches yourself for four inputs and two selector bits rather than copying the 8-to-1
example from A.5.

The entity must have:

| Port | Direction | Type | Description |
|---|---|---|---|
| `d0` | in | `std_logic` | Data input. |
| `d1` | in | `std_logic` | Data input. |
| `d2` | in | `std_logic` | Data input. |
| `d3` | in | `std_logic` | Data input. |
| `sel` | in | `std_logic_vector(1 downto 0)` | Selector. |
| `x` | out | `std_logic` | The selected data input. |

As in exercise 5, the selector names its data input directly:
* `"00"` selects `d0`.
* `"01"` selects `d1`.
* `"10"` selects `d2`.
* `"11"` selects `d3`.
* Again, that is the opposite mapping from A.5's 8-to-1 worked example, where `"000"` routes
  `inputs(7)`. Derive your `case` branches from the four lines above, not from that listing.

Implement the multiplexer using a process:
* Include all data inputs and `sel` in the sensitivity list.
* Use a `case` statement on `sel`, one branch per selector value above.
* Include a `when others` branch.
  * Choose a safe output value for select inputs containing values such as `'X'`, `'U'`, or `'Z'`.
* Do not replace the `case` statement with an `if`/`elsif` chain.

![Module `mux4`](./images/mux4.png)

**Self-check:** name your entity `mux4`, with ports `d0`, `d1`, `d2`, `d3`, `sel`
(`std_logic_vector(1 downto 0)`) and `x` (out), declared in that order; its testbench is in
[`exercises/mux4/`](../exercises/mux4) and sweeps all four selector values against all sixteen
data-input combinations.

---

## Submodules and 7-Segment Displays

Exercises 7 and 8 build one design in two halves: a module that drives a single 7-segment display,
and a top level that uses two copies of it to show a hexadecimal digit on each. Do them in order:
exercise 8 instantiates what you write in exercise 7.

A 7-segment display is seven LEDs, named `a` through `g`, arranged around a figure-eight. Light
the right subset and you get a digit. This is the layout, and it is the one you need in order to
work out the codes below:

```text
      aaaa
     f    b
     f    b
      gggg
     e    c
     e    c
      dddd
```

So `1` lights `b` and `c` (the two on the right), and `7` lights `a`, `b` and `c`. Comparing the
codes given for those two digits is a quick way to confirm you have the layout the right way round
before you start deriving `A` to `F`.

On the DE0-CV the displays are wired **active-low**: driving
a segment to `'0'` lights it, and `'1'` turns it off. That is why the code for `8`, which lights
every segment, is `"0000000"`, and why a blank display is `"1111111"`.

Throughout, `hex(6 downto 0)` maps to segments `g`, `f`, `e`, `d`, `c`, `b`, `a`: bit 6 is `g` and
bit 0 is `a`.

**7.** Write a module named `display` that drives one 7-segment display with a hexadecimal digit.

The entity must have:

| Port | Direction | Type | Description |
|---|---|---|---|
| `number` | in | `std_logic_vector(3 downto 0)` | The value to show, `0000` through `1111`. |
| `hex` | out | `std_logic_vector(6 downto 0)` | The segment code for that value. |

So feeding `number` the value `0111` must put the code for `7` on `hex`, and feeding it `1110`
must put the code for `E` on `hex`.

Implement it using a process:
* Put `number` in the sensitivity list.
* Use a `case` statement on `number`, one branch per value.
* Include a `when others` branch, and blank the display in it.

You are given the codes for `0` to `9`. Work out `A` to `F` yourself, from the segment layout
above:

```vhdl
constant DISPLAY_0  : std_logic_vector(6 downto 0) := "1000000";
constant DISPLAY_1  : std_logic_vector(6 downto 0) := "1111001";
constant DISPLAY_2  : std_logic_vector(6 downto 0) := "0100100";
constant DISPLAY_3  : std_logic_vector(6 downto 0) := "0110000";
constant DISPLAY_4  : std_logic_vector(6 downto 0) := "0011001";
constant DISPLAY_5  : std_logic_vector(6 downto 0) := "0010010";
constant DISPLAY_6  : std_logic_vector(6 downto 0) := "0000010";
constant DISPLAY_7  : std_logic_vector(6 downto 0) := "1111000";
constant DISPLAY_8  : std_logic_vector(6 downto 0) := "0000000";
constant DISPLAY_9  : std_logic_vector(6 downto 0) := "0010000";
-- Todo: add DISPLAY_A through DISPLAY_F here.
constant DISPLAY_OFF: std_logic_vector(6 downto 0) := "1111111";
```

Two of the six are lower-case on a 7-segment display, because their upper-case forms would be
indistinguishable from a digit: `b` would read as `8` and `d` would read as `0`. `A`, `C`, `E` and
`F` are upper-case.

All sixteen codes are also sitting in `display_tb.vhd`, since a self-checking testbench cannot
check an output without knowing what it should be. So this is not a puzzle you can be locked out
of. Derive the six anyway: it takes a couple of minutes with the segment diagram, and reading them
off the testbench teaches you nothing the `case` statement does not. The work of this exercise is
the sixteen-branch `case`, not the lookup table.

![Module `display`](./images/display.png)

**Self-check:** name your entity `display`, with ports `number`
(`std_logic_vector(3 downto 0)`) and `hex` (out, `std_logic_vector(6 downto 0)`), declared in that
order; its testbench is in [`exercises/display/`](../exercises/display) and checks all sixteen
values against the full code table, naming the digit and both codes when one is wrong.

---

**8.** Write a module named `hex_display` that shows a two-digit hexadecimal number on two
displays, using two instances of your `display` from exercise 7.

The entity must have:

| Port | Direction | Type | Description |
|---|---|---|---|
| `input` | in | `std_logic_vector(7 downto 0)` | Eight slide switches: the top four are the left digit, the bottom four the right. |
| `hex1` | out | `std_logic_vector(6 downto 0)` | Segment code for the left digit. |
| `hex0` | out | `std_logic_vector(6 downto 0)` | Segment code for the right digit. |

When it works:
* the number on `input(7 downto 4)` appears on `hex1`.
* the number on `input(3 downto 0)` appears on `hex0`.

Build it with submodules, following
[Appendix A.6](./a_larger_networks.md#a6-building-a-design-from-submodules):
* Create two instances of `display`, labelled `display1` and `display0`.
* Connect `input(7 downto 4)` and `hex1` to `display1`.
* Connect `input(3 downto 0)` and `hex0` to `display0`.
* Use positional `port map`, as everywhere else in this course.
* Write no logic of your own in `hex_display`. If you find yourself writing a `case` statement
  here, you are duplicating exercise 7 rather than reusing it.

Copy your `display.vhd` from exercise 7 into the exercise directory, since `hex_display` cannot be
analyzed without it. This is the first design in the course built from more than one file, so name
`display.vhd` first, ahead of the file that instantiates it:

```bash
ghdl -a --std=93 display.vhd hex_display.vhd hex_display_tb.vhd
ghdl -e --std=93 hex_display_tb
ghdl -r --std=93 hex_display_tb --assert-level=error --stop-time=10ms
```

[Appendix C.4b](./c_testbenches.md#c4b-when-the-design-needs-more-than-one-file) explains why the
order matters.

![Module `hex_display`](./images/hex_display.png)

**Self-check:** name your entity `hex_display`, with ports `input`
(`std_logic_vector(7 downto 0)`), `hex1` (out) and `hex0` (out, both
`std_logic_vector(6 downto 0)`), declared in that order; its testbench is in
[`exercises/hex_display/`](../exercises/hex_display) and sweeps all 256 input values, checking each
half independently so a design that swaps the two digits is caught rather than passing on the
values where both halves happen to match.

---

**9. If you have time.** Realize one digit as a gate network, the way L01 and A.1 had you do it:
* Take the four inputs and one segment, say `a`, and derive the Boolean equation for it from the
  16-row truth table. A Karnaugh map is worth using here: most segments minimize substantially.
* Repeat for as many of the remaining six segments as you have patience for, and build the result
  in CircuitVerse.
* Then copy the whole gate network to drive a second display.

That copy is the point of the exercise. Duplicating a block of gates is exactly what instantiating
`display` a second time did in exercise 8, and it is worth having done once by hand to see what
the one line of VHDL stands for.

---

## Naming an Intermediate Result
**10.** Write an entity named `combo_logic` that implements the Boolean function:

```math
x = ab + c'd
```

[Appendix A.2](./a_larger_networks.md#a2-translating-the-karnaugh-map-network-into-vhdl) made the
case that naming a sub-expression with an internal signal costs nothing and buys readability. This
exercise is where you confirm that rather than take it on trust: you write the function twice, once
as a single expression and once with the `c'd` term pulled out into an internal signal named `y`.

A signal declared inside an architecture is a wire. It is not a variable, it does not store
anything, and naming a sub-expression with one does not add a gate, a delay, or a flip-flop to the
circuit. It only gives a piece of the network a name, so that you, reading it later, can see what
that piece is for. Both architectures below synthesize to the same gates, and the provided
testbench passes against either.

The entity must have:

| Port | Direction | Type |
|---|---|---|
| `a` | in | `std_logic` |
| `b` | in | `std_logic` |
| `c` | in | `std_logic` |
| `d` | in | `std_logic` |
| `x` | out | `std_logic` |

**a)** Implement the entire function using a single concurrent signal assignment:
* Do not declare any internal signals.
* Translate each Boolean operation into its corresponding VHDL operator.

**b)** Rewrite the architecture using an internal signal named `y`:
* Use `y` to represent the term:

```math
c'd
```

* Assign the final expression to `x`.
* This is the same shape as `gate_network` in A.2, which names its `AND` term `ab`.

Confirm that the two architectures describe the same circuit.

**Tip:** Two descriptions represent the same combinational circuit when they produce the same
output for every possible input combination.

With four inputs:
* There are 16 possible input combinations.
* Write the complete truth table.
* Verify that both architectures produce the same value of `x` in every row.

![Module `combo_logic`](./images/combo_logic.png)

**Self-check:** name your entity `combo_logic`, with ports `a`, `b`, `c`, `d` (in) and `x` (out),
declared in that order; its testbench is in [`exercises/combo_logic/`](../exercises/combo_logic)
and checks all 16 rows. It passes against either architecture, which is the point of the
comparison above.

---
