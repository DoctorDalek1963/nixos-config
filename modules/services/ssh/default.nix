{
  flake.aspects =
    { aspects, ... }:
    {
      ssh = {
        includes = [
          aspects.secrets
        ];

        nixos =
          { pkgs, ... }:
          {
            environment.systemPackages = [
              pkgs.sshfs
            ];

            services.openssh = {
              enable = true;
              settings = {
                PermitRootLogin = "no";
                PasswordAuthentication = false;
              };
            };

            programs = {
              ssh.knownHostsFiles = [ ./github.keys ];
              mosh.enable = true;
            };

            impermanence.files = [
              "/etc/ssh/ssh_host_rsa_key"
              "/etc/ssh/ssh_host_rsa_key.pub"
              "/etc/ssh/ssh_host_ed25519_key"
              "/etc/ssh/ssh_host_ed25519_key.pub"
            ];
          };

        homeManager =
          {
            pkgs,
            lib,
            config,
            ...
          }:
          let
            ssh-keys = lib.optionals (config.home.username == "dyson") [
              "github_main"
              "git_main_signing"
              "id_ed25519"
            ];

            ssh-add-commands = map (
              keyname:
              let
                script = pkgs.writeShellScript "cat-passphrase" ''cat "${
                  config.sops.secrets."ssh/${keyname}/passphrase".path
                }"'';
              in
              ''cat "${
                config.sops.secrets."ssh/${keyname}/keys/${keyname}".path
              }" | SSH_ASKPASS="${script}" SSH_ASKPASS_REQUIRE=force ssh-add -''
            ) ssh-keys;

            populate-ssh-keychain = pkgs.writeShellScript "populate-ssh-keychain" (
              builtins.concatStringsSep "\n" ssh-add-commands
            );

            cfg = config.programs.keychain;

            flags =
              cfg.extraFlags
              ++ lib.optional (cfg.agents != [ ]) "--agents ${builtins.concatStringsSep "," cfg.agents}"
              ++ lib.optional (cfg.inheritType != null) "--inherit ${cfg.inheritType}";

            shellCommand = "${lib.getExe cfg.package} --eval ${builtins.concatStringsSep " " flags} ${builtins.concatStringsSep " " cfg.keys}";
          in
          {
            programs = {
              keychain = {
                enable = true;
                keys = ssh-keys;
                extraFlags = [
                  "--noask"
                  "--quiet"
                ];

                enableBashIntegration = false;
                enableZshIntegration = false;
              };

              bash.initExtra = ''
                eval "$(SHELL=bash ${shellCommand})"
                if [ $(ssh-add -l | ${lib.getExe' pkgs.coreutils "wc"} -l) -lt ${toString (builtins.length ssh-add-commands)} ]; then
                  ${populate-ssh-keychain} &> /dev/null
                fi
              '';

              zsh.initExtra = ''
                eval "$(SHELL=zsh ${shellCommand})"
                ${populate-ssh-keychain} &> /dev/null
              '';
            };
          };
      };
    };
}
