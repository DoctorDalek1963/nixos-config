{
  self,
  pkgs,
  lib,
  system,
  inputs,
  ...
}: let
  install-nixos-with-disko = pkgs.writeShellApplication {
    name = "install-nixos-with-disko";
    runtimeInputs = [
      inputs.disko.packages."${system}".disko
      pkgs.rsync
      pkgs.nix-output-monitor
    ];
    text = builtins.readFile ./install-nixos-with-disko.sh;
  };

  connect-wifi = let
    nmcli = "${pkgs.networkmanager}/bin/nmcli";
  in
    pkgs.writeShellScriptBin "connect-wifi" ''
      if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: $0 SSID PSK"
        exit 1
      fi

      wifi_device="$(${nmcli} device | ${pkgs.gawk}/bin/awk '$2 == "wifi" {print $1}')"

      ${nmcli} connection add type wifi con-name "$1" ifname "$wifi_device" ssid "$1"
      ${nmcli} connection modify "$1" wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$2"
      ${nmcli} connection up "$1"
    '';

  set-password = pkgs.writeShellScriptBin "set-password" ''
    if [[ -z "$1" ]]; then
      echo "Usage: $0 FILENAME"
      exit 1
    fi

    filename="$1"

    read -rs -p "Enter password: " first_password
    echo
    read -rs -p "Enter password again: " second_password
    echo

    if [[ "$first_password" = "$second_password" ]]; then
      echo -n "$first_password" > "$filename"
      echo "Successfully wrote password to $filename"
    else
      printf "\033[31;1mERROR!\033[0m Passwords did not match"
    fi
  '';
in {
  environment.systemPackages = [
    pkgs.git
    pkgs.neovim
    install-nixos-with-disko
    connect-wifi
    set-password
  ];

  # Allow ISO to connect to WiFi
  networking = {
    networkmanager.enable = true;
    wireless.enable = false;
  };

  # Use British keyboard
  services.xserver.xkb.layout = "gb";
  console.keyMap = "uk";

  nix.settings = {
    # Enable flakes
    experimental-features = ["nix-command" "flakes"];

    # Use more caches
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://cache.lix.systems"
      "https://doctordalek1963.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      "doctordalek1963.cachix.org-1:ide2OUuSBdJY4mSTyIanZaafJhcHNA5fFh6P633b8EI="
    ];
  };

  systemd.services.copy-nixos-config-to-tmp = {
    description = "Copy /iso/nixos-config to /tmp/nixos-config";

    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.writeShellScript "copy-nixos-config-to-tmp" ''
        ${pkgs.rsync}/bin/rsync -av --delete "/iso/nixos-config/" "/tmp/nixos-config"
        chmod -R ug+w /tmp/nixos-config
        chown -R nixos:users /tmp/nixos-config
      ''}";
    };
  };

  isoImage = {
    # Slightly larger ISO image size, but significantly faster build times
    squashfsCompression = "gzip -Xcompression-level 1";

    # These paths will end up in /iso when in the installation medium
    contents = [
      {
        source = let
          excludeFilter = path: _type:
            (lib.hasInfix ".direnv" path)
            || (lib.hasSuffix "pi.img" path)
            || (lib.hasSuffix ".pre-commit-config.yaml" path)
            || (lib.hasInfix "result" path);
        in
          lib.cleanSourceWith {
            src = self;
            filter = path: type: ! (excludeFilter path type);
          };
        target = "/nixos-config";
      }
    ];
  };
}
