# The Book

The course typeset as a book with LuaLaTeX: eight chapters, one per lecture, then the short answers
to the exercises, the Quartus workflow and the two self-assessment papers as appendices. The
solutions to the VHDL exercises stay in the repository.

---

## Building it

```bash
sudo apt -y install make texlive-luatex texlive-latex-extra fonts-texgyre fonts-texgyre-math \
                    fonts-dejavu-core poppler-utils
make -C book                   # Writes book/digital-design-vhdl.pdf, dated today.
make -C book VERSION=v1.1.0    # The same, with the version on the title page.
make -C book figures           # Renders the figures only, into book/build/figures.
make -C book clean             # Removes book/build/ and the PDF.
```

The figures are drawn by [`diagrams/`](../diagrams/README.md), in the Python environment `make
diagrams` uses; create it once with `python3 -m venv .venv` and
`.venv/bin/pip install -r diagrams/requirements.txt`.

The build renders every figure as a vector PDF, runs LuaLaTeX twice, so the contents and the
cross-references settle, then prints any overfull or underfull lines and LaTeX warnings it found,
and fails if a reference is left undefined. A clean build prints nothing after the two `lualatex`
lines except a handful of mildly underfull ones.

---

## Releasing a new edition

The PDF is committed, beside its sources, so the repository always carries the edition built from
them. To release a new one, rebuild it with the release's version on its title page, commit it,
and tag that commit with the same version:

```bash
make -C book VERSION=v1.1.0
git add book/digital-design-vhdl.pdf
git commit -m "Build the book, v1.1.0"
git tag v1.1.0
git push origin main v1.1.0
```

The README's download link points at the committed PDF, so it never needs updating.

---

## What is where

```text
book.tex                The book: front matter, eight chapters, appendices, in order.
vhdlbook.sty            Every visual decision: page, type, colours, code, figures, exercises.
vhdlbook.lua            How \code{...} typesets inline VHDL (#, backslashes and line breaks).
figures.py              Renders the figures diagrams/ draws as vector PDFs, into build/figures.
front/                  Title pages and preface.
chapters/NN/            Chapter NN: chapter.tex (the opener), one file per group of parts of
                        lecture LNN's Appendix A (and, in Chapter 2, Appendix C), summary.tex (the
                        review) and exercises.tex.
back/answers/           Appendix A: short answers to the exercises' pen-and-paper parts, one file
                        per chapter.
back/quartus.tex        Appendix B: the Quartus and DE0-CV workflow.
back/exam/              Appendices C to G: the papers and their model answers.
```

Every `.tex` file typeset from course material starts with a comment naming its source, for
example:

```tex
% Sections 1.1 to 1.6, from lectures/L01/appendix/a_combinational_logic.md: one section per part,
```

---

## Updating the content

The course material is the source of truth, and the book follows it. **Three kinds of content
behave differently:**

* **The figures update themselves.** The book draws every figure in `diagrams/build.py` from the
  same builders, as vector PDFs, so a changed figure is in the book on the next build. The
  CircuitVerse exports under `lectures/*/appendix/images/` are included as the PNGs they are.
* **The worked examples printed in full update themselves.** The book does not contain their code;
  it includes the files under `lectures/` directly (`\vhdlfile{lectures/...}`), so a change to one
  is in the book on the next build, with nothing to edit here.
* **Prose and the code snippets in the text do not.** A chapter's text is a typeset copy of its
  lecture's markdown. When you change a lecture appendix or README, make the same change in the
  `.tex` file whose header names it. The same holds for `exam/*.md` and `back/exam/`, and for
  `info/quartus_workflow.md` and `back/quartus.tex`.

A few conventions, so an edit reads like the rest of the book:

* Code blocks: `vhdlcode` (VHDL), `shell`, and `console` (tool output, plain text). A text block
  with a character outside ASCII in it, such as a box drawing, is a `textdrawing`, which listings
  cannot mangle. A ```` ```math ```` block is display maths, with `\bool{name}` for a signal name.
* Inline code: `\code{...}`, written exactly as in the source. Inside it, write `\%` for `%`,
  `\{` or `\}` for an unbalanced brace, `\\` for a backslash, and `\#` for `#`.
* References: `\secref{c4:a3}` is the section typeset from A.3 of L04, `\secref{c2:app:c}` is L02's
  Appendix C, and `Exercise~\ref{c6:ex:4}` is exercise 4 of L06 (the book numbers exercises within
  each chapter, as Exercise 6.4, so always refer to them by label).
* Figures: `\bookfigure{name}{caption}{label}` for a figure `diagrams/build.py` draws, by its name
  there; `\bookimage{width}{path}{caption}{label}` for a CircuitVerse export; `\modulefigure{name}`
  for the entity box an exercise shows.
* Exercises: `\exerciseset{Title}` for an exercise set, `\exercise{Title}{Paper, CircuitVerse,
  VHDL}` for one exercise with the kinds of work it asks for, `parts` for its lettered parts,
  `\task{...}` for a titled part, and `\selfcheck` for the paragraph that names its entity and
  testbench.
* A new part worked on paper needs its answer in `back/answers/cNN.tex`: `\answer{cN:ex:k}{Title}`,
  then `\pt{a}` per part.

The solutions to the VHDL exercises are not in the book. Each chapter's exercises say where they are
in the repository (`lectures/LNN/solutions`), so moving or renaming a solution directory means
updating that chapter's `exercises.tex`.

---

## License

The book, its text and figures and the PDF built from them, is licensed under
[CC BY-NC-SA 4.0](../LICENSE-CONTENT), like the course material it is typeset from. This directory's
build files (`vhdlbook.sty`, `vhdlbook.lua`, `figures.py`, `Makefile`) are released under the
repository's [MIT License](../LICENSE), like all the code in the course, and so may the code examples
printed in the book be used.
