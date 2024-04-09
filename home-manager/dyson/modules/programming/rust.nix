{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.programming.rust {
    home = {
      packages = [
        pkgs.evcxr
      ];

      file = {
        ".cargo/clippy.conf".source = ../../files/clippy.conf;
        ".cargo/config.toml".text = ''
          [alias]
          a = "add"
          b = "build"
          br = "build --release"
          c = "check"
          i = "install"
          n = "new"
          r = "run"
          rr = "run --release"
          t = "test"
          tr = "test --release"
          up = "update"
        '';
      };
    };

    xdg.configFile."evcxr/init.evcxr".text = "use std::mem::{size_of, transmute};";
  };
}
