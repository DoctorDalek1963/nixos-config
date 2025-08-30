{
  pkgs,
  osConfig,
  ...
}:
{
  imports = [ ./bash.nix ];

  # TODO: Do something with config.setup.defaultShell

  config = {
    setup.terminal.shellAliases = {
      # Basics
      grep = "${pkgs.gnugrep}/bin/grep --color=auto";
      diff = "${pkgs.diffutils}/bin/diff --color=auto";

      # NixOS management
      cdnc = "cd /etc/nixos";
      cdhm = "cd /etc/nixos/home-manager";

      cdtmp = "cd $(mktemp -d)";

      # Single letters
      c = "cat";
      t = "touch";
      x = "exit";

      # Two letters
      cl = "clear";
      ps = "${pkgs.procps}/bin/ps auxf";
      rm = "${pkgs.coreutils}/bin/rm -v";

      resetwifi =
        let
          nmcli = "${pkgs.networkmanager}/bin/nmcli";
          tailscale = "${osConfig.services.tailscale.package}/bin/tailscale";
        in
        if osConfig.services.tailscale.enable then
          "${nmcli} networking off; ${tailscale} down; sleep 5; ${nmcli} networking on; ${tailscale} up"
        else
          "${nmcli} networking off; sleep 5; ${nmcli} networking on";
    };

    home.packages = [
      (pkgs.writeShellApplication {
        name = "myip";
        runtimeInputs = with pkgs; [
          gum
          jq
          sd
        ];

        # Taken from https://flox.dev/blog/layering-and-composing-flox-environments
        text = ''
          ip=$(curl -s https://ipinfo.io)
          gum style --padding "1 2" \
              "$(gum style --foreground 12 --bold "Your Public IP:")" \
              "" \
              "$(gum style --foreground 11 --bold "IP:")        $(gum style --foreground 2 "$(echo "$ip" | jq -r .ip)")" \
              "$(gum style --foreground 11 --bold "Location:")  $(gum style --foreground 2 "$(echo "$ip" | jq -r '.city + ", " + .region + ", " + .country')")" \
              "$(gum style --foreground 11 --bold "ISP:")       $(gum style --foreground 2 "$(echo "$ip" | jq -r .org)")" \
              "$(gum style --foreground 11 --bold "Coords:")    $(gum style --foreground 2 "$(echo "$ip" | jq -r .loc | sd -F ',' ', ')")"
        '';
      })
    ];
  };
}
