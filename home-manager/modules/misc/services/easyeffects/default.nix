{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  preset-switcher = pkgs.callPackage ./presetSwitcherPackage.nix {};
in {
  config = lib.mkIf config.setup.misc.services.easyeffects {
    assertions = [
      {
        assertion = config.setup.misc.services.easyeffects -> osConfig.setup.isGraphical;
        message = "config.setup.misc.services.easyeffects requires osConfig.setup.isGraphical, since non-graphical machines don't have audio";
      }
    ];

    services.easyeffects = {
      enable = true;
      preset = "BasicAutogain";
    };

    systemd.user.services.easyeffects-preset-switcher = {
      Unit = {
        Description = "Run the easyeffects-preset-switcher in the systray";
        After = ["graphical-session.target"];
      };

      Install = {
        WantedBy = ["default.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = lib.getExe preset-switcher;
      };
    };

    xdg.configFile = let
      basic-autogain = {
        bypass = false;
        input-gain = 0.0;
        output-gain = 0.0;
        maximum-history = 10;
        reference = "Geometric Mean (MSI)";
        silence-threshold = -70.0;
        target = -18.0;
      };
    in {
      "easyeffects/output/Nothing.json".text = lib.generators.toJSON {} {
        output = {
          blocklist = [];
          plugins_order = [];
        };
      };
      "easyeffects/output/BasicAutogain.json".text = lib.generators.toJSON {} {
        output = {
          "autogain#0" = basic-autogain;
          blocklist = [];
          plugins_order = ["autogain#0"];
        };
      };
      "easyeffects/output/AutogainWithNoiseReduction.json".text = lib.generators.toJSON {} {
        output = {
          "autogain#0" = basic-autogain;
          "rnnoise#0" = {
            bypass = false;
            enable-vad = false;
            input-gain = 0.0;
            model-path = "";
            output-gain = 0.0;
            release = 20.0;
            vad-thres = 50.0;
            wet = 0.0;
          };
          blocklist = [];
          plugins_order = ["autogain#0" "rnnoise#0"];
        };
      };
    };
  };
}
