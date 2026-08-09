# Written Examinations

Two complete three-hour papers for **Digital Design with VHDL**, with worked solutions.

```text
paper_a.md              Paper A, questions only. Hand this out.
paper_a_solutions.md    Paper A, model answers with marks.
paper_b.md              Paper B, questions only.
paper_b_solutions.md    Paper B, model answers with marks.
```

---

## What these are for

The course as written has **no exam and nothing is marked**. Assessment is the exercises after every
lecture, the self-checking testbench nearly every one of them ships, and the circuit you predict and
then simulate by hand in CircuitVerse before any VHDL exists - the first two of the three
verification layers the [root README](../README.md) describes.

These papers do not replace that. **They are here to test your own skills and knowledge, nothing
more.** They gate nothing, they are not a qualification, and no part of the course requires them.
No design is built from them and `make build` does not know they exist; `make lint` checks their
Markdown links like any other file here, and that is the whole of the connection. They are useful
where a written result is wanted anyway, for a certifying employer or a formal course credit, and
useful on their own for finding out what you can reconstruct with nothing in front of you.

**Take one after the course is over.** Every paper draws on all eight lectures and on both
capstones, so sitting one partway through examines material nobody has taught you yet, and the
result says more about how far you have read than about what you have understood. The intended point
is after [L08](../lectures/L08/README.md) and the serial receiver and transmitter.

---

## The two papers

Both cover the whole course, L01 to L08, at the same weighting. They share no question. Either can
be used alone; use both as a main sitting and a resit, or in alternate years.

| Question | Topic                                         | Lecture | Marks   |
| -------- | --------------------------------------------- | ------- | ------- |
| 1        | Gates, Boolean algebra, and the first module   | L01     | 12      |
| 2        | Karnaugh maps, multiplexers and submodules     | L02     | 14      |
| 3        | Flip-flops, registers, and when `<=` happens   | L03     | 13      |
| 4        | Metastability, synchronizers and generics      | L04     | 13      |
| 5        | Variables, and what the toolchain builds       | L05     | 13      |
| 6        | Counters and shift registers                   | L06     | 12      |
| 7        | Timers, and composing modules                  | L07     | 10      |
| 8        | State machines, Moore and Mealy                | L08     | 13      |
|          |                                                |         | **100** |

**Paper A leans towards reading and tracing.** Most of its questions hand you something - a truth
table, a clocked process, a listing, a waveform in words - and ask what it does: trace six clock
edges through a two-assignment process, trace a signal accumulator that throws away eight of its
nine assignments, work out how often a timer fires with its clear removed, and design one state
machine from a specification by hand.

**Paper B leans towards writing and reviewing.** Most of its questions ask you to produce a module -
`button_sync` with its generic, `register4`, `piso8`, a modulo-10 counter, `blinker`, a Mealy
detector - or to say what is wrong with one you are handed. Its arithmetic is the capstone's:
oversample ticks, rounding error, and how far a sample point drifts across a frame.

Both papers include at least one design that compiles cleanly and is wrong, because that is the
failure mode this subject actually has.

---

## Why these papers ask for VHDL, when the exercises already do

Because **VHDL is the subject**. A paper that examined the state diagram and stopped short of the
`case` statement would be examining digital design, which this course refreshes rather than teaches.

What a written paper cannot do is run GHDL, and it should not pretend to. So the rubric says
outright that syntax is not what is being marked: a missing semicolon costs nothing, and a process
that describes a latch where the candidate meant a wire costs that part in full. What is being
examined is whether the module describes the right hardware, which is the thing a testbench cannot
tell you and the thing the appendices spend their length on.

---

## Conventions the papers assume

Both papers state these in their own rubric, so a candidate never has to have read this file.

* **VHDL-93**, with `ieee.std_logic_1164`, and `ieee.numeric_std` where a conversion needs it.
* **The course's conventions are the expected ones**: vectors declared `downto`, `port map`
  positional, an active-low signal named `_n`, a two-flop-synchronized signal named `_s2`, a
  subcomponent taking `reset_s2_n` and a top level taking `reset_n`, and shift registers shifting
  toward the most significant bit.
* **The DE0-CV clock is 50 MHz**, a 20 ns period, unless a question says otherwise.
* **Hardware answers, not code answers**, where a question asks what the toolchain builds. "It
  assigns `x`" is not an answer to "what does synthesis produce".
* **Tables in full.** A Karnaugh map group has to be written down as a term.

---

## Marking

Every solution is written to be marked by somebody who has read the appendices and does not
otherwise write VHDL daily, so each carries the reasoning rather than the answer alone. Marks are
shown per part.

Three conventions worth agreeing before a paper is marked:

* **Method carries the marks.** A correct derivation with a slip in it is worth more than a correct
  answer with no working, and both papers are built so that later parts consume earlier ones. Follow
  through an error rather than penalising it twice: an architecture that faithfully implements a
  wrong equation from the part above loses nothing.
* **Mark the hardware, not the syntax.** This is the one that decides whether the paper examines the
  right thing. Where a listing is asked for, the marks are in the sensitivity list, the reset
  branch, the scheduling, the direction of the shift, and whether every path assigns its output -
  not in the punctuation.
* **The named traps are worth full marks on their own.** Several parts exist entirely to see whether
  a candidate avoids one specific mistake. In Paper A: reading a scheduled signal as if it had
  already updated, synchronizing a bus one bit at a time, calling metastability a wrong answer
  rather than a late one, a `case` branch that assigns nothing, a state machine driven by a level
  instead of a pulse, and a timer output wired into a clock port. In Paper B: keeping a redundant
  Karnaugh group, expecting one line of a clocked process to see the next line's assignment, a
  synchronizer chain reset to the wrong idle level, and a process whose sensitivity list omits an
  input it reads. Where a solution flags one of these, a candidate who walks into it loses those
  marks and no others.

There is a fourth, particular to this course. Two questions ask what a design does in **simulation**
and what it does in **hardware**, and the answer is that they differ. An answer that gives one of
the two and calls it the answer has missed the point of the question, however correct that half is.
