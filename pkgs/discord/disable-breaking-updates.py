# slightly tweaked from the script created by @lionirdeadman
# https://github.com/flathub/com.discordapp.Discord/blob/master/disable-breaking-updates.py
"""
Disable breaking updates which will prompt users to download a deb or tar file
and lock them out of Discord making the program unusable.
"""

import json
import os
from pathlib import Path

config_home = os.environ.get("XDG_CONFIG_HOME") or os.path.join(
    os.path.expanduser("~"), ".config"
)

settings_path = Path(f"{config_home}/discord/settings.json")
settings_path_temp = Path(f"{config_home}/discord/settings.json.tmp")

if os.path.exists(settings_path):
    with settings_path.open(encoding="utf-8") as settings_file:
        try:
            settings = json.load(settings_file)
        except json.JSONDecodeError:
            print("[Nix] settings.json is malformed, letting Discord fix itself")
            raise SystemExit(0)
else:
    settings = {}

if settings.get("SKIP_HOST_UPDATE"):
    print("[Nix] Disabling updates already done")
else:
    settings["SKIP_HOST_UPDATE"] = True
    os.makedirs(os.path.dirname(settings_path), exist_ok=True)
    with settings_path_temp.open("w", encoding="utf-8") as settings_file_temp:
        json.dump(settings, settings_file_temp, indent=2)
    settings_path_temp.rename(settings_path)
    print("[Nix] Disabled updates")
