# Appendix A - Sequential Logic

## A.1 From combinational to sequential logic
Every circuit in L01 and L02 was **combinational**: its output is a pure function of its present
inputs, so the same inputs always give the same output, and there is no notion of "before" or
"after" inside the circuit.

Most useful systems need more. A counter must remember its count. A register must hold a value after
the signal that produced it has changed. An LED toggled by a button must remember whether it is on,
since that is not encoded in the button's momentary state at all.

All of these need **memory**: an output that depends on the circuit's own *previous* output.
Sequential logic is combinational logic with part of the output fed back into the input, and that
**feedback loop** is what turns a stateless gate network into a circuit with state. This lecture
builds the primitive that makes controlled feedback practical, the D flip-flop, then the two things
you build directly out of it: registers and edge detectors.

---

## A.2 The D latch
The simplest storage element is the **D latch**: two cross-coupled gates, gated by an `enable`
input, storing a single bit.

```text
        ┌────────────┐
   D ──►│            │──► Q
        │  D LATCH   │
enable─►│            │──► Qn
        └────────────┘
```

`D` is the value to store, `enable` controls whether the latch is *open* (transparent) or *closed*
(holding), `Q` is the stored value and `Qn` is always its inverse.

Each output feeds back into the other's equation, which is exactly A.1's feedback loop:

```math
Q = (D' \cdot enable + Qn)'
```

```math
Qn = (D \cdot enable + Q)'
```

| `enable` | Behaviour | Result |
|---|---|---|
| `1` | latch is **open** (transparent) | `Q = D`, `Qn = D'`; output follows the input immediately |
| `0` | latch is **closed** (locked) | `Q` and `Qn` hold whatever they last had |

**Build it in CircuitVerse** from one NOT gate, two AND gates and two NOR gates (a NOR is an OR
followed by a NOT). Cross-couple the feedback so the NOR producing `Q` feeds the NOR on the `Qn`
side and vice versa. Drive `D` and `enable` from input switches and watch `Q` and `Qn` on LEDs.

Then test it:
* With `enable = 1`, change `D` and confirm `Q` follows immediately. The latch is **transparent**.
* With `enable = 0`, confirm `Q` is unchanged whatever `D` does. The latch is **locked**.
* Cycle `D` a few times while toggling `enable`, and confirm the latch always freezes whatever `Q`
  held at the instant `enable` fell. That is what **level-sensitive** means: transparent for the
  entire time `enable` is high, not just at one instant.

That last point is also the latch's fundamental weakness. Because it is transparent for the whole
time `enable = 1`, any glitch on `D` during that window passes straight through to `Q`. In a large
synchronous system, guaranteeing stable data throughout an entire clock phase is far harder than
guaranteeing it around a single instant. That is the problem the D flip-flop solves.

---

## A.3 The D flip-flop
A **D flip-flop** stores a bit the same way a latch does, but is **edge-triggered** rather than
level-sensitive: it samples `D` only at the *instant* the clock transitions, not for the whole time
the clock is high or low.

Feed the same `D` and the same clock to both and the difference is immediate:

![Timing diagram: a latch follows D throughout every clock-high window, while a flip-flop changes only on the rising edges](./images/latch_vs_flipflop.png)

The latch changes three times: twice because `D` moved while the clock was high, and once because
the clock went high onto a `D` that had already changed. The flip-flop changes once, because only
one of the four rising edges found `D` different from the value `Q` was already holding. Both are
behaving correctly; they are answering different questions.

```text
        ┌───────────────┐
   D ──►│               │──► Q
clock ─►│  D FLIP-FLOP  │
enable─►│ (rising-edge) │──► Qn
reset_n►│               │
        └───────────────┘
```

`clock` is the timing reference (A.4). `enable` gates whether the flip-flop accepts a new value *at
the triggering edge*. `reset_n` is an asynchronous, active-low reset: whenever it is `0`, `Q` is
forced to `0` immediately, regardless of the clock.

| Condition | Result |
|---|---|
| `reset_n = 0` | `Q = 0`, `Qn = 1`, immediately (asynchronous, ignores the clock entirely) |
| `reset_n = 1`, rising edge on `clock`, `enable = 1` | `Q = D`, `Qn = D'`, sampled at that instant |
| `reset_n = 1`, rising edge on `clock`, `enable = 0` | `Q` holds its previous value |
| `reset_n = 1`, no rising edge on `clock` | `Q` holds its previous value, no matter what `D` does |

That last row is worth seeing rather than reading:

![Timing diagram: D rises mid-cycle and is captured at the next rising edge, then dips and recovers entirely between two edges without Q ever moving](./images/dff_timing.png)

`D` dips low and comes back inside a single clock period, and `Q` never moves, because no edge
happened while it was low. A latch in the same position would have followed it down and back up.

Internally, an edge-triggered flip-flop is two D latches in series, a **master-slave** pair. One is
transparent while the clock is low and captures `D`; the other is transparent while the clock is
high and passes the captured value to `Q`. The net effect is that `Q` changes only at the instant
the clock goes low to high, never while it sits at either level. That external behaviour is what
VHDL's `rising_edge()` models (A.6).

**Build it in CircuitVerse** by extending your A.2 latch:
* Duplicate the latch so two sit in series: the *master* feeds the *slave*, whose `Q` is the
  flip-flop's output.
* Add `clock`, `reset_n`, `D` and `enable` as inputs.
* Drive the two latches' transparency from the clock and its inverse. To keep the two meanings
  apart, call that internal per-latch control `gate`: the master's `gate` is `clock'` and the
  slave's is `clock`. The flip-flop's external `enable` is a different signal and is wired
  separately, below.
* Wire the external `enable` as a 2-to-1 mux (L02 A.4) on the master's data input: when
  `enable = 1` the mux passes `D`, and when `enable = 0` it passes the flip-flop's own `Q` back in,
  so the edge re-captures the value already stored. Gate the *data*, never the clock.
* Add the reset to **both** latches. Forcing `Q` low takes two changes in each latch, not one:
  * feed an active-high `reset` (`reset_n` through a NOT) into the NOR producing `Q`, forcing `Q`
    to `0`.
  * AND `reset_n` into that same latch's `D AND gate` term, which frees `Qn` to go high.
* Set the clock period to something slow enough to watch, e.g. `1000 ms`.

With the reset wired in, each latch's equations become:

```math
Q = (D' \cdot gate + Qn + reset)'
```

```math
Qn = (D \cdot gate \cdot reset\_n + Q)'
```

A tempting shortcut is to leave the `Qn` equation alone and break the loop instead, ANDing
`reset_n` onto the `Qn` wire feeding `Q`'s NOR. That is not enough. With `gate = 1` and `D = 1` it
leaves `Qn` at `0`, which is what holds `Q` at `1`, so the reset silently does nothing in exactly
the case you are most likely to test it in. Both changes, in both latches, or neither.

Confirm that `Q` updates only at the instant the clock rises, holding steady between edges even if
`D` changes, and that pulling `reset_n` low forces `Q` to `0` immediately, with releasing it
changing nothing until the next rising edge.

---

## A.4 Clocking
The **clock** is a periodic square wave, read by every flip-flop in a synchronous circuit from the
same source. Two numbers describe it: the **period** `T`, the time for one full cycle, and the
**frequency** `f = 1/T` in Hz.

Each period has exactly two **edges**: a **rising edge** from `0` to `1`, and a **falling edge**
from `1` to `0`. A synchronous design picks one of them, almost always the rising edge, and updates
every flip-flop on that edge and only that edge. Using a single edge everywhere is what makes a
large circuit's timing analyzable: every flip-flop changes at the same well-defined instants, so you
can reason one clock cycle at a time rather than tracking every signal continuously.

Simulated and real clocks run on wildly different timescales, and the logic is identical either way:
* In CircuitVerse, set a period you can watch, e.g. `1000 ms`.
* On the DE0-CV the system clock is a fixed `50 MHz`, a period of `20 ns`. Nobody perceives
  individual edges at that rate, so you reason in terms of "on the next rising edge", never in
  wall-clock time.

---

## A.5 Registers: flip-flops in parallel
A **register** stores more than one bit: N D flip-flops side by side, one per bit, all sharing the
same `clock`, `reset_n` and `enable`.

```text
D(0) ──►[D FF]──► Q(0)
D(1) ──►[D FF]──► Q(1)
D(2) ──►[D FF]──► Q(2)
   ⋮        ⋮
D(N-1)──►[D FF]──► Q(N-1)

  (clock, reset_n, enable shared by every flip-flop above)
```

That is the entire idea: an 8-bit register is eight D flip-flops updating on the same clock edge.

In VHDL you rarely instantiate N flip-flops explicitly. Declare one `std_logic_vector` and assign
the whole thing inside a single synchronous process (A.6): every bit synthesizes to its own
flip-flop, all sharing the process's clock and reset.

```vhdl
signal q: std_logic_vector(3 downto 0);
...
process (clock, reset_n) is
begin
    if (reset_n = '0') then
        q <= "0000";
    elsif (rising_edge(clock)) then
        if (enable = '1') then
            q <= d; -- d is a std_logic_vector(3 downto 0) input
        end if;
    end if;
end process;
```

Four bits, one process, four flip-flops in hardware: no different in principle from four
`d_flip_flop` instances wired in parallel.

---

## A.6 The synchronous process template in VHDL
Every synchronous element in this lecture, the flip-flop, the register and the edge detector, uses
the same shape. Without a reset, a single D flip-flop is:

```vhdl
process (clock) is
begin
    if (rising_edge(clock)) then
        q <= d;
    end if;
end process;
```

`q` takes `d`'s value at every rising edge and holds it the rest of the time. That one line inside
the `if` is enough for synthesis to infer a real D flip-flop.

### Rules
* **`clock` is the only signal in the sensitivity list**, unless there is an asynchronous reset. The
  process should run only when the clock changes; it has no reason to react to anything else.
* A process reacts to *any* change on a sensitivity-list signal, not just rising ones, so
  `rising_edge()` filters for the rising edge specifically. All logic that updates synchronously
  goes inside that `if`.
* Every signal assigned inside such a process synthesizes to a flip-flop, one bit each.

### With an asynchronous reset
An asynchronous reset must also appear in the sensitivity list, since it can be asserted
independently of the clock, and it takes priority when active.

```vhdl
process (clock, reset_n) is
begin
    if (reset_n = '0') then
        q <= '0';
    elsif (rising_edge(clock)) then
        q <= d;
    end if;
end process;
```

Read it in priority order: check the reset first, and only if it is inactive check for a rising
edge. If neither holds (a falling edge, or `reset_n` going from `0` back to `1`, which also
re-triggers the process), nothing is assigned and `q` keeps its previous value.

### When the assignment actually happens
One rule sits underneath all of the above, and it is the single place where `<=` behaves unlike
assignment in any language you have written software in.

A signal assignment does not take effect when its line runs. It **schedules** a value, applied only
once the process finishes this pass and suspends. Until then, every read of that signal returns the
value it held *before the pass started*, however many assignments have already executed.

That sounds like a technicality. It is the reason the template above is a flip-flop rather than a
wire:

```vhdl
process (clock) is
begin
    if (rising_edge(clock)) then
        b <= a;
        c <= b;
    end if;
end process;
```

Read as software, `b` and `c` both end up holding `a`. In hardware they do not. On each edge `b` is
scheduled to take `a`'s value, and `c` is scheduled to take the value `b` held *coming into this
edge*, not the one just scheduled onto it. The result is two flip-flops in a chain: `a` reaches `b`
after one edge and `c` after two. Swap the lines and nothing changes, because neither assignment can
observe the other's result.

Two consequences worth carrying forward:
* **Order does not matter** between assignments to *different* signals in the same clocked process.
  They all read the old values and all take effect together. That is the opposite of the sequential
  reading the word "process" invites, and it is why a chain of flip-flops can be written in any
  order.
* **Assign the same signal twice in one pass and only the last assignment survives.** The earlier
  ones are discarded without ever reaching the signal.

A.7's edge detector is exactly the two-element chain above, and works for exactly this reason. L05
returns to this rule from the other side, with a `variable`, which updates immediately and so
behaves the way the software reading expects.

---

## A.7 Edge detection
A flip-flop's other everyday job is detecting the *instant* a signal changes rather than reading its
level: store the signal's previous value in a flip-flop, then compare it against the current value
with a gate.

* **Rising-edge detection** (`0` to `1`):
  ```math
  edge = current \cdot previous'
  ```
* **Falling-edge detection** (`1` to `0`):
  ```math
  edge = current' \cdot previous
  ```

```text
signal ──┬───────────────────────────► AND ──► edge
         │                              ▲
         └──►[D FF]── previous ──(NOT)──┘
                ▲
           clock, reset_n
```

`edge` is high for exactly one clock cycle, the one immediately after the transition, because
`previous` only catches up on the *next* edge. This is the mechanism behind "do something once per
button press" rather than "do something every clock cycle the button is held", which is exactly what
A.9 solves.

---

## A.8 Worked example: a D flip-flop in VHDL
[`d_flip_flop.vhd`](../d_flip_flop/d_flip_flop.vhd) implements A.3 and A.6 combined: an enable
gating whether a rising edge captures `d`, and an asynchronous active-low reset.

```vhdl
entity d_flip_flop is
    port(clock, reset_n, d, enable: in std_logic;
         q, q_n                   : out std_logic);
end entity;
```

Its single process is the reset-plus-enable variant of A.6's template: reset takes priority, then a
rising edge captures `d` into an internal signal `q_s` if `enable = '1'`. `q_s` exists because an
*output* port cannot be read back inside the same architecture; `q` and `q_n` are both driven
combinationally from it, outside the process.

To try it on hardware, assign `clock` to the `50 MHz` system clock, `reset_n` to a pushbutton, `d`
and `enable` to two slide switches, and `q`/`q_n` to two LEDs. Then flip `enable` on and change `d`,
and the LED follows; flip `enable` off and change `d`, and it does not.

There is no clock edge you can perceive at `50 MHz`, so what you are really confirming is that the
logic still holds once you can no longer see the individual edges. The flip-flop looks like it
responds to your switch; in fact it responded to one of fifty million clock edges that second, and
the switch only decided which value that edge captured.

---

## A.9 Worked example: edge-detected LED toggle
[`led_toggle.vhd`](../led_toggle/led_toggle.vhd) combines A.5, A.6 and A.7 into one small system:
two independent push buttons, each toggling its own LED exactly once per press.

```vhdl
entity led_toggle is
    port(clock, reset_n: in std_logic;
         button_n      : in std_logic_vector(1 downto 0);
         led           : out std_logic_vector(1 downto 0));
end entity;
```

Three 2-bit signals, two held in clocked processes and one computed between them:
* `button_prev_n` is a 2-bit register (A.5) holding last cycle's `button_n`, reset to `"11"` since
  the buttons are active-low.
* `button_edge <= (not button_n) and button_prev_n` is A.7's falling-edge detector applied to both
  bits at once, high for one cycle exactly when a button goes from released to pressed.
* `led_s` is a second 2-bit register which, instead of capturing a new value each cycle, **toggles**
  bit `i` only when `button_edge(i) = '1'`. Without that gating it would toggle every clock cycle
  instead of once per press, which is the whole point of computing `button_edge`.

**On the board**, demonstrated during the lecture: create the Quartus Prime Lite project targeting
the DE0-CV's `5CEBA4F23C7N` exactly as in L01, then assign `clock` to the `50 MHz` oscillator,
`reset_n` and `button_n(1 downto 0)` to three push buttons, and `led(1 downto 0)` to two LEDs.
Each press should toggle exactly one LED, once, no matter how long you hold it.

**A caveat, deliberately left open:** `button_n` is a raw signal straight off a physical pushbutton
pin. In simulation that is a clean, instantaneous transition; on real hardware it is neither
instantaneous (contacts bounce) nor synchronized to `clock`. This edge detector is logically correct
but *unsafe* to wire directly to a real button on an FPGA without more work first, and that work is
exactly what L04 covers.

---
