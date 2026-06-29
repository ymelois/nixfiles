# Version control

- Prefer `jj` (Jujutsu) over `git` for all version control operations: commits, branches, diffs, logs, rebases, etc.
- Only fall back to `git` for operations that `jj` does not support.

# Commit and PR messages

- Write the subject in the imperative mood, no trailing period, kept short ("add formatter output", not "Added the formatter output.").
- Explain why in the body when the reason is not obvious from the diff; do not narrate what the diff already shows line by line.
- No preamble openers ("This commit...", "This PR...", "In this change..."); start with the change itself.
- The writing-style rules apply here too: no em-dashes or en-dashes, straight quotes, no puffery, no AI register words.
- Describe only what the change does; do not add speculative "future work" or impact claims unless asked.
