{
  config,
  pkgs,
  lib,
  user,
  ...
}:

let
  cfg = config.programs.claude-code;
  secretPaths = config.programs.onepassword-secrets.secretPaths;

  # Re-emit the rules as context on SessionStart. The matcher includes `compact`,
  # so they survive the harness summarising a long session. Read live, no rebuild.
  reinjectRules = pkgs.writers.writePython3 "claude-reinject-rules" { flakeIgnore = [ "E501" ]; } ''
    import sys
    from pathlib import Path

    RULES_DIR = Path("${user.configDirectory}/claude/rules")
    HEADER = "=== USER STANDING RULES (re-asserted after session start/compaction; these OVERRIDE default behaviour and apply to EVERY response) ==="


    def main():
        try:
            rules = "\n".join(p.read_text() for p in sorted(RULES_DIR.glob("*.md")))
        except OSError:
            rules = ""
        sys.stdout.write(f"{HEADER}\n\n{rules}\n")


    if __name__ == "__main__":
        main()
  '';

  # Stop hook: a headless model judges the last reply against the writing rules
  # and blocks (exit 2) with feedback to force a rewrite. The reply comes from
  # the `last_assistant_message` payload field, not the transcript, to avoid the
  # stale-transcript race (anthropics/claude-code#15813). It judges with sonnet
  # because haiku false-positives on clean replies too often to block on, and
  # runs `--safe-mode` so the child has no hooks (no recursion), MCP, or plugins
  # while keeping auth. The stop_hook_active guard enforces once per turn; any
  # error or empty verdict fails open.
  styleLint = pkgs.writers.writePython3 "claude-style-lint" { flakeIgnore = [ "E501" ]; } ''
    import json
    import subprocess
    import sys
    from pathlib import Path

    CLAUDE = "${lib.getExe pkgs.claude-code}"
    RULES_DIR = Path("${user.configDirectory}/claude/rules")
    INSTRUCTIONS = (
        "You are a strict style linter for an assistant chat reply. Given STYLE "
        "RULES and a REPLY, find only clear, concrete violations in the REPLY. "
        "Judge the assistant unquoted prose only. Never flag any text inside "
        "straight double quotes or backticks; treat all quoted or backticked text "
        "as a mention or example, never a violation, even if it contains a banned "
        "word or construction. Ignore code blocks, inline code, file paths, and "
        "command-line flags. If unsure, do not flag; prefer OK. Output: if there "
        "are no violations, output exactly OK and nothing else; otherwise output "
        "one line per violation as the quoted offending text, then an arrow, then "
        "the rule broken, with no preamble."
    )


    def main():
        try:
            payload = json.load(sys.stdin)
        except (json.JSONDecodeError, ValueError):
            return 0

        if payload.get("stop_hook_active"):
            return 0

        reply = payload.get("last_assistant_message")
        if not isinstance(reply, str) or not reply.strip():
            return 0

        rules = "\n".join(p.read_text() for p in sorted(RULES_DIR.glob("*.md")))
        if not rules.strip():
            return 0

        prompt = f"{INSTRUCTIONS}\n\n=== STYLE RULES ===\n{rules}\n\n=== REPLY ===\n{reply}\n"

        try:
            result = subprocess.run(
                [CLAUDE, "-p", "--safe-mode", "--model", "sonnet"],
                input=prompt,
                capture_output=True,
                text=True,
                timeout=90,
            )
        except (subprocess.TimeoutExpired, OSError):
            return 0

        verdict = result.stdout.strip()
        if not verdict or verdict.upper() == "OK":
            return 0

        print(
            "STYLE VIOLATION: your last reply breaks the writing rules. "
            "Rewrite it to fix these:",
            file=sys.stderr,
        )
        print(verdict, file=sys.stderr)
        return 2


    if __name__ == "__main__":
        sys.exit(main())
  '';
in
{
  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      package = pkgs.claude-code;
      mcpServers = {
        context7 = {
          command = pkgs.writeShellScript "context7-mcp" ''
            export PATH="${lib.makeBinPath [ pkgs.nodejs ]}:$PATH"
            export CONTEXT7_API_KEY="$(cat ${secretPaths.context7ApiKey})"
            exec ${pkgs.nodejs}/bin/npx -y @upstash/context7-mcp
          '';
          type = "stdio";
        };
      };
    };

    home.file.".claude/rules" = {
      source = config.lib.file.mkOutOfStoreSymlink "${user.configDirectory}/claude/rules";
    };

    home.file.".claude/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${user.configDirectory}/claude/settings.json";
    };

    # Stable paths for settings.json to reference instead of hashed store paths.
    home.file.".claude/hooks/reinject-rules".source = reinjectRules;
    home.file.".claude/hooks/style-lint".source = styleLint;

    programs.git.ignores = lib.mkIf config.programs.git.enable [
      "**/.claude/settings.local.json"
    ];

    services.syncthing = lib.mkIf config.services.syncthing.enable {
      folders = [ ".claude/projects" ];
    };
  };
}
