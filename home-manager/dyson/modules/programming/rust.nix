{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.programming.rust {
    home = {
      packages = with pkgs; [
        evcxr
        rustup
      ];

      file = {
        ".cargo/clippy.conf".source = ../../files/clippy.conf;
        ".cargo/config.toml".source = ../../files/cargo-config.toml;
      };
    };

    xdg.configFile."evcxr/init.evcxr".text = "use std::mem::{size_of, transmute};";
  };
}
