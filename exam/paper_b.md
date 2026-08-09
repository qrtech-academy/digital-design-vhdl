# Digital Design with VHDL - Written Examination, Paper B

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

### Supplied constants

| Quantity                       | Value      |
| ------------------------------ | ---------- |
| DE0-CV system clock            | 50 MHz     |
| DE0-CV system clock period     | 20 ns      |
| Baud rate used by the capstone | 9600 baud  |

### Marks

| Question | 1   | 2   | 3   | 4   | 5   | 6   | 7   | 8   |
| -------- | --- | --- | --- | --- | --- | --- | --- | --- |
| Marks    | 12  | 14  | 13  | 13  | 13  | 12  | 10  | 13  |

---

## Question 1 - A requirement, and the shape of the network it asks for (12 marks)

A two-hand press control. The operator must keep both hands on buttons while the press cycles, so
that neither hand can be under it.

| Port | Direction | Meaning |
|---|---|---|
| `left` | in | The left hand button is pressed (active high). |
| `right` | in | The right hand button is pressed (active high). |
| `curtain_clear` | in | The light curtain sees nothing in the way (active high). |
| `estop_n` | in | The emergency stop, **active low**: `0` when it has been pulled. |
| `maint` | in | Maintenance mode is selected (active high). |
| `pedal` | in | The maintenance foot pedal is pressed (active high). |
| `run` | out | Cycle the press. |

**(a)** Ignore `maint` and `pedal` for now. The press cycles when **both** hand buttons are pressed
and the curtain is clear, and never when the emergency stop has been pulled.

Give the Boolean equation for `run`, state how many gates it needs, and say how many rows of the
full four-input truth table are `1`. (2 marks)

**(b)** Now the whole requirement. In maintenance mode the press cycles from the foot pedal alone,
ignoring the hand buttons and the curtain entirely - but the emergency stop is never ignored, in any
mode.

Give the Boolean equation for `run`. State which single input your equation factors outside
everything else, and what safety property that factoring expresses.

Then contrast it with the braking assistant of L01: there the override sits outside the fault logic
and forces the output **high**, here it sits outside the mode logic and forces it **low**. State
what each of the two guarantees, and say what feeding the override *through* the logic it is
supposed to sit outside would cost in each case.

Finally: the full table has 64 rows. How many are `1`? Use that number to say what deriving this
circuit from its table rather than from its statement would have cost you. (4 marks)

**(c)** Write the complete, synthesizable VHDL module for (b): entity `press_control`, with the
ports above declared in the order the table lists them, all `std_logic`.

Then say where a `not` appears in your architecture and where an **active-low** input needed none,
and give the rule that decides it. (3 marks)

**(d)** VHDL splits every module into an `entity` and an `architecture`, and the course calls that
split a contract rather than ceremony.

State what each part holds, name the two things the split makes possible, and say what is different
about VHDL's version of it compared with a header file beside a source file in C. (3 marks)

---

## Question 2 - The map, the vector, and the process that lies (14 marks)

**(a)** A function `X` of four inputs `A`, `B`, `C`, `D`:

| A | B | C | D | X |   | A | B | C | D | X |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 1 |   | 1 | 0 | 0 | 0 | 0 |
| 0 | 0 | 0 | 1 | 1 |   | 1 | 0 | 0 | 1 | 0 |
| 0 | 0 | 1 | 0 | 0 |   | 1 | 0 | 1 | 0 | 1 |
| 0 | 0 | 1 | 1 | 0 |   | 1 | 0 | 1 | 1 | 1 |
| 0 | 1 | 0 | 0 | 1 |   | 1 | 1 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 | 1 |   | 1 | 1 | 0 | 1 | 0 |
| 0 | 1 | 1 | 0 | 1 |   | 1 | 1 | 1 | 0 | 1 |
| 0 | 1 | 1 | 1 | 1 |   | 1 | 1 | 1 | 1 | 1 |

Draw the Karnaugh map with `AB` down the rows and `CD` across the columns, both in Gray-code order,
and derive a minimal sum-of-products equation. Give each group's cells and its term. (4 marks)

**(b)** A colleague hands in this answer for the same function:

```text
X = A'C' + AC + A'B + BC
```

Every one of their four groups is a legal group. State whether the equation is **correct**, name
which group could be dropped, and give the rule from the Karnaugh-map procedure that drops it.

Then state how many different minimal answers this function has, and what that means for marking
somebody else's. (2 marks)

**(c)** `std_logic_vector` questions, one or two sentences each:

* `input` is declared `std_logic_vector(7 downto 0)` and passed as `input(7 downto 4)` to a port
  declared `std_logic_vector(3 downto 0)`. State which bit of the port `input(7)` drives, and the
  rule that decides it. What has to match, and what does not?
* `count` is a `std_logic_vector(3 downto 0)`. Say why `count + 1` does not compile, and why that is
  the type doing its job rather than a gap in the language.
* Give what this course uses instead for anything that is counted, and the two conversions that
  cross between the two worlds. (4 marks)

**(d)** Write two architectures for an entity computing `x = ab + c'd`: one as a single concurrent
expression, and one naming the intermediate term `c'd` in an internal signal.

State what synthesis produces for each, why your answer is the same for both, and which of the two
you would rather be handed six months from now. (2 marks)

**(e)** A colleague's 4-to-1 multiplexer. It compiles, its testbench passes, and it is wrong:

Its entity has four `std_logic` data inputs `a`, `b`, `c`, `d`, a `std_logic_vector(1 downto 0)`
selector `sel`, and a `std_logic` output `x`.

```vhdl
architecture behaviour of word_mux is
begin
    process(sel) is
    begin
        case sel is
            when "00"   => x <= a;
            when "01"   => x <= b;
            when "10"   => x <= c;
            when others => x <= d;
        end case;
    end process;
end architecture;
```

State what a **simulator** does with this and what **synthesis** does with it, say why the two
answers differ, and name the general class of bug that puts this design in. (2 marks)

---

## Question 3 - Storage, and the two ways a value updates (13 marks)

**(a)** An edge-triggered D flip-flop is built from two D latches in series, a master-slave pair.

State how the two latches are driven relative to each other, and derive from that why the output can
change only at the instant the clock goes low to high, and never while it sits at either level.

Then state the latch's fundamental weakness on its own, and why that weakness is much harder to live
with in a large synchronous system than in a small one. (3 marks)

**(b)** Write a 4-bit register: entity `register4`, ports `clock`, `reset_n`, `enable` (in), `d`
(`std_logic_vector(3 downto 0)`, in) and `q` (`std_logic_vector(3 downto 0)`, out), in that order.
The reset is asynchronous and active-low, and `enable` gates whether a rising edge captures `d`.

Then state how many flip-flops the design puts on the FPGA and what decides that number, and say
whether writing the reset branch before or after the `rising_edge` branch is a matter of style or of
meaning. (4 marks)

**(c)** A colleague wants `q` to follow `din` after exactly **one** clock cycle. It compiles, and
`q` follows `din` after **two**:

```vhdl
DELAY_PROCESS: process(clock, reset_n) is
begin
    if (reset_n = '0') then
        stage2_s <= '0';
        stage1_s <= '0';
    elsif (rising_edge(clock)) then
        stage2_s <= stage1_s;
        stage1_s <= din;
    end if;
end process;

q <= stage2_s;
```

Both are architecture signals. The author's reasoning was that the first line reads `stage1_s` after
the second line has already put `din` into it, so `stage2_s` would land one edge behind `din`.

Trace `stage1_s`, `stage2_s` and `q` through four rising edges with `din` carrying `0`, `1`, `0`,
`0`, starting from reset. Name the rule that makes the author's reasoning wrong.

Then state what changes if the two assignments are swapped, and why. Finally, give the change that
really does make `q` follow `din` after one cycle, and say how many flip-flops synthesis puts on the
FPGA for the listing as written and how many after your change. (4 marks)

**(d)** Synchronous designs pick one clock edge and update every flip-flop on that edge and only
that edge. State why, and what that buys somebody trying to reason about a circuit too large to see
all at once. (2 marks)

---

## Question 4 - One module, several widths (13 marks)

**(a)** Write `button_sync`: the three-flip-flop chain that synchronizes a set of active-low push
buttons and turns each press into a one-cycle pulse.

```vhdl
entity button_sync is
    generic(COUNT: natural range 1 to 3 := 1);
    port(clock, reset_s2_n: in  std_logic;
         button_n         : in  std_logic_vector(COUNT-1 downto 0);
         button_edge_s2   : out std_logic_vector(COUNT-1 downto 0));
end entity;
```

Write the architecture in full. Then state which flip-flops are the synchronizer and which is the
edge detector, what value the chain resets to and why the other value would be wrong, and why this
module's reset port is `reset_s2_n` rather than `reset_n`. (5 marks)

**(b)** `button_sync` carries a generic and `reset_sync` carries none.

State the rule that decides it, and what would be wrong with adding a `WIDTH` generic to
`reset_sync` for symmetry. Then say where in the built circuit `COUNT` ends up, how many flip-flops
an instance at `COUNT = 2` uses against one at `COUNT = 1`, and what a `generic map` costs in
hardware. (3 marks)

**(c)** In this lecture's CircuitVerse exercises the chain above appears to debounce the button
perfectly. On the DE0-CV at 50 MHz it does not, and one physical press can toggle an LED several
times.

Explain both observations with one mechanism, name what a real debounce circuit adds, and say why it
sits **on top of** the synchronizer rather than instead of it. (2 marks)

**(d)** The rule is that every asynchronous input gets its own double-flop chain before anything
else looks at it. Two limits on that rule matter:

* `seq_detect_mealy` synchronizes `reset_n` but sends `din` straight into the machine. State why,
  and what synchronizing `din` would cost.
* `serial_rx8`, `timer` and `counter` all declare their reset port as `reset_s2_n`, and
  `walking_led` declares its as `reset_n`. State the rule that separates the two, and what goes
  wrong if a subcomponent is wired straight to a push button. (3 marks)

---

## Question 5 - Two kinds of update, and a speed limit (13 marks)

**(a)** Give the four-row comparison between a `signal` and a `variable`: where each is declared,
where each is visible, when an assignment to each takes effect, and what happens when each is
assigned twice in one pass through a process.

Then give the rule of thumb for choosing between them. (3 marks)

**(b)** Write `ones_count8`: a combinational entity counting how many bits of an 8-bit input are
set.

| Port | Direction | Type |
|---|---|---|
| `bits` | in | `std_logic_vector(7 downto 0)` |
| `ones` | out | `natural range 0 to 8` |

Use a single process and a loop.

Then answer: `ones` is a `natural range 0 to 8` rather than a `std_logic_vector(3 downto 0)`, and
both can hold the answer. State what the range buys you, and what GHDL would do if your count ever
left it. (4 marks)

**(c)** Signals take time to get through a LUT and along the wires between blocks, so a clock cannot
go arbitrarily fast.

Name the three delays a clock period has to cover for the standard flip-flop / logic / flip-flop
path, define the critical path and Fmax in terms of them, and state what happens in the second
flip-flop if the period is too short.

Then: adding registers to a design adds hardware, and can make it **faster**. Explain how, and state
what it trades away. Finally, say what Quartus needs before it will report an Fmax at all, and why a
design with no constraint gets no number rather than a good one. (4 marks)

**(d)** A `variable` retains its value between activations of its process, behaving like static
local storage rather than a fresh local each time.

State what that means for a loop accumulator that is not cleared at the top of every activation, and
give the value such an accumulator would report over a long run. Then say why the course still
tells you to reach for a `signal` when state genuinely has to persist and be read by other
logic. (2 marks)

---

## Question 6 - Counting to something that is not a power of two (12 marks)

**(a)** Write `counter10`: a modulo-10 counter, counting `0` to `9` and returning to `0`. This is
a deliberately fixed-radix variant of L06's `counter`, which takes its radix as a generic and is
written to compare against `RADIX-1`; here the radix is wired in, so the comparison is against a
literal and the entity carries an `enable` instead of a `tick`.

| Port | Direction | Type |
|---|---|---|
| `clock` | in | `std_logic` |
| `reset_s2_n` | in | `std_logic` |
| `enable` | in | `std_logic` |
| `count` | out | `natural range 0 to 9` |

Then state which lines of your architecture would be unnecessary if the range were `0 to 15`
instead, and why exactly those. (4 marks)

**(b)** Write the architecture of `piso8`, a parallel-in/serial-out shift register:

```vhdl
entity piso8 is
    port(clock, reset_s2_n, load, shift, serial_in: in  std_logic;
         parallel_in                              : in  std_logic_vector(7 downto 0);
         serial_out                               : out std_logic);
end entity;
```

`load` takes precedence over `shift`. Then state which bit of a loaded value leaves first, and name
the **two** things that separate this architecture from a serial-in/parallel-out one - the shift
expression is not one of them. (4 marks)

**(c)** A colleague modifies `serial_rx8` so that `shift_enable` gates the shift register but not
the bit counter, which now advances on every clock edge.

The transmitter sends three bits, pauses for five clock cycles, then sends the remaining five. State
what the receiver does, on which edge `data_ready` first pulses, and what is on `data_out` when it
does. (2 marks)

**(d)** A counter and a shift register are both "N flip-flops sharing one clock". State, for each,
what feeds flip-flop `i`'s `D` input, and use the two answers to say what the difference between the
two circuits actually is. (2 marks)

---

## Question 7 - Turning ticks into time (10 marks)

**(a)** A design needs an LED that blinks at a visible rate, driven by this course's `timer`, whose
`timeout` toggles the LED.

State how many clock cycles a 100 ms timeout takes at 50 MHz, and give the `TICK_COUNT` for it, both
as the round number the course writes and as the cycle-exact value.

Then give the resulting **blink** frequency in Hz, and say why it is half the number somebody would
first write down. (3 marks)

**(b)** `timer`'s `enable` freezes the timer rather than clearing it: while it is low, the counter
holds its value and `timeout` stays low.

State what that means for the first timeout after a design re-enters a state that uses the timer,
compared with what a clearing enable would give. Then say whether holding `enable` high permanently
would be better or worse, and for what. (2 marks)

**(c)** Write `blinker`: a top-level design blinking an LED with no button at all.

```vhdl
entity blinker is
    generic(TICK_COUNT: natural := 25_000_000);
    port(clock, reset_n: in  std_logic;
         led           : out std_logic);
end entity;
```

Write the architecture. It instantiates two modules and contains one process of its own. (3 marks)

**(d)** A button controlling a timer has nothing to do with counting, and a designer proposes wiring
it straight to the timer's `enable`.

State why it must go through a synchronizer first, and what specifically the design would do on a
real press without one. (2 marks)

---

## Question 8 - The output that arrives a cycle early (13 marks)

**(a)** Write `seq_detect_01_mealy`: a **Mealy** machine watching a serial input `din`, one bit per
clock cycle, whose output `y` is high whenever the previous bit was `0` and the current bit is `1` -
a rising edge on the data itself.

| Port | Direction | Type |
|---|---|---|
| `clock` | in | `std_logic` |
| `reset_n` | in | `std_logic` |
| `din` | in | `std_logic` |
| `y` | out | `std_logic` |

Write the module in full: enumerated state type, transition process, and output. Two states are
enough; say what each one means.

Then name the **one line** that makes this a Mealy machine, and say what `when others` buys you in
the transition `case` given that `state_t` has only the values you declared. (5 marks)

**(b)** The Moore machine detecting the same thing needs one state more than yours. State why, what
its output does differently, and which of the two you should reach for by default with the reason.
(2 marks)

**(c)** The capstone receiver recovers its bit timing from the falling edge of a start bit and
nothing else.

* At 50 MHz and 9600 baud, how many clock cycles is one bit period, and how many is a sixteenth of
  one?
* This course's `timer` pulses every `TICK_COUNT + 1` clock cycles. The exact sixteenth is not a
  whole number, so there are two candidate `TICK_COUNT` values either side of it. Give both, give
  the error each leaves, and say which one the capstone's default of `325` is and why.
* State why the receiver samples in the **middle** of each bit rather than near a boundary, in terms
  of what it is tolerating.
* Ten bit periods after the start edge, how far has the sample point drifted, in oversample ticks,
  and how many ticks of margin did it start with? (4 marks)

**(d)** The capstone's `STATE_IDLE` leaves on a falling **edge** of the synchronized line, not on
the line being low, which costs one extra flip-flop.

Consider a **break**: the line held low for far longer than a frame, which is what a transmitter
losing power looks like. State what a level test does during the break and what it does at the
moment the break ends, and say why that last frame is the one that matters. (2 marks)

---
