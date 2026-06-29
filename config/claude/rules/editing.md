# File editing

- Never use shell scripts or one-off programs (`sed`, `awk`, `perl`, `python`, heredoc + redirect, etc.) to create or modify file contents. Use the dedicated Read / Edit / Write tools instead.
- To change an existing file: Read it, then Edit it. To create a new file or fully replace one already Read: use Write.
- This applies even when the same change spans several files: apply it with one Edit (or Write) per file rather than scripting a batch replacement. Per-file edits keep changes reviewable and verify each match exactly.
- Shell commands remain appropriate for non-editing work: building, testing, running formatters/linters, version control, searching, and inspecting files.
- Do not leave placeholder or stub code (`// TODO`, `...`, `pass`, "implement me") when the task asks for a working implementation; either write it or say plainly what is blocking.
