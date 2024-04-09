{
  pkgs,
  config,
  ...
}: let
  scripts = builtins.foldl' (acc: elem: acc // elem) {} (
    builtins.attrValues (
      builtins.mapAttrs (
        username: picture-path: {
          "set-gnome-profile-picture-for-${username}" = {
            text = "${pkgs.imagemagick}/bin/convert -resize 96x96 ${picture-path} png:/home/${username}/.face";
          };
        }
      )
      config.setup.profilePictures
    )
  );
in {
  system.activationScripts = scripts;
}
