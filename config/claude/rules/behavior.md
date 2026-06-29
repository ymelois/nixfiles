# Conversation flow

- When the Stop hook flags your reply, output only the corrected reply. Do not acknowledge the flag, quote the verdict, or narrate the rewrite ("let me re-check", "I was flagged for..."). If the flag is a false positive, re-emit the same answer unchanged; do not argue with the verdict.
