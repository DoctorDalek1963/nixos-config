{
  lib,
  config,
  ...
}: let
  cfg = config.setup.terminal;
in {
  config = lib.mkMerge [
    (lib.mkIf cfg.tools.direnv {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;

        config.global.hide_env_diff = true;
      };

      setup = {
        impermanence.keepDirs = [".local/share/direnv"];
        terminal.shellAliases.ndr = "nix-direnv-reload";
      };
    })
    (lib.mkIf (cfg.tools.direnv && cfg.shells.bash) {
      programs = {
        direnv.enableBashIntegration = false;

        # Copied mostly from the output of "direnv hook bash" but adapted to use
        # blesh. This fixes a bug with Starship where the Starship prompt would
        # run in blesh's PRECMD before _direnv_hook would run in PROMPT_COMMAND

        # TODO (direnv): Keep up to date. This version copied from 2.36.0

        # Once https://github.com/direnv/direnv/pull/1439 is merged and
        # included in a release, we can go back to home-managers's Bash
        # integration option
        bash.initExtra =
          # bash
          ''
            _direnv_hook() {
              local previous_exit_status=$?;
              trap -- "" SIGINT;
              eval "$("${lib.getExe config.programs.direnv.package}" export bash)";
              trap - SIGINT;
              return $previous_exit_status;
            };

            if [[ ''${BLE_VERSION-} && _ble_version -ge 400 ]]; then
              blehook PRECMD!="_direnv_hook"
            elif [[ ";''${PROMPT_COMMAND[*]:-};" != *";_direnv_hook;"* ]]; then
              if [[ "$(declare -p PROMPT_COMMAND 2>&1)" == "declare -a"* ]]; then
                PROMPT_COMMAND=(_direnv_hook "''${PROMPT_COMMAND[@]}")
              else
                PROMPT_COMMAND="_direnv_hook''${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
              fi
            fi

          '';
      };
    })
  ];
}
