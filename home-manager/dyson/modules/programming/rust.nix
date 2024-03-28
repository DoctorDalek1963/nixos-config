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

          [target.x86_64-unknown-linux-gnu]
          linker = "${pkgs.clang}/bin/clang"
          rustflags = ["-Clink-arg=-fuse-ld=${pkgs.mold-wrapped}/bin/mold"]

          [target.armv7-unknown-linux-gnueabihf]
          linker = "arm-linux-gnueabihf-gcc"
        '';
      };
    };

    xdg.configFile."evcxr/init.evcxr".text = "use std::mem::{size_of, transmute};";
  };
}
