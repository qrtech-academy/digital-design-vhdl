# Appendix C - Verifying your VHDL with a testbench

This appendix is the course's guide to **running** testbenches, and every later lecture's exercises
point back here. You do not write testbenches in this course, which is the follow-on CAN Controller
Design course's subject, but you run one after every VHDL exercise, because with no FPGA board of
your own that is what verifies your VHDL. Every worked example and every exercise ships a ready-made
`<module>_tb.vhd`.

---

## C.1 What you need
* **GHDL**, the open-source VHDL analyzer and simulator. Check with `ghdl --version`; install on
  WSL/Ubuntu with `sudo apt -y install ghdl`.

Every command below uses `--std=93`, the VHDL standard this course targets.

---

## C.2 What a testbench is
A testbench is itself a VHDL module, but a special one:
* Its entity has **no ports**: nothing connects to the outside, because it is the top of the
  simulation.
* Its architecture **instantiates your design**, the "device under test" labelled `dut`, and drives
  its inputs.
* It **checks** each output with an `assert`. If an output is wrong, the assertion fires with a
  message and the simulation stops.

So instead of you reading a waveform to decide whether the output is right, the testbench decides,
and only speaks up when something is wrong.

---

## C.3 Running a testbench: analyze -> elaborate -> run
Three steps. Pass `--std=93` to all three, and give the **testbench entity name**, not a filename,
to the last two:

```bash
ghdl -a --std=93 <module>.vhd <module>_tb.vhd        # analyze both files (module first)
ghdl -e --std=93 <module>_tb                         # elaborate the testbench
ghdl -r --std=93 <module>_tb --assert-level=error --stop-time=10ms   # run it
```

* `--assert-level=error` makes a failed check stop the run and return a **non-zero exit code**, a
  real pass/fail you can check with `echo $?`. The testbenches here raise failures at
  `severity failure`, which stops the run on its own, so you get a real pass/fail even without the
  flag. Keep it on anyway: it is the habit that also works with testbenches reporting at a lower
  severity.
* `--stop-time=10ms` caps how long the simulation may run. A testbench often waits for your module
  to do something, with a line like `wait until tx = '0';`. If your module never does, that wait
  never finishes and without a stop time the simulation hangs: no output, no error, just a terminal
  sitting there. 10 ms of *simulated* time is far more than any testbench here needs, and takes well
  under a second of real time.
* A passing run prints its "all checks passed" note and exits 0. Every testbench in this course ends
  with that note, so if you do not see it, the run did not finish: it either failed a check or hit
  the stop time.

---

## C.4 Checking an exercise
Each VHDL exercise ships its testbench in its own directory. For example, this lecture's exercise 3
has `lectures/L02/exercises/xyz_logic/xyz_logic_tb.vhd`. Write your module in **that same
directory**, named exactly as the exercise asks, then run the three commands from there:

```bash
cd lectures/L02/exercises/xyz_logic
ghdl -a --std=93 xyz_logic.vhd xyz_logic_tb.vhd
ghdl -e --std=93 xyz_logic_tb
ghdl -r --std=93 xyz_logic_tb --assert-level=error --stop-time=10ms
```

Each testbench header lists these exact commands.

The testbench connects to your module **by position**, not by name, so your entity must declare its
ports in the **same order** the exercise lists them. The names are yours to choose, but use the ones
specified anyway, so your module and the testbench's error messages talk about the same signals.

A port declared in the wrong order fails in one of two ways, neither of which says "wrong order":
* if the misplaced ports have **different** types or widths, analysis stops with
  `can't associate "sel" with port "sel"`, pointing at the testbench's `port map` line.
* if they have the **same** type, several `std_logic` ports say, it analyzes and elaborates quite
  happily, then fails at run time as an ordinary assertion failure, which reads exactly like a logic
  bug in your design.

So when a testbench fails on the very first case it checks, re-read your port order before hunting
through your architecture. The same applies to **generics**: a module that carries them must declare
exactly the ones the exercise specifies, in order.

---

## C.5 When the design needs more than one file
Some exercises build a module out of another one, so the `ghdl -a` line names several files instead
of two. The elaborate and run steps are unchanged: they still take the testbench **entity name**
only.

```bash
ghdl -a --std=93 <subcomponent>.vhd <module>.vhd <module>_tb.vhd
ghdl -e --std=93 <module>_tb
ghdl -r --std=93 <module>_tb --assert-level=error --stop-time=10ms
```

* **Order matters on the analyze line**: name a module before anything that instantiates it, so
  GHDL has already seen the entity when it reaches the `entity work.<name>` that refers to it.
  Subcomponents first, your top level next, the testbench last.
* No exercise directory ships a subcomponent. Every module a design instantiates is one you wrote
  in an earlier exercise and copy in yourself; the exercise says which, and where from.
* The exercises that need this are L02's `hex_display` (which instantiates your `display`), L04's
  `led_toggle_sync2`, L07's `blinker` (`reset_sync` and `timer`) and `walking_led` (those two plus
  `button_sync`), and all of L08's, where the receiver names five files and the transmitter four.
* Every testbench header lists the exact command for its own exercise.

---

## C.6 Reading the result
A failed check looks like this:

```text
xyz_logic_tb.vhd:37:13:@10ns:(assertion failure): xyz_logic: wrong X with a='0' b='0' c='0' d='0', expected '0' but got '1'!
ghdl:error: assertion failed
```

Read it in order: `file:line` is where the assert is, `@time` is when it fired, then the message.
It is the same shape as a GHDL compile error, so it maps onto what you already know. No failure
means every case matched.

---

## C.7 A complete example
A combinational testbench in the shape every testbench in this course uses, here for L01's
`or_gate`:

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity or_gate_tb is
end entity;

architecture behaviour of or_gate_tb is
signal a, b, x: std_logic;
begin
    dut: entity work.or_gate
        port map(a, b, x);   -- positional: same order as or_gate's port clause.

    SIM_PROCESS: process is
    begin
        for i in 0 to 3 loop
            (a, b) <= std_logic_vector(to_unsigned(i, 2));   -- apply inputs
            wait for 10 ns;                                  -- let them settle
            assert x = (a or b)                              -- check AFTER the wait
                report "or_gate: wrong output with a=" & std_logic'image(a)
                     & " b=" & std_logic'image(b)
                     & ", expected " & std_logic'image(a or b)
                     & " but got " & std_logic'image(x) & "!"
                severity failure;
        end loop;
        report "or_gate: all checks passed!" severity note;
        wait;                                                -- end the simulation
    end process;
end architecture;
```

Two rules keep a combinational testbench correct:
* **Apply -> wait -> check, in that order.** A signal assignment only *schedules* a value, so the
  inputs and output do not update until the `wait`. Checking before it tests the previous
  iteration's values.
* **End with `wait;`** so the stimulus process suspends and the simulation stops on its own.

Clocked designs need a little more, a clock-generator process and a way to stop it, which is exactly
the machinery the provided testbenches already contain. For the exercises you only ever write the
module.

---
