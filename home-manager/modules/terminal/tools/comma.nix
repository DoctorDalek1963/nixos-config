{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.terminal.tools.comma {
    programs = {
      nix-index.enable = true;
      nix-index-database.comma.enable = true;
    };
  };
}
