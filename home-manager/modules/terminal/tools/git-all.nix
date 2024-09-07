{
  pkgs,
  lib,
  config,
  ...
}: let
  git-all = pkgs.stdenv.mkDerivation {
    name = "git-all";
    propagatedBuildInputs = [(pkgs.python3.withPackages (p: [p.rich]))];
    dontUnpack = true;
    installPhase = "install -Dm755 ${../../../files/scripts/git_all.py} $out/bin/git-all";
  };

  git-all-bin = "${git-all}/bin/git-all";
in {
  config = lib.mkIf config.setup.terminal.tools.git-all {
    home.packages = [git-all];

    setup.terminal.shellAliases = {
      gstall = "${git-all-bin} status";
      gfall = "${git-all-bin} fetch";
      gplall = "${git-all-bin} pull";
      gfplall = "${git-all-bin} fetch && ${git-all-bin} pull";
      gpall = "${git-all-bin} push";
    };

    systemd.user = {
      services.git-fetch-all = {
        Unit.Description = "Periodically run `git-all fetch`";

        Service = {
          Type = "simple";
          # TODO: This is a horrible hack that I'm using to authenticate SSH
          # keys in the service's shell. It would be much better to somehow
          # re-use the populate-ssh-keychain script from modules/secrets/keychain.nix
          ExecStart = toString (pkgs.writeShellScript "git-fetch-all-service-script" ''
            source /home/dyson/.bashrc
            ${git-all-bin} fetch
          '');
        };
      };

      timers.git-fetch-all = {
        Timer = {
          Unit = "git-fetch-all.service";
          OnCalendar = "*:00:00";
        };
      };
    };
  };
}
