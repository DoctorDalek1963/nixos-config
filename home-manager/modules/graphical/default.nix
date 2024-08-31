{
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.setup.isGraphical {
    services.easyeffects = {
      enable = true;
      preset = "BasicAutogain";
    };

    xdg.configFile = {
      "easyeffects/output/BasicAutogain.json".text = lib.generators.toJSON {} {
        output = {
          "autogain#0" = {
            bypass = false;
            input-gain = 0.0;
            output-gain = 0.0;
            maximum-history = 10;
            reference = "Geometric Mean (MSI)";
            silence-threshold = -70.0;
            target = -18.0;
          };
          blocklist = [];
          plugins_order = ["autogain#0"];
        };
      };
    };
  };
}
