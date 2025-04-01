{
  pkgs,
  osConfig,
  ...
}: {
  imports = [./bash.nix];

  # TODO: Do something with config.setup.defaultShell

  config = {
    setup.terminal.shellAliases.resetwifi = let
      nmcli = "${pkgs.networkmanager}/bin/nmcli";
      tailscale = "${osConfig.services.tailscale.package}/bin/tailscale";
    in
      if osConfig.services.tailscale.enable
      then "${nmcli} networking off; ${tailscale} down; sleep 5; ${nmcli} networking on; ${tailscale} up"
      else "${nmcli} networking off; sleep 5; ${nmcli} networking on";
  };
}
