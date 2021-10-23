Mutaml: A Mutation Tester for OCaml
===================================

Mutaml is a mutation testing tool for OCaml. 
Briefly, that means Mutaml tries to change your code randomly to see
if the changes are caught.

In more detail: 
[Mutation testing](https://en.wikipedia.org/wiki/Mutation_testing) is
a form of fault injection used to assess the quality of a program's
testsuite. Mutation testing works by repeatedly making small, breaking
changes to a program's text, such as turning a `+` into `-`, negating
the condition of an `if-then-else`, ..., and subsequently rerunning
the testsuite to see if each such 'mutant program' is 'killed'
(caught) by one or more tests in the testsuite. By finding examples of
uncaught wrong behaviour, mutation testing can thereby reveal
limitations of an existing testsuite and indirectly suggest
improvements.

Since OCaml already prevents many potential programming errors at compile
time (strong type system, pattern-match compiler warnings, ...) Mutaml
favors mutations that
- preserve typing and
- would not be caught statically, e.g., changes in the values computed.

Mutaml consists of:

 - a [`pxxlib`](https://github.com/ocaml-ppx/ppxlib)-preprocessor that
   first transforms the program under test.
 - a runner that loops through a range of possible program mutations,
   saving the output of each individual test
 - a reporter that prints a test report to the console.


Installation:
-------------

Installing Mutaml

```
$ clone https://github.com/jmid/mutaml.git
$ cd mutaml
$ opam install .
```


Instructions:
-------------

How you can use `mutaml` depends on your project's build setup.
Preferably it should support an explicit two-staged build process.
For now it has only been tested it with `dune`:


### Using Mutaml with `dune`

1. Mark the target code for instrumentation in your `dune` file(s):
   ```
   (library
     (public_name your_library)
     (instrumentation (backend mutaml)))
   ```
   Using `dune`'s [`instrumentation` stanza](https://dune.readthedocs.io/en/stable/instrumentation.html), your project's code is
   only instrumented when you pass the `--instrument-with mutaml`
   option.


2. Compile your test code with `mutaml` instrumentation enabled:
   ```
   $ dune build test --instrument-with mutaml
   ```
   This creates/overwrites an individual `lib.muts` file for each
   instrumented `lib.ml` file and an overview file
   `mutaml-mut-files.txt` listing them.
   These files are written to `dune`'s current build context.


3. Start mutaml-runner, passing the name of the test executable to run:
   ```
   $ mutaml-runner _build/default/test/mytests.exe
   ```
   This reads from the files written in step 2. Running the command also
   creates/overwrites the file `mutaml-report.json`.
   You can also pass a command that runs the executable through `dune`
   if you prefer:
   ```
   $ mutaml-runner "dune exec --no-build test/mytest.exe"
   ```

4. Generate a report, optionally passing the json-file
   (`mutaml-report.json`) created above:
   ```
   $ mutaml-report
   ```
   By default this prints `diff`s for each mutation that flew under
   the radar of your test suite. This output can be suppressed by
   passing `-no-diff`.


Steps 3 and 4 output a number of additional files.
These are all written to a dedicated directory named `_mutations`



Options and Environment Variables
---------------------------------

The `mutaml` preprocessor's behaviour can be configured through either
environment variables or parameters in the `dune` file:

- `MUTAML_SEED` - an integer value to seed mutaml-ppx's randomized
  mutations (overridden by option `-seed`)
- `MUTAML_MUT_RATE` - a integer between 0 and 100 to specify the
  mutation frequency (0 means never and 100 means always, overridden by option `-mut-rate`)
- `MUTAML_GADT` - allow only pattern mutations compatible with GADTs
  (`true` or `false`, overridden by option `-gadt`)


For example, the following `dune` sets all three options:
```
 (executable
  (name test)
  (instrumentation (backend mutaml -seed 42 -mut-rate 75 -gadt))
 )
```
We could achieve the same behaviour by setting three environment
variables:
```bash
  $ export MUTAML_SEED=42
  $ export MUTAML_MUT_RATE=75
  $ export MUTAML_GADT=true
```
If you do both, the values passed in the `dune` file takes precedence.



Status
------

This is an *alpha* release. There are therefore rough edges:

- Mutaml is designed to avoid repeated recompilation for each
  mutation. It does so by writing files during preprocessing which are
  later read during the `mutaml-runner` testing loop. As a consequence,
  if you attempt to merge steps 2 and 3 above into one this will not work:
  ```
  $ mutaml-runner "dune test --force --instrument-with mutaml"
  ```
  The preprocessor in this case only writes the relevant files when
  `mutaml-runner` first calls the command, and thus *after* it needs the
  information  contained in the files...

- There are [issues to force `dune` to
rebuild](https://github.com/ocaml/dune/issues/4390). This can affect
  Mutaml, e.g., in case just an environment variable changed. `dune
  clean` is a crude but effective work-around to this issue.

- The output files to `_build/default` are not registered with `dune`.
  This means rerunning steps 2,3,4 above will fail, as the additional
  output files in `_build/default` are not cached by `dune` and hence
  deleted. Again `dune clean` is a crude but effective work-around.

- ...


Mutations should not introduce compiler errors, be it type errors or
from the pattern-match compiler (if so: please report it in an issue).


Acknowledgements
----------------

Mutaml was developed with support from the [OCaml Software Foundation](https://ocaml-sf.org/).