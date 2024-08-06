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

  allUsers = ["dyson" "pi" "rebecca"];
in {
  assertions = [
    {
      assertion = let
        setupUsers = builtins.attrNames config.setup.users;
        passwordUsers = builtins.attrNames cfg.userPasswords.users;
      in
        (allUsers == setupUsers) && (allUsers == passwordUsers);
      message = "config.setup.users must have all the same users as config.setup.secrets.userPasswords.users and all those users must be defined in modules/secrets/users.nix";
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
