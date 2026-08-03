# Quartus Prime Lite: Installation and Workflow

This is the toolchain reference for the course, and it is **instructor-facing**: the Quartus and
DE0-CV work is demonstrated from the front, starting with the braking assistant in L01, and no
participant
needs Quartus or a board of their own. It lives here rather than in a lecture appendix because
nobody following the course has to execute it.

It covers:
* installing Quartus Prime Lite.
* once installed, taking a VHDL file from source to a running FPGA:
  * new project.
  * adding sources.
  * assigning pins.
  * compiling.
  * programming the board.

This workflow is demonstrated from the front during the lectures; you don't need Quartus or a board
of your own to follow the course. Everything described here ends on real FPGA hardware, verified by
hand. That is a separate layer from the exercises, which you verify on your own laptop by running a
self-checking testbench under GHDL (see
[L02 Appendix C](../lectures/L02/appendix/c_testbenches.md)).

---

## 1. What you need
* **Quartus Prime Lite** (free edition): Intel/Altera's FPGA design software, covering:
  * synthesis.
  * placement and routing ("fitting").
  * programming file generation.
* **Cyclone V device support**: a separate add-on package.
  * The DE0-CV's FPGA, `5CEBA4F23C7N`, is a Cyclone V part.
  * Quartus doesn't include every device family's support by default.
* **USB-Blaster driver**: the DE0-CV programs over USB using Altera's USB-Blaster protocol.
  * the driver usually installs alongside Quartus.
  * it occasionally needs a manual nudge (section 8).
* A **Terasic DE0-CV board** and a USB cable.

Quartus Prime Lite is available for both Windows and Linux; the steps below are the same regardless
of host OS except where noted (the Windows 11-specific gotcha in section 2 doesn't apply on Linux).

---

## 2. Installing Quartus Prime Lite
1. Download Quartus Prime Lite from
   [Intel's Quartus Prime Lite download page](https://www.intel.com/content/www/us/en/software-kit/711791/intel-quartus-prime-lite-edition-design-software-version-20-1-for-windows.html).
   * Any recent Lite release works; this course doesn't depend on a specific point version.
2. During installation, make sure **Cyclone V** is selected under the device family options.
   * If Quartus is already installed without it, add Cyclone V support afterwards by either:
     * re-running the installer.
     * using Quartus's own "Additional Software" / device installer.
3. On first connecting the DE0-CV board over USB, Windows should detect the USB-Blaster and either:
   * install its driver automatically.
   * prompt you to point it at Quartus's own driver files (typically under the Quartus installation
     directory).
   * If Windows can't find a driver automatically, see section 8.

**Windows 11 gotcha:** a couple of Windows 11's security defaults can interfere with this install
or with programming the board later:
* If the installer itself won't open:
  * check Windows Security's `Smart App Control` (search for it in the Start menu).
  * turn it off, then restart.
* If everything installs cleanly but the board still won't program (section 7):
  * go to `Windows Security → Device security → Core isolation`.
  * disable **Memory integrity**:

![`Memory integrity` option under Windows 11's Core isolation settings](./images/mem_integrity.png)

Neither setting affects Quartus itself; both are general Windows 11 hardening defaults that
happen to be strict enough to interfere with driver-level USB access.

---

## 3. Creating a new project
1. Open Quartus and start the **New Project Wizard** (`File → New Project Wizard`).
2. Choose a working directory and a project name.
   * Quartus uses the project name as the default top-level entity name too.
   * Keep them matching your VHDL entity's name to avoid having to override it later (for
     `or_gate.vhd`, name the project `or_gate`).
3. Choose **Empty Project** as the project type.
   * This course doesn't use Quartus's IP catalog or any project templates.
4. Skip adding files at this step (section 4 covers it) unless you already know the exact file; either is
   fine.
5. On the device selection page, select the exact part on the DE0-CV board:
   * filter by family **Cyclone V**.
   * then locate and select the exact device `5CEBA4F23C7N`.
6. Skip the EDA tool settings page (leave it on "none"); this course runs its simulations directly
   in GHDL rather than through Quartus.
7. Finish the wizard.

---

## 4. Adding your VHDL source
* Add your source file:
  * `Project → Add/Remove Files in Project...`, then browse to your `.vhd` file and add it (for
    example, [L01's `or_gate.vhd`](../lectures/L01/or_gate/or_gate.vhd) or L05's
    [`parity_gen.vhd`](../lectures/L05/parity_gen/parity_gen.vhd)). `or_gate` stands in for L01's
    braking assistant throughout this document because the assistant is built live in the lecture
    and deliberately not committed; the steps are identical either way.
* If your design has more than one file (a top-level entity plus one or more subcomponents):
  * add all of them.
  * Quartus resolves the instantiation hierarchy automatically as long as every file is in the
    project.
* Confirm the top-level entity is set correctly:
  * `Project → Set as Top-Level Entity`, with your main file selected.
  * For a single-file design like `or_gate` or `parity_gen`, this is automatic.

---

## 5. Assigning pins with the Pin Planner
Every port in your entity needs a physical pin on the FPGA before Quartus can produce a working
programming file, otherwise there's no way to connect your design's `a`/`b`/`x` (or `bits`/
`parity`) to an actual switch or LED on the board.

1. Run `Processing → Start → Start Analysis & Elaboration` first, then open the Pin Planner:
   * open it via `Assignments → Pin Planner`.
   * on a brand-new project the port list is empty until Quartus has elaborated the design and knows
     its ports.
2. Each of your entity's ports appears as a row.
   * for each one, fill in the **Location** column with the pin identifier for the physical switch or
     LED you want to use.
3. This course doesn't reproduce the DE0-CV's specific pin numbers here.
   * Look them up yourself, either:
     * directly in the Pin Planner (it lists the device's available pins).
     * in the DE0-CV user manual's pinout tables.
   * Use whichever switches/LEDs are convenient on your board.
4. Set the **I/O Standard** column if Quartus doesn't infer a sensible default for the pin you chose.
   * the DE0-CV's general-purpose I/O is 3.3 V LVTTL/LVCMOS.
   * consult the pin's entry in the Pin Planner if in doubt.
5. Save the assignments (they're written into the project's `.qsf` file).
   * any change here requires recompiling (section 6) before it takes effect.
   * Quartus won't retroactively patch a `.sof` that was compiled before the pin assignment changed.

---

## 6. Compiling the design
* `Processing → Start Compilation` (or the ▶ toolbar button) runs the full flow:
  * analysis and synthesis.
  * placement and routing ("fit").
  * timing analysis.
  * assembly into a programming file.
* Read the compilation report once it finishes, especially the **Warnings**:
  * an unconnected port, an incomplete sensitivity list, or a latch inferred where you meant
    combinational logic all show up here as warnings rather than errors.
  * they're easy to miss if you only check for a green checkmark.
* A successful compile produces a `.sof` file (SRAM Object File) in the project's `output_files`
  directory.
  * this is what section 7 loads onto the board.
  * it's volatile: it configures the FPGA's SRAM directly and is lost on power-down; there's no
    persistent flashing step in this course.

---

## 7. Programming the DE0-CV board
1. Connect the DE0-CV to your computer via USB and power it on.
2. Open the Programmer: `Tools → Programmer`.
3. Under **Hardware Setup**, select the USB-Blaster.
   * it should be auto-detected if the driver installed correctly (see section 8 if not).
4. Make sure the `.sof` file produced in section 6 is listed, and its **Program/Configure** checkbox is
   ticked.
   * if it's not listed, use `Auto Detect` or add the file manually.
5. Click **Start**.
   * the progress bar should reach 100% and report success.
6. Test the design directly on the board:
   * flip the switches you assigned in section 5 and confirm the LED matches your entity's truth table:
     * for `or_gate`: lit whenever either switch is on.
     * for `parity_gen`: toggles every time exactly one switch changes.

---

## 8. Troubleshooting
* **USB-Blaster not detected in the Programmer**:
  * check Windows Device Manager for an unknown device or one flagged with a driver error.
  * point it manually at the USB-Blaster driver under the Quartus installation directory.
* **Board won't program, no obvious error**:
  * on Windows 11, disable `Memory integrity` under `Core isolation` (section 2).
  * this is the single most common cause once the driver itself is installed.
* **Installer won't run or open**: check `Smart App Control` under Windows Security (section 2).
* **Compilation succeeds but the design doesn't behave correctly on the board**:
  * re-check the Pin Planner assignments (section 5) before suspecting the VHDL.
  * a swapped or missing pin assignment produces a board that compiles cleanly but behaves
    nonsensically, since it isn't wired the way you think it is.
* **Fitter reports unassigned pins as errors**:
  * some project settings treat this as fatal rather than a warning.
  * either assign every port in the Pin Planner or, for a stray unused port during early development,
    mark it explicitly.
  * Don't leave ports silently unassigned and expect Quartus to guess.

---
