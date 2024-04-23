{
  self,
  pkgs,
  ...
}: let
  install-nixos-with-disko = pkgs.callPackage ({stdenvNoCC}:
    stdenvNoCC.mkDerivation {
      name = "install-nixos-with-disko";
      dontUnpack = true;
      installPhase = "install -Dm555 ${./install-nixos-with-disko} $out/bin/install-nixos-with-disko";
    }) {};

  connect-wifi = let
    nmcli = "${pkgs.networkmanager}/bin/nmcli";
  in
    pkgs.writeShellScriptBin "connect-wifi" ''
      if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: $0 SSID PSK"
      fi

      wifi_device="$(${nmcli} device | ${pkgs.gawk}/bin/awk '$2 == "wifi" {print $1}')"

      ${nmcli} connection add type wifi con-name "$1" ifname "$wifi_device" ssid "$1"
      ${nmcli} connection modify "$1" wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$2"
    '';
in {
  environment.systemPackages = [
    pkgs.git
    pkgs.neovim
    pkgs.rsync
    install-nixos-with-disko
    connect-wifi
  ];

  # Allow ISO to connect to WiFi
  networking.networkmanager.enable = true;

  # Use British keyboard
  services.xserver.xkb.layout = "gb";
  console.keyMap = "uk";

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  isoImage = {
    # Slightly larger ISO image size, but significantly faster build times
    squashfsCompression = "gzip -Xcompression-level 1";

    # These paths will end up in /iso when in the installation medium
    contents = [
      {
        source = self;
        target = "/config";
      }
    ];
  };
}