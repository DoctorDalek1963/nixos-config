{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.terminalTools.comma {
    programs = {
      nix-index.enable = true;
      nix-index-database.comma.enable = true;
    };
  };
}
