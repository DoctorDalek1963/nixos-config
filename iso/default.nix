{
  self,
  pkgs,
  lib,
  system,
  inputs,
  ...
}: let
  install-nixos-with-disko = pkgs.callPackage ({stdenvNoCC}:
    stdenvNoCC.mkDerivation {
      name = "install-nixos-with-disko";
      dontUnpack = true;

      buildPhase = ''
        cp ${./install-nixos-with-disko} ./install-nixos-with-disko
        substituteInPlace ./install-nixos-with-disko \
          --replace DISKOCOMMAND "${inputs.disko.packages."${system}".disko}/bin/disko"
      '';

      installPhase = ''
        install -Dm555 ./install-nixos-with-disko $out/bin/install-nixos-with-disko
      '';
    }) {};

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
in {
  environment.systemPackages = [
    pkgs.git
    pkgs.neovim
    pkgs.rsync
    install-nixos-with-disko
    connect-wifi
    inputs.disko.packages."${system}".disko
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
      "https://doctordalek1963.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "doctordalek1963.cachix.org-1:ide2OUuSBdJY4mSTyIanZaafJhcHNA5fFh6P633b8EI="
    ];
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
        target = "/config";
      }
    ];
  };
}
