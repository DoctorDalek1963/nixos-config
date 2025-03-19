{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.podman.enable {
    virtualisation = {
      containers.enable = true;

      podman = {
        enable = true;
        dockerCompat = true;

        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };
}
