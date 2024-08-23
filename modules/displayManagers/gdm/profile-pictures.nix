{
  lib,
  config,
  ...
}: let
  mkGdmUserConf = icon: ''
    [User]
    Session=
    XSession=
    Icon=${icon}
    SystemAccount=false
  '';

  mkCommand = name: icon: "echo -e '${mkGdmUserConf icon}' > /var/lib/AccountsService/users/${name}";
in {
  config = lib.mkIf config.setup.displayManagers.gdm.enable {
    systemd.services.populate-gdm-profile-pictures = {
      description = "Populate profile pictures in /var/lib/AccountsService for GDM";
      wantedBy = ["multi-user.target" "accounts-daemon.service"];
      before = ["accounts-daemon.service"];

      script = ''
        mkdir -p /var/lib/AccountsService/users
        ${builtins.concatStringsSep "\n" (
          builtins.attrValues (
            builtins.mapAttrs mkCommand config.setup.profilePictures
          )
        )}
      '';
    };
  };
}
