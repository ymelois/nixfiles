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

    programs.git.ignores = lib.mkIf config.programs.git.enable [
      "**/.claude/settings.local.json"
    ];
  };
}
