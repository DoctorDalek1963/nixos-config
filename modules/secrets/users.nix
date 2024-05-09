{
  lib,
  config,
  ...
}: let
  cfg = config.setup.secrets;

  userPasswordConfig = user:
    builtins.listToAttrs
    [
      {
        name = "sops";
        value = {secrets."user-passwords/${user}".neededForUsers = true;};
      }
      {
        name = "users";
        value = {
          users."${user}".hashedPasswordFile = config.sops.secrets."user-passwords/${user}".path;
        };
      }
    ];

  allUsers = ["dyson"];
in {
  assertions = [
    {
      assertion = let
        setupUsers = builtins.attrNames config.setup.users;
        passwordUsers = builtins.attrNames cfg.userPasswords.users;
      in
        (allUsers == setupUsers) && (allUsers == passwordUsers);
      message = "config.setup.users must have all the same users as config.setup.secrets.userPasswords.users";
    }
  ];

  imports =
    map (user: {
      config =
        lib.mkIf
        (cfg.enable && cfg.userPasswords.enable && config.setup.users.${user} && cfg.userPasswords.users.${user})
        (userPasswordConfig user);
    })
    allUsers;
}
