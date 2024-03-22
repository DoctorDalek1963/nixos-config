{config, ...}: let
  # TODO: Make a derivation for a shell script that can switch to an active
  # window if it exists or start a new instance of that program. Then use that
  # shell script for the xremap maps
  xremap-config = {
    keymap = [
      {
        name = "Firefox";
        remap.alt-f.launch = ["firefox"];
      }
    ];
  };
in {
  # TODO: Fork xremap/nix-flake to add `enable` option
  # Current xremap is always installed but we just remove all the mappings when
  # it's disabled
  services.xremap = {
    withGnome = true;
    config =
      if config.setup.miscPrograms.xremap
      then xremap-config
      else {};
  };
}
