# Paper B - Solutions

Marks are shown per part. Method carries them: a correct derivation with a slip in it is worth more
than a correct answer with no working, and later parts consume earlier ones, so an error should be
followed through rather than penalised twice.

Where a part asks for VHDL, mark the **hardware described**, not the syntax. A listing with a
missing semicolon and the right circuit in it scores full marks; a listing that compiles and infers
a latch does not.

---

## Question 1 - A requirement, and the shape of the network it asks for (12 marks)

### (a) 2 marks

```text
run = left · right · curtain_clear · estop_n
```

*(1 mark)*

**Gates.** One four-input AND, or three two-input ANDs if the library has nothing wider. **No
inverter**, which is worth noticing before part (c) asks about it: the condition wanted is "the stop
has *not* been pulled", and that is `estop_n = 1` as it stands.

**The table.** Four inputs, sixteen rows, and exactly **one** of them is `1`: the row where all four
are `1`.
*(1 mark)*

### (b) 4 marks

```text
run = estop_n · ( maint'·left·right·curtain_clear  +  maint·pedal )
```

*(1 mark)*

**The factored input: `estop_n`.** It multiplies the whole sum rather than appearing inside either
branch.

**What that expresses.** No mode can bypass the emergency stop. It is not an input to the mode
logic; it gates the mode logic's result. A third mode added next year cannot accidentally create a
path that runs the press with the stop pulled, because every path goes through the same AND.
*(1 mark)*

**The contrast.**

| | Braking assistant | Press control |
|---|---|---|
| Shape | `engine_brake = driver_brake + adas_brake` | `run = estop_n · (mode logic)` |
| The override | is ORed in **last**, outside the fault logic | is ANDed in **last**, outside the mode logic |
| Forces the output | **high** | **low** |
| Guarantees | the action is always **available**: the driver can always brake, including when the assistance system is faulty and doing nothing | the action can always be **prevented**: the press never cycles with the stop pulled, in any mode |

**What routing the override through the logic would cost, in each case.** The same structural
mistake with opposite consequences, which is why the two are worth seeing together. Feed
`driver_brake` through the assistance system's fault logic and a fault stops the driver braking -
the safety requirement the structure exists to protect. Feed `estop_n` into only one branch of the
sum, say the maintenance branch, and pulling the stop no longer stops the press in normal mode. Both
are one wire in the wrong place, and neither shows up in a test that only exercises the happy path.
*(1 mark)*

**The count.** Sixty-four rows, of which **10** are `1`:

* `estop_n = 1` throughout, `maint = 0`: needs `left = right = curtain_clear = 1`, `pedal` free - 2
  rows.
* `estop_n = 1`, `maint = 1`: needs `pedal = 1`, the three others free - 8 rows.

**What the table would have cost you.** Ten AND-terms of six literals each, from a requirement that
is two clauses long, plus the whole job of simplifying them back down. The structure came out of the
*statement* in one line. That is the case L01 A.6 makes with the braking assistant: derive from the
requirement, and use the table to check the answer rather than to find it.
*(1 mark)*

### (c) 3 marks

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity press_control is
    port(left, right, curtain_clear, estop_n, maint, pedal: in  std_logic;
         run                                              : out std_logic);
end entity;

architecture behaviour of press_control is
-- The two mode branches, before the emergency stop gates either of them.
signal two_hand, maintenance: std_logic;
begin
    two_hand    <= (not maint) and left and right and curtain_clear;
    maintenance <= maint and pedal;

    run <= estop_n and (two_hand or maintenance);
end architecture;
```

*(2 marks: 1 for the entity with the ports in order, 1 for an architecture matching the candidate's
own (b). The internal signals are optional; a single collapsed expression is equally correct.)*

**Where the `not` is, and where it is not.** The one inversion is on `maint`, an **active-high**
signal that has to be *false* for the two-hand branch. `estop_n`, the **active-low** signal, needs
no inversion at all.

**The rule.** An `_n` suffix says what a `0` on that wire means; it does not say that an inversion
is needed. Write down the condition you want first, then invert whatever does not already say it.
"Active-low, therefore `not`" is the reflex to lose: here it would have produced a press that runs
only while the emergency stop is pulled.
*(1 mark)*

### (d) 3 marks

**The two parts.** The `entity` is the black-box view: the ports, and nothing about what happens
inside. The `architecture` is the implementation behind it.
*(1 mark)*

**What the split makes possible.**

* One design can **instantiate** another knowing only its entity, without reading the architecture.
* An implementation can be **rewritten** without touching anything that depends on it, because
  nothing that depends on it was allowed to see it.

*(1 mark)*

**What is different from a C header.** The shape is the same - a header beside a source file, or an
interface beside its class - but VHDL **enforces** it, for every module, with no way to skip the
interface and no way to leak the implementation through it. A C header is a convention: the compiler
does not require one, nothing stops a translation unit from exposing its internals, and the
interface and the implementation can disagree until the linker or the run finds out. In VHDL the
entity is the only way in.
*(1 mark)*

---

## Question 2 - The map, the vector, and the process that lies (14 marks)

### (a) 4 marks

The map, `AB` down the rows and `CD` across, both in Gray-code order `00, 01, 11, 10`:

| `AB` \ `CD` | `00` | `01` | `11` | `10` |
|---|---|---|---|---|
| `00` | **1** | **1** |  |  |
| `01` | **1** | **1** | **1** | **1** |
| `11` |  |  | **1** | **1** |
| `10` |  |  | **1** | **1** |

*(1 mark for the filled map)*

**A minimal cover, three groups of four:**

| Group | Cells | Constant | Term |
|---|---|---|---|
| The top-left block | `0000`, `0001`, `0100`, `0101` | `A = 0`, `C = 0` | `A'C'` |
| The bottom-right block | `1010`, `1011`, `1110`, `1111` | `A = 1`, `C = 1` | `AC` |
| The whole `AB = 01` row | `0100`, `0101`, `0111`, `0110` | `A = 0`, `B = 1` | `A'B` |

```text
X = A'C' + AC + A'B
```

*(3 marks: 1 per group with its cells and term. Nothing here wraps: all three groups are
rectangles you can draw without leaving the map, which is what makes this one easier to see than
the four-corner shapes. `A'B` may be replaced by `BC` throughout - see (b).)*

### (b) 2 marks

**The colleague's answer.** `X = A'C' + AC + A'B + BC` is **correct**: it computes the same
function, since every group in it is a legal group of cells that are genuinely `1`. It is not
minimal.

**Which group to drop: either `A'B` or `BC`, but not both.** `A'C'` and `AC` are forced - `0000`
and `0001` sit in no other legal group of four, and neither do `1010` and `1011` - and between them
they leave exactly two cells uncovered, `0110` and `0111`. Both `A'B` and `BC` cover that pair, and
each of them has its other two cells already covered by one of the forced groups. So one of the two
is redundant and either one may go.

The rule is step 3 of the procedure: **use as few groups as will do it, and drop any group whose
cells are every one of them already covered by another.** Nothing in the earlier steps forbids a
redundant group, which is exactly why the step exists - a redundant group is a redundant AND-term,
correct but not minimal.
*(1 mark)*

**How many minimal answers.** **Two.**

```text
X = A'C' + AC + A'B        and        X = A'C' + AC + BC
```

are both three terms of two literals, and both minimal. What that means for marking: check the
**function**, not the string. Two candidates can hand in different equations and both be right, and
the only way to tell is to evaluate. What is *not* right is keeping both, which is the colleague's
answer.
*(1 mark)*

### (c) 4 marks

**Slicing.** `input(7)` drives **bit 3** of the port. The two are matched **by position, left to
right**, not by index number: `input(7)` drives bit 3, `input(6)` drives bit 2, and so on. The
**lengths** have to match; the **numbering** does not. `input(7 downto 4)` really does have the
index range `7 downto 4` and not `3 downto 0`, which is the detail that surprises a software
engineer.
*(2 marks)*

**Why `count + 1` does not compile.** `std_logic_vector` says nothing about what the bits *mean*, so
it offers only the operations that make sense for a bundle of wires: the logical operators applied
bit by bit, comparison, and concatenation. Arithmetic is not on that list because nothing has
declared whether those four wires are an unsigned number, a signed one, or four unrelated signals.
That is the type doing its job: the meaning genuinely is missing, so the operation is refused rather
than guessed at.
*(1 mark)*

**What this course uses instead.** A plain integer with a range:

```vhdl
signal count: natural range 0 to 9;
```

which adds and compares directly, and which synthesis turns into exactly the flip-flops the range
needs. Vectors stay what they are, bundles of wires for things that really are bundles of wires. The
two worlds meet only at a boundary, with the conversions from `ieee.numeric_std`:

```vhdl
count_v <= std_logic_vector(to_unsigned(count, 4));   -- integer to vector
count   <= to_integer(unsigned(count_v));             -- vector to integer
```

*(1 mark)*

### (d) 2 marks

```vhdl
-- One expression.
x <= (a and b) or ((not c) and d);
```

```vhdl
-- The same circuit, with the second term named.
architecture behaviour of combo_logic is
signal cd: std_logic;
begin
    cd <= (not c) and d;
    x  <= (a and b) or cd;
end architecture;
```

*(1 mark for both)*

**What synthesis produces: the same circuit, twice.** An internal signal names a wire that already
existed in the first version - the output of the AND gate computing `c'd` - so nothing has been
added. On the Cyclone V both are one LUT, because a LUT is a lookup table over its inputs: a
function of four or fewer inputs fits in one however it was written, and naming an intermediate
term does not add an input. The answer is the same for both because VHDL describes hardware, and the
two descriptions describe the same hardware.

**Which to be handed in six months.** At two terms, honestly, either; the named version's advantage
appears as soon as the expression outgrows one line, and the habit is worth having before you need
it. An answer that simply asserts "the named one is always better" is worth less than one that says
where the line is.
*(1 mark)*

### (e) 2 marks

**What a simulator does.** The process re-runs only when a signal in its **sensitivity list**
changes, and the list holds only `sel`. So a change on `a`, `b`, `c` or `d` while `sel` holds still
is invisible: `x` keeps whatever value it took the last time `sel` moved. That is not a multiplexer.
It behaves like a multiplexer whose output is captured whenever the selector changes and held in
between.

**What synthesis does.** It builds the multiplexer. The tool reads the logic, works out that `x`
depends on `sel`, `a`, `b`, `c` and `d`, and produces a real 4-to-1 mux - usually emitting a warning
that the sensitivity list is incomplete, and ignoring it either way.
*(1 mark)*

**Why they differ.** The sensitivity list is a **simulation** construct: it tells the simulator when
to re-evaluate the process. It is not hardware, so there is nothing for the synthesis tool to build
from it.

**The class of bug: the simulator and the chip model different things.** That is the one class where
a green testbench stops meaning anything, because the thing that passed is not the thing that ships.
The course's other example is the opposite direction - GHDL aborting on a counter wrap the drawing
and the chip both perform happily. The lesson is the same in both: where the two models disagree,
neither one alone is evidence.
*(1 mark)*

Worth a comment rather than a mark: the testbench passes here only because it changes `sel` for
every case it checks. One that held `sel` still and varied the data would fail immediately, which is
a useful thing to know about your own testbenches.

---

## Question 3 - Storage, and the two ways a value updates (13 marks)

### (a) 3 marks

**How the two latches are driven.** In opposition. The master's own transparency control is the
inverted clock and the slave's is the clock, so exactly one of the two is ever transparent.

**Why that gives edge triggering.** While the clock is **low** the master is transparent and follows
`D`, and the slave is closed, holding `Q`. At the **rising edge** the master closes, freezing
whatever `D` was at that instant, and the slave opens and passes that frozen value to `Q`. While the
clock is **high** the slave is transparent but its input cannot change, because the master ahead of
it is closed; so `D` may do anything it likes and `Q` will not move. At the falling edge the slave
closes and the master reopens for the next capture.

The net effect is that exactly one value passes per period, captured at the instant the clock goes
low to high, and `Q` never changes while the clock sits at either level. That external behaviour is
what `rising_edge()` models.
*(2 marks)*

**The latch's weakness.** It is transparent for the *entire* time `enable` is high, so any glitch on
`D` during that window passes straight through to `Q`.

**Why that is worse in a large system.** In a small circuit you can look at every path feeding `D`
and convince yourself it is stable across the phase. In a large one there are thousands, each with
its own delay, and guaranteeing that all of them are settled throughout an entire clock phase is far
harder than guaranteeing they are settled at one instant - which is all the flip-flop asks for.
*(1 mark)*

### (b) 4 marks

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity register4 is
    port(clock, reset_n, enable: in  std_logic;
         d                     : in  std_logic_vector(3 downto 0);
         q                     : out std_logic_vector(3 downto 0));
end entity;

architecture behaviour of register4 is
begin
    REGISTER_PROCESS: process(clock, reset_n) is
    begin
        if (reset_n = '0') then
            q <= (others => '0');
        elsif (rising_edge(clock)) then
            if (enable = '1') then
                q <= d;
            end if;
        end if;
    end process;
end architecture;
```

*(2 marks: 1 for the entity and port order, 1 for the process with `clock` and `reset_n` in the
sensitivity list, the reset branch outside the clocked branch, and the enable inside it)*

`q` is only ever assigned here, never read, so no internal signal is needed. A design that toggles
or otherwise reads its own output does need one, because an output port cannot be read back.

**Flip-flops: four.** What decides it is the **width of the signal assigned inside the clocked
process** - every signal assigned there becomes flip-flops, one per bit. Four bits, one process,
four flip-flops, no different in principle from four `d_flip_flop` instances wired in parallel.
*(1 mark)*

**Reset branch first: meaning, not style.** The `if`/`elsif` is read in priority order, so the reset
branch coming first is what makes the reset take priority and act with no clock edge involved. Put
`rising_edge(clock)` first and the reset is only examined at an edge, which is a **synchronous**
reset: a different circuit, one that ignores a reset pulse landing entirely between two edges. It is
also the shape the synthesis tool pattern-matches to infer an asynchronous reset at all.
*(1 mark)*

### (c) 4 marks

**The trace.** Both are signals, so both assignments **schedule**: neither takes effect until the
process suspends, and every right-hand side in the pass reads the value the signal held *before* the
edge. `stage2_s <= stage1_s;` therefore reads the old `stage1_s`, not the `din` the line below is
putting there, and the two lines describe two flip-flops in series.

| Edge | `din` | `stage1_s` after | `stage2_s` after | `q` after |
|---|---|---|---|---|
| (after reset) | - | `0` | `0` | `0` |
| 1 | `0` | `0` | `0` | `0` |
| 2 | `1` | `1` | `0` | `0` |
| 3 | `0` | `0` | `1` | `1` |
| 4 | `0` | `0` | `0` | `0` |

The `1` on `din` at edge 2 reaches `stage1_s` at edge 2 and `q` at edge 3: **two** edges, not one.
*(2 marks: 1 for the table, 1 for reading each right-hand side against the pre-edge value rather
than asserting the answer)*

**The rule.** A signal assignment inside a process **schedules** a new value, applied only when the
process suspends; every read in the same pass sees the old value. It is the same rule L03 states for
the two-assignment process, and it is what lets a clocked process describe a chain of flip-flops in
whatever order the lines happen to be written.

**Swapping the two assignments changes nothing.** Write `stage1_s <= din;` first and `stage2_s <=
stage1_s;` second, and `stage2_s` still reads the pre-edge `stage1_s`, because scheduling does not
care which line came first. That is the point worth taking away: **with signals in a clocked
process, order does not matter**, which is exactly why the author's line-order reasoning was the
wrong tool. A `variable` is the object for which order *would* matter, and L05 is where the course
picks that up.
*(1 mark)*

**The change that gives one cycle.** Delete `stage2_s` and drive the output from the first stage:
`stage1_s <= din;` in the process, `q <= stage1_s;` outside it. One assignment, one register.

**Flip-flops.** The listing as written builds **two** - `stage1_s` and `stage2_s` are each assigned
under `rising_edge(clock)` with an asynchronous reset, which is a flip-flop apiece; `q <= stage2_s;`
is a wire and costs nothing. After the fix, **one**. The extra edge of latency and the extra
flip-flop are the same fact seen from two sides.
*(1 mark)*

### (d) 2 marks

**Why one edge.** Every flip-flop in the design changes at the same well-defined instants, so the
circuit's behaviour is defined at a sequence of points rather than continuously.
*(1 mark)*

**What that buys.** It turns a continuous-time problem into a discrete one. You can reason **one
clock cycle at a time** - "given the state at this edge, what is the state at the next?" - instead
of tracking every signal continuously and worrying about the order in which things happen in
between. Between edges, nothing has to be true except that everything settles before the next one
arrives, which reduces the whole timing question for an arbitrarily large design to a single number:
the longest path against the period. That is what makes a circuit too large to see all at once
analyzable at all, by you or by the tool.
*(1 mark)*

---

## Question 4 - One module, several widths (13 marks)

### (a) 5 marks

```vhdl
library ieee;
use ieee.std_logic_1164.all;

architecture behaviour of button_sync is
-- Three stages, each COUNT bits wide: two synchronizing, one remembering.
signal button_s1_n, button_s2_n, button_s3_n: std_logic_vector(COUNT-1 downto 0);
begin
    -- Falling edge: pressed now, released the cycle before. Bit by bit.
    button_edge_s2 <= (not button_s2_n) and button_s3_n;

    BUTTON_PROCESS: process(clock, reset_s2_n) is
    begin
        if (reset_s2_n = '0') then
            button_s1_n <= (others => '1');
            button_s2_n <= (others => '1');
            button_s3_n <= (others => '1');
        elsif (rising_edge(clock)) then
            button_s1_n <= button_n;
            button_s2_n <= button_s1_n;
            button_s3_n <= button_s2_n;
        end if;
    end process;
end architecture;
```

*(3 marks: 1 for three vector signals declared in terms of `COUNT`, 1 for the three-stage chain in a
clocked process with an asynchronous reset, 1 for the edge expression as a concurrent assignment
outside the process. Deduct nothing for writing the edge inside the process as a registered pulse,
provided the candidate says it arrives a cycle later.)*

**Which flip-flops do what.** Stages 1 and 2 are the **double-flop synchronizer**, so `button_s2_n`
is the stable, safe-to-use current value. Stage 3 stores last cycle's `button_s2_n` and is the
**edge detector's own** flip-flop; comparing stage 2 against stage 3 gives edge detection for free,
high for exactly one clock cycle.
*(1 mark)*

**The reset value: `(others => '1')`.** The buttons are active-low, so `1` means released. Reset the
chain to `0` and it comes up claiming every button is already held down, which is a lie about the
world for the two cycles it takes the real level to propagate - and, concretely, a press that is
already being held when the reset is released is **lost**, because the chain never sees a
high-to-low transition on it. This is the same reason L04's CircuitVerse drawing ties `preset` to
`1` on these three flip-flops and leaves it alone on the reset synchronizer's two.
*(1 mark)*

**Why `reset_s2_n`** - worth a comment rather than a mark, and the one place a candidate reveals
whether they know why the port is named as it is. This is a **subcomponent**. A synchronizer does not synchronize its own reset;
`reset_sync` does that, and the design that owns the pin instantiates it. Reading the `_s2` as a
requirement on the caller is the habit worth having, because from L06 on most of what you write is a
subcomponent.

### (b) 3 marks

**The rule: add a generic when something genuinely varies between instances, not on principle.**
`button_sync` is instantiated at `COUNT = 1` by `led_toggle_sync` and `walking_led`, and at
`COUNT = 2` by `fsm_led`: two widths, one file, and that second instantiation is what makes the
generic worth having. `reset_sync` is one bit everywhere.

**What a `WIDTH` on `reset_sync` would be.** A parameter nobody ever passes anything but `1` to:
pure indirection, and one more thing for a reader to check before they can be sure what an instance
is.
*(1 mark)*

**Where `COUNT` ends up: nowhere.** It is fixed before a single gate is placed, so it does not
appear in the built circuit as logic at all. What it did was decide how many flip-flops to
instantiate and how wide the ports are, and then it was gone - the same thing that happens to a
`for` loop's bounds in L05.
*(1 mark)*

**Flip-flop counts.** Three stages, `COUNT` bits each: `COUNT = 2` gives **6** flip-flops (plus two
inverters and two AND gates for the edge), `COUNT = 1` gives **3**. A `generic map` itself costs
nothing in hardware; it is an elaboration-time decision, not a runtime one.
*(1 mark)*

### (c) 2 marks

**One mechanism explains both.** The chain samples the button once per clock edge, and whether that
*looks* like debouncing depends entirely on the clock period relative to the bounce time.

* In CircuitVerse the period is a full second. Bounce settles in far less than that, so every bounce
  transition happens **between** two samples and by the next edge the chain reads one clean level.
  The circuit is not debouncing; it is sampling too infrequently to see bounce.
* At 50 MHz the period is 20 ns, and bounce lasts from under a millisecond to a few tens of
  milliseconds - many thousands of cycles. The chain faithfully detects **every** bounce transition
  as its own edge, so one physical press produces several pulses and the LED toggles several times.

*(1 mark)*

**What a real debounce adds**, either of:

* an **analog RC low-pass filter**, optionally with a Schmitt-trigger buffer, on the input before it
  reaches the pin: the RC pair smooths the fast make/break transitions into one gradual edge and the
  Schmitt trigger's two thresholds turn that back into one clean digital transition; or
* a **digital debounce counter**: require the input to hold a new level for a few milliseconds'
  worth of clock cycles before accepting it, which builds the artificially slow detection window
  on-chip without slowing the system clock.

**Why on top rather than instead.** Even a perfectly debounced signal is still asynchronous to your
clock: it can still change inside the setup/hold window and still drive a flip-flop metastable.
Debouncing solves a mechanical problem and synchronizing solves a timing one, and neither solves the
other.
*(1 mark)*

### (d) 3 marks

**`din` against `reset_n` in `seq_detect_mealy`.** `din` is **synchronous serial data**, already
clocked by this clock, so it is not an asynchronous input and the rule does not apply to it.
Synchronizing it anyway would delay it by two clock cycles and shift its timing relative to
everything around it - in a sequence detector that means the machine is looking at a different part
of the sequence than everything else believes, so the bug is a wrong answer rather than a slow one.
`reset_n` comes from a push button and is asynchronous, so it does get a chain. The rule is about
where a signal comes from, not about being cautious.
*(1 mark)*

**`reset_s2_n` against `reset_n`.** The port name says which side of the boundary the module is on:

* A **subcomponent** takes `reset_s2_n` and never touches a raw asynchronous input. It is a part,
  and a part is entitled to assume the design around it has done the synchronizing. `serial_rx8`,
  `timer`, `counter`, `sipo8`, `piso8` and `sync` are all written this way.
* A **top level** takes `reset_n`, because it is the thing holding the pin, and it instantiates
  `reset_sync` itself. `walking_led`, `blinker`, `fsm_led` and both capstones are written that way.

*(1 mark)*

**What goes wrong if a subcomponent is wired straight to a push button.** The reset is then released
asynchronously, so the module's flip-flops leave reset on different clock edges. In `serial_rx8`
that is a dozen flip-flops between the shift register and the bit counter, and a receiver that
starts counting a byte one cycle before it starts shifting one is broken by its own reset - a fault
that appears once in a while, at power-on, and never in a testbench that resets cleanly.
*(1 mark)*

---

## Question 5 - Two kinds of update, and a speed limit (13 marks)

### (a) 3 marks

| | `signal` (`<=`) | `variable` (`:=`) |
|---|---|---|
| Declared | The architecture's declarative part | The process's declarative part |
| Visible from | Anywhere in the architecture | Only within its own process |
| Update timing | **Scheduled**: applied when the process next suspends | **Immediate**: applied before the next statement |
| Assigned twice in one pass | Only the last survives; earlier ones are discarded | Every one takes effect, in order |

*(2 marks, or 1 for two of the four rows)*

**The rule of thumb.** Use a **variable** for a scratch computation consumed entirely within one
pass: loop accumulators, temporary swaps, an intermediate value handed to a signal at the end. Use a
**signal** for anything another process or the outside world reads, and for anything that has to
hold its value across separate passes - a counter, a shift register's stored bits, the previous
value in an edge detector.
*(1 mark)*

### (b) 4 marks

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity ones_count8 is
    port(bits: in  std_logic_vector(7 downto 0);
         ones: out natural range 0 to 8);
end entity;

architecture behaviour of ones_count8 is
begin
    COUNT_PROCESS: process(bits) is
        variable count: natural range 0 to 8;
    begin
        count := 0;
        for i in bits'range loop
            if (bits(i) = '1') then
                count := count + 1;
            end if;
        end loop;
        ones <= count;
    end process;
end architecture;
```

*(3 marks: 1 for a `variable` accumulator assigned with `:=`, 1 for clearing it at the top of every
activation, 1 for `bits` in the sensitivity list and a single assignment to `ones` after the loop)*

A `signal` accumulator here scores none of the three: the assignments schedule rather than take
effect, so only the last of the nine survives and `ones` reports the final bit rather than a
count.

**What the range buys.** Two things, one for each tool. It tells **synthesis** exactly how many bits
the value needs - four, for `0` to `8` - so the register or the wires are sized to the value rather
than to whatever an unconstrained `natural` would give. And it is a **promise the simulator
checks**: `natural range 0 to 8` is range-checked, so GHDL aborts with a range-check failure at the
statement that broke it the instant the count leaves the range.

**What GHDL would do.** Stop, with an error naming the line, rather than carrying on with a wrong
number. A `std_logic_vector(3 downto 0)` would hold `9` through `15` quite happily and say nothing,
which is the difference between a bug that reports itself and one that does not.
*(1 mark)*

### (c) 4 marks

**The three delays** the clock period has to cover on a flip-flop / logic / flip-flop path:

1. the first flip-flop's **clock-to-Q** delay, between the edge and its output actually changing;
2. the **combinational delay** through the LUTs and the wires between the two;
3. the second flip-flop's **setup time**.

The **critical path** is the slowest such path in the design, and **Fmax** is one over that total.
*(2 marks)*

**If the period is too short**, the value has not settled when the second flip-flop samples, so it
captures something still changing - and the design does the wrong thing *reliably and mysteriously*,
which is worse than doing it intermittently, because it looks like a logic bug.

**Why adding registers can make a design faster.** Splitting a long combinational expression so that
part of the work happens on one cycle and the rest on the next shortens the longest path, and the
clock period only has to cover the longest path. It trades **latency** - more cycles before an
answer comes out - and some flip-flops, for **throughput**: a faster clock, and once the pipeline is
full, one result per cycle. That trade is the single most common move in high-speed digital design.
*(1 mark)*

**What Quartus needs before it reports an Fmax.** An `.sdc` constraints file with a `create_clock`
on the 50 MHz input. Without one the timing analyzer has no period to compare anything against, so
it reports every path as **unconstrained** and gives no Fmax at all - not an optimistic number, no
number. Separately, a design that "fails timing" is one where a path turned out slower than the
period you did declare, which is a different message and a different problem.

None of this is part of the course: every design here fits inside 20 ns with room to spare. Knowing
the step exists and what it needs is what is examinable.
*(1 mark)*

### (d) 2 marks

**An uncleared accumulator keeps growing.** The variable is not a fresh local on each activation, so
a pass that starts by adding to it is adding to the *previous* pass's total. Over a long run the
count climbs without bound: with a range-constrained type it aborts on a range check as soon as it
leaves the range, and with an unconstrained one it simply reports a number that means nothing. The
answer it reports is the running total of every activation since the simulation began, not a count
over `bits`.
*(1 mark)*

**Why a signal for persistent state anyway.** It is possible to build state with a variable, but its
updates are immediate rather than scheduled, so it behaves differently from a signal used the same
way. Question 3(c) is the mirror image: a chain of registers stepping one stage per clock edge is
exactly what scheduled updates give you for free, and a variable there would collapse the chain. A variable is also invisible outside its own process, so no
other logic can read it. Scheduled updates are what make counters and shift registers work, so if
state genuinely has to persist *and* be read elsewhere, reach for a signal.
*(1 mark)*

---

## Question 6 - Counting to something that is not a power of two (12 marks)

### (a) 4 marks

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity counter10 is
    port(clock, reset_s2_n, enable: in  std_logic;
         count                    : out natural range 0 to 9);
end entity;

architecture behaviour of counter10 is
-- Internal count, because an output port cannot be read back.
signal count_s: natural range 0 to 9;
begin
    count <= count_s;

    COUNT_PROCESS: process(clock, reset_s2_n) is
    begin
        if (reset_s2_n = '0') then
            count_s <= 0;
        elsif (rising_edge(clock)) then
            if (enable = '1') then
                if (count_s >= 9) then
                    count_s <= 0;
                else
                    count_s <= count_s + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
```

*(3 marks: 1 for the internal signal and the entity, 1 for the clocked process with the asynchronous
reset and the enable, 1 for the explicit comparison and clear)*

A candidate who writes `if (count_s = 9)` rather than `>=` loses nothing; `>=` is the defensive form
the course's `timer` uses.

**What would be unnecessary at `0 to 15`.** The whole comparison:
`if (count_s >= 9) then count_s <= 0; else ... end if`, leaving `count_s <= count_s + 1;` on its
own.

**Why exactly those.** `15` is `2^4 - 1`, so incrementing past it produces a carry out of the fourth
bit with nowhere to go, and the four bits that survive are `0000`. The wrap is a consequence of the
register's width - you can point at the bit it ran out of. `9` is not a power-of-two boundary, so
nothing in the hardware returns the count to zero there, and the comparison has to say so.

Worth noting, and worth a comment rather than a mark: the course writes the comparison out even at
`0 to 15`, because a VHDL simulator range-checks `natural range 0 to 15` and aborts on the wrap that
the gate network and the chip both perform happily. Anything you intend to verify should say what it
means.
*(1 mark)*

### (b) 4 marks

```vhdl
library ieee;
use ieee.std_logic_1164.all;

architecture behaviour of piso8 is
signal shift_reg: std_logic_vector(7 downto 0);
begin
    -- Bit 7 is always the next bit to leave.
    serial_out <= shift_reg(7);

    SHIFT_PROCESS: process(clock, reset_s2_n) is
    begin
        if (reset_s2_n = '0') then
            shift_reg <= (others => '0');
        elsif (rising_edge(clock)) then
            if (load = '1') then
                shift_reg <= parallel_in;                  -- Parallel load.
            elsif (shift = '1') then
                shift_reg <= shift_reg(6 downto 0) & serial_in;  -- Shift toward the MSB.
            end if;
        end if;
    end process;
end architecture;
```

*(3 marks: 1 for the load branch taking precedence over the shift branch, 1 for the shift expression
in this course's direction, 1 for tapping bit 7 as the serial output)*

What fills the vacated bit 0 is a wiring decision rather than a property of a PISO. Here it is
`serial_in`, so tying that low shifts zeros in behind the byte; `walking_led` instead wires the bit
falling off the top back round to it, which is what turns a one-shot pattern register into an
endlessly repeating pattern generator.

**Which bit leaves first: bit 7, the most significant.** Load `"10110010"` and `serial_out` presents
`1`, `0`, `1`, `1`, `0`, `0`, `1`, `0` over the following cycles.

**The two things that separate it from a SIPO**, the shift expression being identical in both:

1. PISO has a **`load` branch**, distinguishing loading a new parallel value from shifting the
   existing one out. SIPO has nothing to load.
2. PISO **taps `shift_reg(7)`** as a one-bit serial output, where SIPO drives the whole vector out
   in parallel.

"SIPO" and "PISO" name how you wire a shift register up, not two kinds of hardware.
*(1 mark)*

### (c) 2 marks

The bit counter now counts **clock edges** rather than bits, so it loses track of the byte the
moment the stream pauses.

| Edge | What arrives | `bit_count` after |
|---|---|---|
| 1 | bit 7 | 1 |
| 2 | bit 6 | 2 |
| 3 | bit 5 | 3 |
| 4 | (pause) | 4 |
| 5 | (pause) | 5 |
| 6 | (pause) | 6 |
| 7 | (pause) | 7 |
| 8 | (pause) | count was already 7: **`data_ready` pulses**, count clears to 0 |

So `data_ready` first pulses on the **eighth clock edge**, which is the fifth and last cycle of the
pause, five bits before the byte is complete.
*(1 mark)*

`data_out` at that moment holds the shift register's contents: the five reset zeros it started with,
followed by the three bits that really did arrive - `"00000"` then bits 7, 6 and 5 of the byte. And
it does not recover: the counter is now permanently out of step with the data, so every subsequent
"byte" is a window of eight clock edges rather than eight bits.

That is why `shift_enable` has to gate the counter as well as the shift. With both gated, a gap in
the stream **pauses** the receiver mid-byte rather than corrupting it, and it resumes on exactly the
bit it was waiting for - which is also what makes the board demonstration possible, one press per
bit.
*(1 mark)*

### (d) 2 marks

| | What feeds flip-flop `i`'s `D` |
|---|---|
| **Counter** | The adder's sum bit `i`: a function of the counter's own bit `i` and the carry out of every bit below it. The register's output feeds back into its own input through an adder. |
| **Shift register** | Flip-flop `i-1`'s `Q`, straight through, with bit 0's `D` coming from `serial_in`. No arithmetic anywhere. |

*(1 mark each)*

The difference between the two circuits is therefore not in the flip-flops, which are identical, and
not in the clocking, which is identical. It is entirely in the combinational network between one
stage's `Q` and the next stage's `D`: an adder in one case, a plain wire in the other. That is the
whole of it, and it is why both are "technically state machines" while neither is what L08 means by
one - the state is a count or a shifted pattern rather than a label whose meaning you chose.

---

## Question 7 - Turning ticks into time (10 marks)

### (a) 3 marks

**Cycles.** `0.1 s * 50,000,000 cycles/s = 5,000,000` clock cycles.

**`TICK_COUNT`.** The course writes `TICK_COUNT = 5_000_000`. The cycle-exact value is
`TICK_COUNT = 4_999_999`, because the internal counter runs `0` through `TICK_COUNT` inclusive, so a
full period is `TICK_COUNT + 1` cycles. The round number is 1 cycle long in 5,000,000, which is
0.2 ppm - far below the board oscillator's own tolerance, which is why the course quotes it.
*(2 marks)*

**Blink frequency: 5 Hz.** `timeout` fires every 100 ms, so the LED **toggles** ten times a second;
but one blink is on *and* off, so a full cycle takes two timeouts, 200 ms, giving 5 Hz. The number
somebody first writes down is 10 Hz, which is the timeout rate rather than the blink rate.
*(1 mark)*

### (b) 2 marks

**A freezing enable means the timer resumes rather than restarts.** Whatever was left of the period
when `enable` went low is what is left when it comes back, so the first timeout after re-entering
the state arrives anywhere between one clock cycle and a full period later, depending on where in
its count the timer was frozen. A **clearing** enable would give a full, predictable period every
time, at the cost of never being able to pause anything.

In `fsm_led` the visible consequence is that the first LED toggle after re-entering `STATE_BLINK`
can come almost immediately, so the first blink interval is short.
*(1 mark)*

**Holding `enable` high permanently.** Neither better nor worse for correctness, and it does not fix
the short first interval: entering `STATE_BLINK` would still catch a free-running timer at an
arbitrary point in its period. What it does buy is a blink phase that is independent of the state
machine entirely; what it costs is a 26-bit counter switching continuously when nothing is reading
it, which is power spent on nothing. The freezing enable is the more useful default because a design
that wants free-running behaviour can always tie `enable` high, while a design that wants to pause
cannot un-clear a clearing timer.
*(1 mark)*

### (c) 3 marks

```vhdl
library ieee;
use ieee.std_logic_1164.all;

architecture behaviour of blinker is
signal reset_s2_n, timeout: std_logic;
signal enable_always      : std_logic;
signal led_s              : std_logic;
begin
    led           <= led_s;
    enable_always <= '1';

    -- This is a top level: it owns the pin, so it synchronizes the reset itself.
    reset_sync1: entity work.reset_sync
        port map(clock, reset_n, reset_s2_n);

    timer1: entity work.timer
        generic map(TICK_COUNT)
        port map(clock, reset_s2_n, enable_always, timeout);

    -- The timeout pulse is an enable on a flip-flop running on the system clock,
    -- never a clock of its own.
    LED_PROCESS: process(clock, reset_s2_n) is
    begin
        if (reset_s2_n = '0') then
            led_s <= '0';
        elsif (rising_edge(clock)) then
            if (timeout = '1') then
                led_s <= not led_s;
            end if;
        end if;
    end process;
end architecture;
```

*(3 marks: 1 for `reset_sync` instantiated and its `reset_s2_n` carried to the timer, 1 for `timer`
with the generic passed through and `enable` tied high, 1 for the toggle process using `timeout` as
an enable rather than as a clock)*

Tying the literal `'1'` directly in the `port map` is accepted by GHDL and Quartus and loses
nothing; the named signal is the form that is unambiguously legal in every tool.

`led_s` exists because an output port cannot be read back, and this process reads its own output.

### (d) 2 marks

**Why the synchronizer.** The button is **asynchronous** to the 50 MHz clock: a human decides when
it changes, with no relationship to the clock edge, so it can change inside the setup/hold window of
the flip-flop sampling it and drive that flip-flop metastable. That the button has nothing to do
with counting is beside the point - the rule is about where the signal comes from, not what it
controls.
*(1 mark)*

**What the design would do without one.** Two things, and the second is the one that matters. The
visible symptom is **bounce**: the raw contacts make and break several times over the first
millisecond, which at 20 ns per cycle is many thousands of clock cycles, so the enable would flicker
on and off many times per press and the timer would start, stop and restart. The real fault is
**metastability**: the enable feeds a 26-bit counter and everything downstream of it, and an
unresolved value reaching several destinations can be read as `0` by some and `1` by others in the
same cycle, so parts of the design disagree about whether the timer is running.
*(1 mark)*

---

## Question 8 - The output that arrives a cycle early (13 marks)

### (a) 5 marks

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity seq_detect_01_mealy is
    port(clock, reset_n: in  std_logic;
         din           : in  std_logic;
         y             : out std_logic);
end entity;

architecture behaviour of seq_detect_01_mealy is
-- STATE_HIGH: the previous bit was '1'. Also the reset state, since the line idles high.
-- STATE_LOW : the previous bit was '0'.
type state_t is (STATE_HIGH, STATE_LOW);

signal reset_s2_n: std_logic;
signal state     : state_t;
begin
    -- Top level: it owns the reset pin. din is synchronous serial data and is NOT
    -- synchronized, exactly as in seq_detect_mealy.
    reset_sync1: entity work.reset_sync
        port map(clock, reset_n, reset_s2_n);

    STATE_PROCESS: process(clock, reset_s2_n) is
    begin
        if (reset_s2_n = '0') then
            state <= STATE_HIGH;
        elsif (rising_edge(clock)) then
            case (state) is
                when STATE_HIGH =>
                    if (din = '0') then
                        state <= STATE_LOW;
                    else
                        state <= STATE_HIGH;
                    end if;
                when STATE_LOW =>
                    if (din = '1') then
                        state <= STATE_HIGH;
                    else
                        state <= STATE_LOW;
                    end if;
                when others =>
                    state <= STATE_HIGH;
            end case;
        end if;
    end process;

    -- Mealy output: the current state AND the current input, combinational,
    -- outside any clocked process.
    y <= '1' when (state = STATE_LOW and din = '1') else '0';
end architecture;
```

*(3 marks: 1 for a two-value enumerated `state_t` with a `case` transition process and an
asynchronous reset, 1 for the transitions, 1 for the output as a **concurrent** conditional
assignment reading both `state` and `din`)*

**What the states mean.** `STATE_HIGH` is "the previous bit was `1`", `STATE_LOW` is "the previous
bit was `0`". That is the entire history a rising-edge detector needs, which is why two states are
enough. Either reset state is defensible provided the candidate says which they chose and why;
`STATE_HIGH` suits a line that idles high, and means a first `1` after reset is not reported as an
edge.

**The line that makes it Mealy.**

```vhdl
y <= '1' when (state = STATE_LOW and din = '1') else '0';
```

It reads `din`. Move that condition inside the clocked process, or drop `din` from it, and the
machine becomes Moore. Note also that it must have an `else`: leave one out and you have described a
signal that keeps its old value when no condition holds, which is a latch.
*(1 mark)*

**What `when others` buys.** In behaviour, nothing: every value of `state_t` is already named above
it, so the branch is unreachable in the source and synthesis normally optimizes it away rather than
building recovery logic. What it buys is that the `case` stays exhaustive if a state is added later
and a branch is forgotten - a maintenance property, checked at analysis time.

What it is **not** is a safety net against a corrupted state register. Once Quartus re-encodes the
machine, most bit patterns are illegal, and recovering from one needs Quartus's Safe State Machine
setting rather than anything you can write in VHDL.
*(1 mark)*

### (b) 2 marks

**Why one more state.** A Moore output may not read `din`, so "a rising edge just happened" has to
be recorded in the state itself before the output can report it. That means a third state, entered
on the `0` to `1` transition, existing purely to hold the output high for one cycle - exactly the
`M_TWO` of the course's own Moore-versus-Mealy comparison.

**What its output does differently.** It arrives **one clock cycle later**, and it comes off a
register rather than out of a gate, so it cannot follow a noisy input and, if the output is
registered, cannot glitch.
*(1 mark)*

**Which to reach for: Moore, by default.** Its output depends on no primary input, so it cannot
follow one; a Mealy output can in principle glitch combinationally if its inputs are not already
clean; and a machine whose output depends on fewer things is a machine with fewer ways to be wrong.
It is what the rest of this course and the follow-on CAN course use. Reach for Mealy only when you
specifically need the lower latency or the smaller state count, and know you are trading a
synchronous output for a combinational one when you do.
*(1 mark)*

Credit an answer that adds that "Moore" alone does not mean glitch-free: an output decoded
combinationally from several state bits can still glitch while they skew, and what makes an output
glitch-free is registering it.

### (c) 4 marks

**Cycles per bit and per tick.**

```text
one bit period  = 50,000,000 / 9600 = 5208.33 clock cycles
one sixteenth   = 5208.33 / 16      =  325.52 clock cycles
```

*(1 mark)*

**The two candidates.** The timer pulses every `TICK_COUNT + 1` cycles, so the target is
`TICK_COUNT + 1 = 325.52`, that is `TICK_COUNT = 324.52`, which is not a whole number:

| `TICK_COUNT` | Cycles per tick | Error against 325.52 |
|---|---|---|
| 324 | 325 | 0.52 cycles short, **-0.16%** |
| **325** | **326** | 0.48 cycles long, **+0.15%** |

The default is **325**, and the reason is simply that 326 is the closer of the two: `|326 - 325.52|`
is `0.48` against `|325 - 325.52|` = `0.52`. Both would work; neither is exact, because 9600 baud
does not divide 50 MHz.
*(1 mark)*

**Why sample mid-bit.** The transmitter runs off a different physical crystal, so the two clocks
drift apart across a frame, and the receiver's idea of where a bit starts came from one falling edge
it inferred rather than from a clock line it was given. Sampling at the middle leaves half a bit of
margin on **each** side; sampling near a boundary reads the neighbouring bit as soon as the two
drift at all, or as soon as the line's own edges are anything but instantaneous. What is being
tolerated is frequency error between the two crystals, plus the fraction of a tick of phase error
left over by never stopping the timer.
*(1 mark)*

**The drift.** Ten bit periods is 160 oversample ticks. The receiver's 160 ticks take
`160 * 326 = 52,160` clock cycles; ten true bit periods are `10 * 5208.33 = 52,083` cycles. The
difference is about `77` cycles, which is `77 / 325.52 = 0.24` of an oversample tick.

The margin it started with is **8 ticks**, half a bit period. So the sample point has drifted about
**3% of its margin** by the stop bit, which is why the answer is comfortable and why resynchronizing
on every start bit is enough: the error never gets ten bit periods to accumulate over more than
once.
*(1 mark)*

### (d) 2 marks

**During the break**, a level test re-arms the instant the previous frame's stop bit is judged. The
line is low, so the receiver reads it as a start bit immediately and marches through back-to-back
all-zero frames for as long as the break lasts. Each of those ends on a low stop bit and is
correctly rejected as a framing error, and **that part is fine**: nothing is handed over.
*(1 mark)*

**At the moment the break ends**, one frame is already in flight, and its stop bit is sampled after
the line has returned high. So it is a perfectly well-formed frame as far as the receiver can tell:
correct framing, high stop bit, and a byte made of nothing handed over as real data.

That last frame is the one that matters because it is the only one that **passes**. Every other
frame during the break is rejected, so a design that gets this wrong looks correct right up to the
moment a cable is unplugged and plugged back in, and then delivers one plausible byte that was never
sent.

The **edge** test does not re-arm during the break at all: after the first falling edge there is not
another one until the line has recovered. It costs one flip-flop of history, and that is the whole
difference.
*(1 mark)*

---
