{
  lib,
  config,
  ...
}: let
  cfg = config.setup.secrets;

  userPasswordConfig = users:
    builtins.listToAttrs
    (lib.lists.flatten
      (builtins.map (user: [
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
        ])
        users));
in {
  # TODO: Why do I get an infinite recursion error when I use
  # `cfg.userPasswords.users` here?
  config = lib.mkIf (cfg.enable && cfg.userPasswords.enable) (userPasswordConfig ["dyson"]);
}
