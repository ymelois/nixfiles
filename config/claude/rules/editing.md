# File editing

- Never use shell scripts or one-off programs (`sed`, `awk`, `perl`, `python`, heredoc + redirect, etc.) to create or modify file contents. Use the dedicated Read / Edit / Write tools instead.
- To change an existing file: Read it, then Edit it. To create a new file or fully replace one already Read: use Write.
- This applies even when the same change spans several files: apply it with one Edit (or Write) per file rather than scripting a batch replacement. Per-file edits keep changes reviewable and verify each match exactly.
- Shell commands remain appropriate for non-editing work: building, testing, running formatters/linters, version control, searching, and inspecting files.
- Do not leave placeholder or stub code (`// TODO`, `...`, `pass`, "implement me") when the task asks for a working implementation; either write it or say plainly what is blocking.

# Comments

- Comment to explain intent, a non-obvious constraint, or a reason the code is surprising; do not narrate what the code plainly does ("// loop over the items", "// increment counter").
- Do not restate the line above in a comment, and do not add docstrings that only echo the signature.
- Match the surrounding comment density and style. If a file is sparsely commented, do not flood your addition with comments.
- No decorative banner or section-divider comments, and no comments that address the reader as a tutorial ("Now we will...").
- Remove or update comments you make stale by an edit; never leave a comment describing code that no longer exists.
