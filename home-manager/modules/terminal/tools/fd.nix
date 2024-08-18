{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.terminal.tools.fd {
    home.packages = [pkgs.fd];
    xdg.configFile = {
      "fd/ignore".text = ''
        .git/*
        .cache/*
        OneDrive/*
        *.pyc
      '';
    };
  };
}
