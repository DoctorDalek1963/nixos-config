{ inputs, ... }:
{
  flake-file.inputs = {
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [
    inputs.pre-commit-hooks.flakeModule
  ];

  perSystem =
    { pkgs, config, ... }:
    {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          # Secrets
          age
          sops

          # Build ISO with justfile
          just
          fd
          nix-output-monitor
          jq
          cachix
        ];
        shellHook = ''
          ${config.pre-commit.installationScript}
        '';
      };

      # See https://flake.parts/options/git-hooks-nix and
      # https://github.com/cachix/git-hooks.nix/blob/master/modules/hooks.nix
      # for all the available hooks and options
      pre-commit = {
        # This repo contains some large images and patch files with
        # necessary whitespace "errors", so we don't want to run the
        # pre-commit hooks on every file when checking the flake
        check.enable = false;

        settings.hooks = {
          check-added-large-files.enable = true;
          check-merge-conflicts.enable = true;
          check-toml.enable = true;
          check-vcs-permalinks.enable = true;
          check-yaml.enable = true;
          end-of-file-fixer.enable = true;

          trim-trailing-whitespace = {
            enable = true;
            excludes = [ ''.+\.patch$'' ];
          };

          nixfmt-rfc-style = {
            enable = true;
            package = pkgs.nixfmt;
          };

          deadnix.enable = true;
          statix = {
            enable = true;
            stages = [ "pre-push" ];
          };
        };
      };
    };
}
