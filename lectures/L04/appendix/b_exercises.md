# Appendix B - Exercises

> **How to check your work.** Every exercise below that asks you to write a VHDL module ships a
> self-checking testbench under [`exercises/`](../exercises). Write your module in its
> `exercises/<module>/` directory, using the entity name and the **port order** the exercise
> specifies, then run it with GHDL - see [Appendix C](../../L02/appendix/c_testbenches.md) for the
> three commands.
>
> No FPGA board is needed for any exercise. The Quartus synthesis and board-programming steps are
> demonstrated during the lecture; your job afterwards is to get the VHDL right, and the testbench
> is how you confirm it.

## Metastability Concepts
**1.** Explain metastability in your own words.
In your explanation, describe:
* What happens inside a D flip-flop when its input changes too close to the active clock edge.
* Why the flip-flop output may temporarily remain between a valid logic `0` and logic `1`.
* Why the output may take an unpredictable amount of time to settle.
* Why two downstream gates may interpret the unresolved output differently:
  * One gate may interpret it as `0`.
  * Another gate may interpret it as `1`.

Explain why this disagreement can cause different parts of a digital circuit to enter inconsistent
states.

---

**2.** Setup time and hold time define a window around the active clock edge during which the
input of a flip-flop must remain stable.

Explain:
* Why a synchronously generated signal can normally be designed to satisfy these timing
  requirements.
* Why an asynchronous input, such as a mechanical pushbutton, has no fixed relationship to the
  system clock.
* Why an asynchronous input may therefore change during the setup-and-hold window regardless of
  how the surrounding synchronous logic is designed.

Conclude why the metastability risk from an asynchronous input must be managed rather than simply
avoided.

---

## Synchronizer Design
**3.** Draw a double-flop synchronizer for one asynchronous input.

The circuit must contain:
* One asynchronous input.
* Two D flip-flops connected in series.
* A shared system clock.
* A synchronized output taken from the second flip-flop.

Explain in your own words:
* Why the first flip-flop is exposed directly to the asynchronous input.
* Why the first flip-flop may become metastable.
* How the interval between the first and second clock edges gives the first stage time to settle.
* Why the output of the second flip-flop has a much lower probability of being metastable.
* Why the second stage, rather than the first, should be used by the rest of the design.

A synchronizer does not make the probability of metastability exactly zero.
Explain why it nevertheless reduces the risk to an acceptably low level in most designs.

**Tip:** Consider how much resolution time the first flip-flop receives before its value is
sampled by the second flip-flop.

---

**4.** A colleague suggests using three synchronizer flip-flops on every asynchronous input in a
low-speed design clocked at a few megahertz, just to be safe.

A third stage buys one more clock period for a metastable value to settle, and costs one more clock
cycle of latency on every synchronized input. At a few megahertz that extra clock period is an
enormous amount of time in metastability terms, which is exactly why the proposal sounds prudent,
and also why it may already be unnecessary.

**a)** Work the trade out in both directions. Under what circumstances does it come out in favour
of the third stage, and under what circumstances is the second stage already enough? Your answer
has to turn on something other than the clock frequency, because frequency alone does not settle
it: name what it does turn on.

**b)** A.4 got to MTBF from the resolution time available per stage. Without redoing that
arithmetic, say which way each of these pushes the decision, and why:
* How often the asynchronous input actually changes.
* The metastability characteristics of the FPGA family you are targeting.
* What a synchronization failure would cost if one happened.

**c)** Give your recommendation for an ordinary low-speed design like the ones in this course.
Then describe a design, real or imagined, where you would argue for the third stage instead, and
say which of the factors in **b)** is doing the work in that case.

> **Check your answer covers** the two things a third stage provides, an additional clock period of
> resolution time and a lower probability that an unresolved value reaches the functional logic,
> and the two it costs, an additional cycle of latency and additional flip-flops. If your answer to
> **a)** rests on the clock rate rather than on the required mean time between failures, read A.4
> again before moving on.

---

**5.** Explain the **assert asynchronously, release synchronously** reset pattern used in
`reset_sync.vhd`.

See [Appendix A.5](./a_metastability_and_synchronization.md#a5-synchronizing-a-reset-signal-assert-async-release-sync).

Describe the two parts separately:
* Asynchronous assertion:
  * The reset takes effect immediately.
  * It does not wait for a clock edge.
* Synchronous release:
  * The reset is removed only on an active clock edge.
  * All affected logic leaves reset in a controlled relationship with the clock.

Explain:
* Why immediate reset assertion can be important when:
  * The clock is stopped.
  * The clock is unstable.
  * The system must enter its reset state without delay.
* Why releasing an asynchronous reset close to a clock edge can violate the recovery or removal
  timing requirements of a flip-flop.
* Why synchronizing the release prevents different flip-flops from leaving reset on different
  clock cycles.

---

## Building the Circuit
**6.** Build the `led_toggle_sync` circuit from
[Appendix A.9](./a_metastability_and_synchronization.md#a9-worked-example-led_toggle_sync)
by hand in CircuitVerse.

**a)** Add the external ports:
* Inputs:
  * `clock`
  * `reset_n`
    * Asynchronous.
    * Active-low.
  * `button_n`
    * Active-low.
* Output:
  * `led`

**b)** Build the two-flip-flop reset synchronizer:
* Connect the two flip-flops in series.
* Assert both stages asynchronously using the raw `reset_n` input.
* Allow the reset to propagate out of the chain synchronously.
* Use the synchronized reset output, `reset_s2_n`, throughout the rest of the circuit.
* Do not use the raw `reset_n` input directly outside the reset synchronizer.

**c)** Build the three-flip-flop button synchronizer and edge detector:
* Use the first two flip-flops as the double-flop synchronizer.
* Use the third flip-flop to store the previous synchronized button value.
* Compare the current and previous synchronized values.
* Detect a button press when:
  * The current synchronized active-low button value is `0`.
  * The previous synchronized value is `1`.
* Use an AND gate with the current value inverted to generate `button_edge_s2`.

The falling-edge relationship for the active-low button is:

```math
button\_edge\_s2 = previous \cdot current'
```

**d)** Build the LED toggle logic:
* Add a flip-flop to store `led_s`.
* Reset `led_s` using `reset_s2_n`.
* Toggle `led_s` only when `button_edge_s2 = 1`.
* Connect the `led` output to `led_s`.

**e)** Simulate the complete design:
* Set the clock period to `1000 ms`.
* Assert and release `reset_n`.
* Press and release `button_n`.
* Observe the synchronized button stages.
* Observe `button_edge_s2`.
* Observe `led_s`.

Determine:
* Whether the LED toggles on the first clock edge after the physical button press.
* How many clock cycles are required for the button value to propagate through the synchronizer
  and edge detector.
* Whether the observed latency matches the behaviour predicted in Appendix A.

---

## Debouncing and Timing
**7.** You have now built and watched the circuit, so this is a question about what you saw.

The three-flip-flop chain in exercise 6 does three jobs at once:
* Reduces the risk of metastability.
* Stores the previous synchronized button value.
* Detects a button press.

Explain why it does **not**, by itself, guarantee that the button is debounced.

**a)** Distinguish the three things it is easy to run together:
* Synchronization:
  * Converts an asynchronous input into a signal suitable for use in the clock domain.
* Edge detection:
  * Generates a pulse when the sampled signal changes.
* Debouncing:
  * Prevents several physical transitions from being interpreted as several separate presses.

Which two of these does your circuit actually do?

**b)** In your simulation, one press produced one clean toggle. That is a stronger claim than it
looks: it holds only under a particular condition about where the bouncing fell relative to the
clock edges. State that condition precisely, in terms of what your circuit sampled and what it
therefore saw.

Then explain why that condition is an accident of your clock period rather than a property of your
circuit. Be specific about which of the two, the bounce or the sampling, your design actually
controls.

**c)** Your simulation ran at a `1000 ms` clock period; the FPGA runs at `50 MHz`. A push button's
contacts typically bounce for something on the order of 1 ms. Work out the consequences yourself:
* How many times does a `1000 ms` clock sample the button during that 1 ms of bouncing?
* How many times does a `50 MHz` clock sample it?
* Each sampled transition looks like a fresh edge to your edge detector. Given those two numbers,
  predict what the LED does on the board for one physical press, and say why the identical circuit
  behaved impeccably in CircuitVerse.

**d)** Describe one fix of each kind:
* A hardware fix:
  * for example, an RC low-pass filter followed by a Schmitt-trigger input.
* A purely digital fix:
  * for example, requiring the synchronized signal to hold a new level for some minimum number of
    clock cycles before accepting it.
  * or a counter that ignores further transitions for a fixed interval after a press - which is
    what [L07](../../L07/README.md)'s timer would give you.

**e)** Explain why the double-flop synchronizer must still be kept even once a debounce method is
added. What problem does debouncing not solve?

---

## The Synchronizers as Modules of Their Own
The worked example puts each synchronizer in a module of its own, so every later design
instantiates the same two files instead of re-deriving them. That is why L07's `walking_led` and
L08's `fsm_led` both ask you to copy these two in, and why L08's `seq_detect_mealy`, which has no
button, takes the reset synchronizer alone and leaves the other behind
([Appendix A.9](./a_metastability_and_synchronization.md#a9-worked-example-led_toggle_sync)).

The next two exercises are you writing those modules. Appendix A.5 and A.6 give you the logic; what
they do not give you is the entity around it, and, for the second one, the step from a single button
to a vector of them. Write each module yourself before opening the worked example's copy, then
compare. Exercise 10 then composes both of them into a working design.

---

**8.** Write the reset synchronizer as a module named `reset_sync`.

The entity has:

| Port | Direction | Type | Description |
|---|---|---|---|
| `clock` | in | `std_logic` | 50 MHz system clock. |
| `reset_n` | in | `std_logic` | Active-low asynchronous reset, straight from the outside world. |
| `reset_s2_n` | out | `std_logic` | Active-low synchronized reset, safe for the rest of the design to use. Goes low the instant `reset_n` does, with no clock edge involved, and returns high two rising edges after `reset_n` does. |

**a)** Implement **assert asynchronously, release synchronously**
([Appendix A.5](./a_metastability_and_synchronization.md#a5-synchronizing-a-reset-signal-assert-async-release-sync)):
* One internal signal for the first stage, plus the output for the second.
* One process, sensitive to both `clock` and `reset_n`.
* On `reset_n = '0'`, drive both stages low, outside the clocked branch.
* On a rising clock edge, shift a constant `'1'` in through the two stages.

**b)** The value forced on reset and the value shifted in on the clock are opposites, `'0'` and
`'1'`. Explain in one sentence why that is not a contradiction, in terms of what each branch is
for.

**c)** Verify the design with its testbench (see the note at the top of this appendix). It checks
both halves of the pattern separately: that pulling `reset_n` low takes `reset_s2_n` low with no
clock edge in between, and that releasing `reset_n` leaves `reset_s2_n` low until two rising edges
have passed.

**d)** Answer, in prose:
* The output is named `reset_s2_n` rather than `reset_n_sync`. What does `s2` say, and what would
  have to change about this module for that name to become wrong?
* Every other module in this course takes `reset_s2_n` as its reset. This one takes the raw
  `reset_n`. Why must exactly one module in a design be the exception?

**Tip:** the release is the interesting half. On reset the process does not care about the clock at
all, so both stages go low together; on the clock it does not care about `reset_n`, so the `'1'`
takes one edge per stage to reach the output. Two edges of latency on release is the price of the
whole pattern.

![Module `reset_sync`](./images/reset_sync.png)

**Self-check:** name your entity `reset_sync`, with ports `clock`, `reset_n` (in) and `reset_s2_n`
(out), declared in that order; its testbench is in
[`exercises/reset_sync/`](../exercises/reset_sync).

---

**9.** Write the button synchronizer and edge detector as a module named `button_sync`.

Exercise 10 handles two buttons by writing a two-bit synchronizer. This one is the same circuit with
the width left open: one generic decides how many buttons it serves, so `led_toggle_sync` can use
it for one button and `fsm_led` for two without either file being edited. See
[Appendix A.8](./a_metastability_and_synchronization.md#a8-generics-one-module-several-sizes) for
the syntax and for why this module has a generic where `reset_sync` has none.

The entity has one generic:

| Generic | Type | Default | Description |
|---|---|---|---|
| `COUNT` | `natural range 1 to 3` | `1` | The number of buttons, and therefore the width of both vector ports. |

and these ports:

| Port | Direction | Type | Description |
|---|---|---|---|
| `clock` | in | `std_logic` | 50 MHz system clock. |
| `reset_s2_n` | in | `std_logic` | Active-low, **already synchronized** reset. This module does not synchronize its own reset; exercise 8's module did that. |
| `button_n` | in | `std_logic_vector(COUNT - 1 downto 0)` | Active-low asynchronous push buttons. |
| `button_edge_s2` | out | `std_logic_vector(COUNT - 1 downto 0)` | A one-cycle pulse on each button's falling edge, two clock edges after the press. Each bit is independent of every other. |

**a)** Build the three-stage chain from
[Appendix A.6](./a_metastability_and_synchronization.md#a6-reusing-the-chain-for-edge-detection---and-incidentally-debouncing),
now over vectors rather than single bits:
* Three internal `std_logic_vector(COUNT - 1 downto 0)` signals, one per stage.
* Stages 1 and 2 are the double-flop synchronizer; stage 3 stores the previous value of stage 2.
* On reset, set all three stages to `(others => '1')`, not `(others => '0')`.
* Derive the output with a single concurrent assignment, and note that the same expression works
  unchanged on vectors as on bits.

**Keep this one in mind.** Those first two flip-flops are the whole of a synchronizer and nothing
else, and [L05 exercise 4](../../L05/appendix/b_exercises.md) has you pull them back out as a
module of their own, generic in width and in the value they reset to. Writing them inline here
first is what makes that exercise a consolidation rather than a new idea.

**b)** Explain why the reset value is all-ones. All-ones means "released", because the buttons are active-low, so an all-zeros
reset starts the chain out claiming every button is already held down. Trace what that costs:
* With the buttons released and a reset to all-zeros, does the module emit a spurious pulse as the
  released state propagates through the three stages? Work it through the output expression edge by
  edge before you answer, rather than guessing.
* Now the case that actually breaks. A user is holding a button down at the moment the reset is
  released. What does the module report with an all-ones reset, and what does it report with
  all-zeros? Which of the two is the behaviour you want, and why?

**c)** Verify the design with its testbench. It instantiates your module **twice**, once at
`COUNT = 1` and once at `COUNT = 2`, and checks that a press produces exactly one single-cycle
pulse, that holding the button produces no further pulses, that a release produces none at all,
that pressing one button of a pair never pulses the other, and - the case part **b)** asks you to
reason about - that a button already held down when the reset releases produces exactly one pulse
with an all-ones reset and none at all with all-zeros.

**d)** Answer, in prose:
* `COUNT` is constrained to `1 to 3` rather than left an unbounded `natural`. What does the
  constraint buy, given that nothing in the architecture depends on the upper bound?
* This module is deliberately not merged with exercise 8's, even though a design that has a button
  always needs both. Give the design that justifies the split, and say what it would have had to do
  instead.

**Tip:** write the architecture for `COUNT = 1` in your head first, then check that every line you
wrote is already correct for a vector. `and`, `not` and the aggregate `(others => '1')` all work
element-wise, so the generalization should cost you no extra code at all. If it does, that is worth
a second look.

![Module `button_sync`](./images/button_sync.png)

**Self-check:** name your entity `button_sync`, with generic `COUNT` (`natural range 1 to 3`,
default `1`), inputs `clock`, `reset_s2_n`, `button_n` (`std_logic_vector(COUNT - 1 downto 0)`) and
output `button_edge_s2` (`std_logic_vector(COUNT - 1 downto 0)`), declared in that order; its
testbench is in [`exercises/button_sync/`](../exercises/button_sync).

---

## Composing Them Into a Design
**10.** Now make L03's `led_toggle` metastability-safe, in VHDL, as a new module named
`led_toggle_sync2`.

L03's `led_toggle` toggled two LEDs from two push buttons, but fed their raw, asynchronous signals
straight into the edge detector - logically correct, but unsafe on real hardware (L03's own "Next
lecture" section flagged exactly this). Here you rebuild it with every asynchronous input guarded by
this lecture's double-flop synchronizer.

The entity has:

| Port | Direction | Type | Description |
|---|---|---|---|
| `clock` | in | `std_logic` | 50 MHz system clock. |
| `reset_n` | in | `std_logic` | Active-low asynchronous reset. |
| `button_n` | in | `std_logic_vector(1 downto 0)` | Two active-low asynchronous push buttons. |
| `led` | out | `std_logic_vector(1 downto 0)` | Two LEDs; `led(i)` toggles once per press of `button_n(i)`. |

**a)** Synchronize every asynchronous input:
* Apply the two-flip-flop reset synchronizer from Appendix A.5 (assert asynchronously, release
  synchronously).
* Give the buttons a double-flop synchronizer plus a third stage for edge detection, as in
  Appendix A.6 - now over a `std_logic_vector(1 downto 0)`, so both buttons are synchronized in
  parallel.
* Never let the raw `reset_n` or `button_n` reach the toggle logic; use only the synchronized reset
  and the per-button edge pulses.

**Tip:** you can inline the synchronizer, or split it out into a subcomponent taking a two-bit
`button_n`, using the instantiation syntax from
[L02 A.6](../../L02/appendix/a_larger_networks.md#a6-building-a-design-from-submodules). Inlining
is the shorter route, and then the build is a single file:

```bash
ghdl -a --std=93 led_toggle_sync2.vhd led_toggle_sync2_tb.vhd
```

If you split it out instead, copy in the `reset_sync.vhd` and `button_sync.vhd` you
wrote for exercises 8 and 9 (instantiating `button_sync` at `COUNT = 2`), and name them first on
the `ghdl -a` line, ahead of your own module, so GHDL sees them before the file that instantiates
them:

```bash
ghdl -a --std=93 reset_sync.vhd button_sync.vhd \
                 led_toggle_sync2.vhd led_toggle_sync2_tb.vhd
```

See [Appendix C.5](../../L02/appendix/c_testbenches.md#c5-when-the-design-needs-more-than-one-file).
Neither module is shipped anywhere in the repo, because writing them is exercises 8 and 9. If yours
are not working yet, go back to
[A.5](./a_metastability_and_synchronization.md#a5-synchronizing-a-reset-signal-assert-async-release-sync),
which prints `reset_sync`'s process in full, and
[A.6](./a_metastability_and_synchronization.md#a6-reusing-the-chain-for-edge-detection---and-incidentally-debouncing),
which gives `button_sync`'s three-flop chain and its edge equation.

**b)** Build the toggle logic:
* One LED-state flip-flop per LED.
* On the synchronized reset, clear both LEDs.
* Toggle `led(i)` only when button `i`'s synchronized falling-edge pulse fires.
* Confirm `led(i)` responds to `button_n(i)` alone, never to the other button.

**c)** Verify the design with its testbench (see the note at the top of this appendix).

The testbench presses each button in turn and checks that:
* Reset clears both LEDs.
* No press means no toggle.
* Pressing button 0 toggles `led(0)` **only**, once the synchronizer latency has elapsed.
* Holding that button down does not toggle it again.
* Pressing button 1 then toggles `led(1)` only, leaving `led(0)` where it was.

Pay attention to the **latency**: the testbench checks the *exact* edge, not merely that the LED
settles eventually. A press must reach the toggle logic through two synchronizer flip-flops, so
`led` is still unchanged after the first and second rising edges and toggles on the third. Count
the flip-flops a press travels through and satisfy yourself that the third edge is the right one,
and that a defensive extra pipeline stage would now be caught rather than tolerated.

**d)** Answer, in prose, by comparing this design with your L03 `led_toggle`:
* What does the synchronizer change about pressing a real, bouncing button?
* Why was the raw L03 version unsafe to wire to a physical button at `50 MHz`?
* Your testbench drives clean, perfectly-timed transitions. Which of the two problems from this
  lecture, metastability or contact bounce, can a testbench therefore never demonstrate to you?

![Module `led_toggle_sync2`](./images/led_toggle_sync2.png)

**Self-check:** name your entity `led_toggle_sync2`, with inputs `clock`, `reset_n`, `button_n`
(`std_logic_vector(1 downto 0)`) and output `led` (`std_logic_vector(1 downto 0)`), declared in that
order; its testbench is
in [`exercises/led_toggle_sync2/`](../exercises/led_toggle_sync2). It presses each button in turn
and checks that `led(i)` toggles on `button_n(i)`'s falling edge, that it does so on the right clock
edge rather than merely settling to the right value eventually, and that it never fires the wrong LED - see [Appendix C](../../L02/appendix/c_testbenches.md).

---
