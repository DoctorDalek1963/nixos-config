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

  mkBootCommand = name: icon: "echo -e '${mkGdmUserConf icon}' > /var/lib/AccountsService/users/${name}\n";

  bootCommands = builtins.attrValues (builtins.mapAttrs mkBootCommand config.setup.profilePictures);
in {
  config = lib.mkIf config.setup.displayManagers.gdm.enable {
    boot.postBootCommands = lib.strings.concatStrings bootCommands;
  };
}
