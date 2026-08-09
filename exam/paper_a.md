# Digital Design with VHDL - Written Examination, Paper A

**Time:** 3 hours. **Closed book.** A basic calculator is permitted. **Total: 100 marks.**

This paper exists to test your own skills and knowledge. It is not a qualification and it gates
nothing. It draws on all eight lectures, so **it is meant to be taken once the course is over**,
after L08 and the two capstones.

---

## Rubric

**VHDL is the subject, so you write it here.** Every listing you produce is VHDL-93 using
`ieee.std_logic_1164`, and `ieee.numeric_std` where a conversion needs it. Write the `library` and
`use` clauses out at least once; after that they are assumed.

**Syntax is not what is being marked. Hardware is.** A missing semicolon or a forgotten `is` costs
nothing. A process that describes a latch where you meant a wire, or a chain of flip-flops where you
meant one, costs that part in full, because that is a different circuit.

**The course's conventions are the ones expected**, and a design that breaks one should say why:

* Vectors are declared `downto`, and `port map` is positional.
* An active-low signal is named with an `_n` suffix; a signal that has been through a two-flop
  synchronizer is named with an `_s2` suffix.
* A **subcomponent** takes `reset_s2_n` and never touches a raw asynchronous input. A **top level**
  takes `reset_n` and instantiates `reset_sync` itself.
* Shift registers shift toward the most significant bit.

**Where a question asks what the toolchain builds, answer in hardware**, not in code. "It assigns
`x`" is not an answer to "what does synthesis produce".

**Where a question asks for a truth table or a state table, give every row.** A Karnaugh map group
has to be written down as a term; circling it in the air scores nothing.

### Supplied constants and formulas

| Quantity                          | Value                                              |
| --------------------------------- | -------------------------------------------------- |
| DE0-CV system clock               | 50 MHz                                             |
| DE0-CV system clock period        | 20 ns                                              |
| Synchronizer mean time to failure | `MTBF = e^(t_r / tau) / (T_w * f_clock * f_data)`   |

### Marks

| Question | 1   | 2   | 3   | 4   | 5   | 6   | 7   | 8   |
| -------- | --- | --- | --- | --- | --- | --- | --- | --- |
| Marks    | 12  | 14  | 13  | 13  | 13  | 12  | 10  | 13  |

---

## Question 1 - A table, a network, and a module (12 marks)

**(a)** A function `X` of three inputs `A`, `B`, `C` is specified by this table:

| A | B | C | X |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 1 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 0 | 1 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 |

Read a sum-of-products equation straight off the table. Then simplify it by Boolean algebra alone,
naming the law used at each step, and count the gates the minimized equation needs against the
gates the unsimplified one needs. (4 marks)

**(b)** Every button and every reset in this course is active-low. A design carries `button_n` and
`enable_n`, both active-low, and must drive an active-high `go`, true exactly when both are
asserted.

Give the Boolean expression for `go`, apply De Morgan to it, and name the **single** gate that
implements the result. Then give both VHDL forms of the assignment, and state what synthesis
produces for each. (3 marks)

**(c)** Write the complete, synthesizable VHDL module for your minimized `X` from (a): entity
`gate_net`, inputs `a`, `b`, `c`, output `x`, all `std_logic`, declared in that order. Include the
`library` and `use` clauses, and state what they buy you. (3 marks)

**(d)** `x <= a or b;` is a concurrent assignment. State what it describes and why it is not a
statement that runs once. Then state what a signal sitting at `'U'` and a signal sitting at `'X'`
each tell you, and why neither is a value. (2 marks)

---

## Question 2 - The map, the multiplexer, and the module used twice (14 marks)

**(a)** A function `X` of four inputs `A`, `B`, `C`, `D`:

| A | B | C | D | X |   | A | B | C | D | X |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 1 |   | 1 | 0 | 0 | 0 | 1 |
| 0 | 0 | 0 | 1 | 0 |   | 1 | 0 | 0 | 1 | 0 |
| 0 | 0 | 1 | 0 | 1 |   | 1 | 0 | 1 | 0 | 1 |
| 0 | 0 | 1 | 1 | 0 |   | 1 | 0 | 1 | 1 | 0 |
| 0 | 1 | 0 | 0 | 0 |   | 1 | 1 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 | 1 |   | 1 | 1 | 0 | 1 | 1 |
| 0 | 1 | 1 | 0 | 0 |   | 1 | 1 | 1 | 0 | 0 |
| 0 | 1 | 1 | 1 | 1 |   | 1 | 1 | 1 | 1 | 1 |

Draw the Karnaugh map with `AB` down the rows and `CD` across the columns, both in Gray-code order.
Mark your groups, give the minimized sum-of-products equation, and state for each group which cells
it covers and which variables survive.

Then say how many AND-terms a direct L01-style reading of the table would have given, name the two
inputs that do not appear in your answer at all, and state which **single gate** realizes the whole
function. (5 marks)

**(b)** Write the architecture of a 4-to-1 multiplexer:

```vhdl
entity mux4 is
    port(inputs: in  std_logic_vector(3 downto 0);
         sel   : in  std_logic_vector(1 downto 0);
         x     : out std_logic);
end entity;
```

Selector `"00"` routes `inputs(3)`, `"01"` routes `inputs(2)`, `"10"` routes `inputs(1)` and `"11"`
routes `inputs(0)`, matching this course's `mux_8to1`.

Then answer: why can the `case` statement not appear directly in the architecture body, and what
does `when others` protect you against given that a two-bit selector "can only" hold four values?
(4 marks)

**(c)** The same entity again, built structurally. A 2-to-1 multiplexer is available:

```vhdl
entity mux2 is
    port(a, b, sel: in  std_logic;
         x        : out std_logic);
end entity;
```

with `x = a` when `sel = '1'` and `x = b` when `sel = '0'`.

Write an architecture `structure` for `mux4` that uses **three** instances of `mux2` and no logic of
its own. Then state how many copies of `mux2`'s logic the FPGA ends up with, and whether your
architecture and part (b)'s describe the same hardware. (3 marks)

**(d)** This course writes every `port map` positionally. State what happens when an entity declares
its ports in a different order from the one its testbench expects, distinguishing the case where the
misplaced ports have different types from the case where they have the same type, and say **when**
you find out in each case. (2 marks)

---

## Question 3 - What a clock edge does, and when an assignment happens (13 marks)

**(a)** Distinguish the D latch from the D flip-flop: state the condition under which each changes
its output, and why synchronous designs are built almost entirely from the flip-flop.

Then: `D` rises and falls again entirely between two rising clock edges. State what `Q` does in each
of the two, and why. (3 marks)

**(b)** A clocked process:

```vhdl
process(clock) is
begin
    if (rising_edge(clock)) then
        c <= b;
        b <= a;
    end if;
end process;
```

`b` and `c` both hold `'0'` before the first edge. `a` carries these values at the six rising edges:

| Edge | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| `a` | 1 | 0 | 1 | 1 | 0 | 0 |

Give `b` and `c` after each of the six edges. State how much hardware this process describes, what
happens if the two lines are swapped, and the rule that decides all of it. (4 marks)

**(c)** Write the VHDL for a rising-edge detector on an active-high input `req`, producing
`req_edge`, using one flip-flop and one gate. Include the asynchronous active-low reset.

Then state exactly how long `req_edge` is high and why, and say why its stored previous value resets
to `'0'` here where `led_toggle`'s resets to `"11"`. (3 marks)

**(d)** State the rule for a synchronous process's sensitivity list, and give the reason behind it.
Then say what changes, in simulation and in the built hardware, if a designer:

* adds `d` to the list of a flip-flop process, and
* leaves `reset_n` out of the list of a process with an asynchronous reset. (3 marks)

---

## Question 4 - The input you do not control (13 marks)

**(a)** State what a flip-flop's setup time and hold time are, what happens inside the flip-flop
when an input changes inside that window, and why an asynchronous input can never be promised to
avoid it.

Then a sharper point: sampling a signal in the middle of a transition and getting either level back
is **not** the failure. Say what the actual failure is, and why. (3 marks)

**(b)** Draw the double-flop synchronizer and state which flip-flop's output the rest of the design
may use, and why the other one's must not be.

Then read the supplied `MTBF` expression: name what each of `t_r`, `tau`, `T_w`, `f_clock` and
`f_data` is. A design has two asynchronous inputs, a push button pressed about once a second and a
line from another clock domain toggling at 10 MHz, and both go through a two-flop chain. State which
of the two makes the case for a third stage, by how many orders of magnitude, and what the third
stage costs. (4 marks)

**(c)** Write `reset_sync`: the reset synchronizer, entity and architecture, with ports `clock`,
`reset_n` (in) and `reset_s2_n` (out), declared in that order.

Name the pattern it implements, state what each half of that pattern does, and say what goes wrong
in a design of a dozen flip-flops if the second half is left out. (3 marks)

**(d)** A colleague has a 4-bit counter crossing from another clock domain. They put each bit
through its own double-flop synchronizer and use the four synchronized bits as a number.

State what is safe about this and what is not. Give a concrete value the receiving domain can read
that the counter never held, naming the transition that produces it. Then name the three standard
fixes and say which one removes the problem by construction rather than by handshaking around it.
(3 marks)

---

## Question 5 - The accumulator that isn't, and the latch nobody asked for (13 marks)

**(a)** A colleague writes an entity `any_set`, driving `found` high when any bit of `bits` is
`'1'`. It compiles, and it is wrong:

```vhdl
architecture broken of any_set is
signal any_s: std_logic;
begin
    found <= any_s;

    process(bits) is
    begin
        any_s <= '0';
        for i in bits'range loop
            any_s <= any_s or bits(i);
        end loop;
    end process;
end architecture;
```

Assume `bits` has the range `7 downto 0`, `bits = "01000000"`, and `any_s` holds `'0'` before the
process runs.

Trace the pass. For the initial assignment and every iteration, give the index, the value read from
`any_s`, the value scheduled, and whether that scheduled assignment survives. Give the value `found`
ends up with, give the correct answer, and state why repeatedly assigning a signal does not build an
accumulator.

Then, the part that makes this bug dangerous: characterize **every** input for which this
architecture happens to produce the right answer. (4 marks)

**(b)** Rewrite the architecture correctly, and answer: the loop runs eight times, so how many clock
cycles does the fixed design take to produce an answer, and how much storage does your accumulator
cost? Justify both. (3 marks)

**(c)** Nothing on an FPGA becomes a gate. State what a Boolean function becomes instead, name the
two things the fabric is made of, and name the unit Quartus counts on the DE0-CV's Cyclone V.

Then use that to say what your Karnaugh map in Question 2 actually bought you on this board, and
what it would still buy you anywhere. (3 marks)

**(d)** A combinational decoder, which compiles with no errors:

```vhdl
process(sel) is
begin
    case sel is
        when "00"   => leds <= "0001";
        when "01"   => leds <= "0010";
        when "10"   => leds <= "0100";
        when others => null;
    end case;
end process;
```

Quartus reports `Warning: Inferred latch(es) for signal "leds"`. State what the tool built and the
two-step reason it had no choice. Give two different fixes, one changing only the `when others`
branch and one adding a single line before the `case`. Then say why a warning here is more dangerous
than an error would be. (3 marks)

---

## Question 6 - Counting, shifting, and knowing when a byte has arrived (12 marks)

**(a)** A counter is declared `signal counter: natural range 0 to 15;` and incremented once per
clock edge with no comparison anywhere in the design.

State what happens after `15` and why. Name the element in the gate-level drawing that performs the
wrap, state what has to be true of the range for the wrap to be free, and say what changes at
`natural range 0 to 9`.

Then: GHDL aborts on the wrap that the drawing and the FPGA both perform happily. State which of the
two is modelling the hardware, and give the rule that follows for anything you intend to verify.
(4 marks)

**(b)** An 8-bit shift register, reset to `"00000000"`, is clocked with this course's shift:

```vhdl
shift_reg <= shift_reg(6 downto 0) & serial_in;
```

`serial_in` carries `1`, `0`, `1`, `1` on four consecutive enabled edges. Give `shift_reg` after
each of the four.

Then state which bit position holds the first bit you sent, where it will be after eight edges, and
give the mirror-image shift expression together with what it changes. (3 marks)

**(c)** Distinguish SIPO from PISO: what enters and leaves each, which you would reach for to
receive a stream of serial bits and which to drive a chain of LEDs from a fixed pattern, and the
**two** things that differ between the two architectures. (2 marks)

**(d)** In `serial_rx8`, `data_ready` is a one-cycle pulse rather than a level that stays high once
a byte has arrived.

State why it is a pulse, what that requires of `data_out`, and what a real peripheral would add.
Then state why the board demonstration had to add a flip-flop before an LED could show `data_ready`
at all, and name the earlier lecture whose problem that is in different clothes. (3 marks)

---

## Question 7 - The counter that watches for a number (10 marks)

**(a)** State what separates a timer from a plain counter.

Then build the comparison as gates: name the gate used per bit and say what it computes, name the
gate that combines them, and give the total gate count for a 4-bit target and for the 26-bit target
that counting to 50,000,000 needs.

Finally, watching a 4-bit timer count toward `1010`, three of the four per-bit outputs are high on
plenty of counts that are not `1010`. State what insists on all four. (3 marks)

**(b)** A 4-bit timer has `TICK_COUNT = 10`, and its designer leaves out the clear that returns the
counter to `0000` when the target is reached.

State how often `timeout` fires with the clear in place and how often without it, in clock edges,
and show the arithmetic for both. State which of the two periods is the one that was asked for, and
give the general form of the off-by-one that makes the first number what it is. (3 marks)

**(c)** The CircuitVerse timer's `timeout` is a combinational decode of the count; the VHDL
`timer`'s is registered inside the clocked process. State the difference this makes to *when*
`timeout` is high and to what it can do between edges, and name the discussion later in the course
that turns on exactly this distinction. (2 marks)

**(d)** A colleague wants an LED to blink once a second and wires the `timeout` output of a timer
into the clock input of the flip-flop holding the LED state, "so it only ticks once a second".

State the rule this breaks, what it costs in a design of any size, and what they should have done
instead. (2 marks)

---

## Question 8 - A machine designed by hand, then written down (13 marks)

A **Moore** machine watches a serial input `din`, one bit per clock cycle, and raises `y` once it
has seen the sequence `1, 1, 0`. Matches do **not** overlap: after a match the machine starts
looking for a fresh `1, 1, 0` from scratch. It has four states, encoded in two
flip-flops `{Q1, Q2}`:

| State | Meaning | `{Q1, Q2}` |
|---|---|---|
| `S0` | nothing matched yet | `00` |
| `S1` | saw `1` | `01` |
| `S2` | saw `11` | `11` |
| `S3` | saw `110` | `10` |

**(a)** Draw the state diagram, with an arrow out of every state for `din = 0` **and** for
`din = 1`, and mark which state drives `y = 1`. Then give the complete state table: all eight rows
of `{Q1, Q2, din}`, with `{Q1+, Q2+}` and `y`.

State what happens in `S2` on `din = 1` and justify it in one sentence. (5 marks)

**(b)** Derive `Q1+`, `Q2+` and `y` by Karnaugh map, treating each as a function of `{Q1, Q2, din}`.
Give the equations and say what gates each needs. (3 marks)

**(c)** Write the same machine in VHDL: an enumerated state type and a `case`-statement process,
with `reset_n` synchronized the way every top level in this course synchronizes it.

Then state what your VHDL does **not** contain that parts (a) and (b) produced, and who decides it
instead. (3 marks)

**(d)** In `fsm_led`, a colleague replaces the edge-detected pulse driving `to_next_state` with the
button's **level**, `not button_n(0)`, on the grounds that it is high exactly when the button is
pressed. (`button_sync` exposes only the pulse, so there is no synchronized level to take instead
without adding a `sync` of your own.)

State what the machine does while the button is held down, with the arithmetic, and say which state
it ends up in. Name the fix. (2 marks)

---
