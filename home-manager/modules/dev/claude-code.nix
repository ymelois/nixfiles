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

  jq = "${pkgs.jq}/bin/jq";
  grep = "${pkgs.gnugrep}/bin/grep";

  # Re-emit the rules as context on SessionStart. The matcher includes `compact`,
  # so they survive the harness summarising a long session. Read live, no rebuild.
  reinjectRules = pkgs.writeShellScript "claude-reinject-rules" ''
    printf '%s\n\n' "=== USER STANDING RULES (re-asserted after session start/compaction; these OVERRIDE default behaviour and apply to EVERY response) ==="
    cat ${user.configDirectory}/claude/rules/*.md 2>/dev/null || true
  '';

  # Stop hook: block replies with banned characters (em-dash, en-dash, curly
  # quotes) to force a rewrite. Mechanical bans only; prose rules ride the
  # re-injection above. The stop_hook_active guard enforces once, never loops.
  styleLint = pkgs.writeShellScript "claude-style-lint" ''
    set -uo pipefail
    input="$(cat)"

    [ "$(${jq} -r '.stop_hook_active // false' <<<"$input" 2>/dev/null)" = "true" ] && exit 0

    transcript="$(${jq} -r '.transcript_path // empty' <<<"$input" 2>/dev/null)"
    [ -f "$transcript" ] || exit 0

    last="$(${jq} -rs '
      [ .[]
        | select(.type == "assistant")
        | (.message.content // []) | map(select(.type == "text") | .text) | join("\n")
        | select(length > 0)
      ] | last // empty
    ' "$transcript" 2>/dev/null)"

    matches="$(printf '%s' "$last" | ${grep} -nF -e $'—' -e $'–' -e $'‘' -e $'’' -e $'“' -e $'”' || true)"
    [ -n "$matches" ] || exit 0

    {
      echo 'STYLE VIOLATION: your last reply contains banned characters (em-dash, en-dash, or curly quotes).'
      echo 'Rewrite it: use straight quotes only, and replace dashes with commas, semicolons, or periods.'
      echo 'Offending lines:'
      printf '%s\n' "$matches"
    } >&2
    exit 2
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
        github = {
          command = pkgs.writeShellScript "github-mcp" ''
            export GITHUB_PERSONAL_ACCESS_TOKEN="$(cat ${secretPaths.githubPersonalAccessToken})"
            exec ${lib.getExe pkgs.unstable.github-mcp-server} stdio
          '';
          type = "stdio";
        };
        gitlab = {
          command = "${lib.getExe pkgs.unstable.glab}";
          args = [
            "mcp"
            "serve"
          ];
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
