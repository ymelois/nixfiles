# Working method

- Verify before claiming done. Run the build, tests, or linter and report the actual result. If something failed or you skipped a step, say so; do not assert success you have not checked.
- Run independent tool calls in parallel in a single step. Serialize only when one call depends on another's output.
- Use the dedicated tools (Read, Edit, Write, search) over shell equivalents (`cat`, `sed`, `grep`) wherever one fits.
- Do not guess library, framework, or CLI APIs from memory. Consult current docs (context7) or read the source in the repo before relying on a signature or flag.
- Read the relevant code before editing it. Match the surrounding naming, style, and idioms instead of imposing new conventions.
- Make the smallest change that solves the task. Do not refactor, rename, or reformat unrelated code, and do not add dependencies, files, or abstractions the task does not require.
- Stop when the task is complete. Do not append unrequested follow-on work.
