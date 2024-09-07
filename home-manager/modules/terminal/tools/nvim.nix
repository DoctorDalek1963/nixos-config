{
  pkgs,
  config,
  system,
  ...
}: let
  nvim-extend = pkgs.writeShellApplication {
    name = "nvim-extend";
    runtimeInputs = [pkgs.mktemp pkgs.nix];
    text = ''
      TMPDIR=$(mktemp -d)
      cat > "$TMPDIR/flake.nix" << EOF
      {
        outputs = {nixvim-config, ...}: {
          packages.${system}.default =
            nixvim-config.packages.${system}.nvim-medium.extend
            {$1};
        };
      }
      EOF
      echo "$(nix build "$TMPDIR" --quiet --no-link --print-out-paths --inputs-from /etc/nixos 2> /dev/null)"/bin/nvim
      rm -rf "$TMPDIR"
    '';
  };
in {
  setup.terminal.shellAliases = {
    v = config.consts.nvimPath;

    nvim-dev = "nix run ${config.home.homeDirectory}/repos/nixvim-config --";

    nvim-tiny = "nix run github:DoctorDalek1963/nixvim-config#nvim-tiny";
    nvim-small = "nix run github:DoctorDalek1963/nixvim-config#nvim-small";
    nvim-medium = "nix run github:DoctorDalek1963/nixvim-config#nvim-medium";
    nvim-full = "nix run github:DoctorDalek1963/nixvim-config#nvim-full";
  };

  home.packages = [nvim-extend];
}
