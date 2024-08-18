{
  pkgs,
  lib,
  config,
  ...
}: let
  indent = num: text: let
    padding = lib.strings.concatStrings (lib.lists.replicate num " ");
    lines = lib.strings.splitString "\n" text;
    indented-lines = map (line: padding + line) lines;
  in
    lib.strings.concatStringsSep "\n" indented-lines;

  inherit (config.setup.terminal) theme emulators;

  common = fontSize:
    indent 2 ''
      audible_bell = True
      font = Hack Nerd Font Mono ${toString fontSize}
      scrollbar_position = hidden
      scrollback_infinite = True
      use_system_font = False
      bold_is_bright = False
    '';

  toTerminatorConfig = {
    cursor_color,
    background_color,
    foreground_color,
    dark_grey,
    grey,
    light_grey,
    very_light_grey,
    dark_red,
    light_red,
    dark_green,
    light_green,
    dark_yellow,
    light_yellow,
    dark_blue,
    light_blue,
    dark_magenta,
    light_magenta,
    dark_teal,
    light_teal,
  }: let
    palette1 = "${dark_grey}:${dark_red}:${dark_green}:${dark_yellow}:${dark_blue}:${dark_magenta}:${dark_teal}:${light_grey}";
    palette2 = "${grey}:${light_red}:${light_green}:${light_yellow}:${light_blue}:${light_magenta}:${light_teal}:${very_light_grey}";
  in
    indent 2 ''
      cursor_color = "${cursor_color}"
      background_color = "${background_color}"
      foreground_color = "${foreground_color}"
      palette = "${palette1}:${palette2}"
    '';

  themed-dark =
    {
      # Palette should be "dark_grey : dark_red : dark_green : dark_yellow :
      # dark_blue : dark_purple : dark_teal : light_grey : grey : light_red :
      # light_green : light_yellow : light_blue : light_purple : light_teal :
      # very_light_grey"
      catppuccin-macchiato = {
        name = "catppuccin_macchiato";
        light = toTerminatorConfig {
          cursor_color = "#dc8a78";
          background_color = "#eff1f5";
          foreground_color = "#4c4f69";
          dark_grey = "#5c5f77";
          grey = "#6c6f85";
          light_grey = "#acb0be";
          very_light_grey = "#bcc0cc";
          dark_red = "#d20f39";
          light_red = "#e64553";
          dark_green = "#40a02b";
          light_green = "#70d367";
          dark_yellow = "#fe640b";
          light_yellow = "#df8e1d";
          dark_blue = "#1e66f5";
          light_blue = "#04a5e5";
          dark_magenta = "#8839ef";
          light_magenta = "#ea76cb";
          dark_teal = "#179299";
          light_teal = "#81c8be";
        };
        dark = toTerminatorConfig {
          cursor_color = "#f4dbd6";
          background_color = "#24273a";
          foreground_color = "#cad3f5";
          dark_grey = "#494d64";
          grey = "#6e738d";
          light_grey = "#939ab7";
          very_light_grey = "#b8c0e0";
          dark_red = "#e78284";
          light_red = "#ee99a0";
          dark_green = "#a6d189";
          light_green = "#a6e3a1";
          dark_yellow = "#f5a97f";
          light_yellow = "#eed49f";
          dark_blue = "#8aadf4";
          light_blue = "#7dc4e4";
          dark_magenta = "#c6a0f6";
          light_magenta = "#f5bde6";
          dark_teal = "#81c8be";
          light_teal = "#89dceb";
        };
      };
      onedark = {
        name = "onedark";
        light = toTerminatorConfig {
          cursor_color = "#383a42";
          background_color = "#fafafa";
          foreground_color = "#383a42";
          dark_grey = "#e6e6e6";
          grey = "#a0a1a7";
          light_grey = "#818387";
          very_light_grey = "#383a42";
          dark_red = "#992f2f";
          light_red = "#e45649";
          dark_green = "#357534";
          light_green = "#50a14f";
          dark_yellow = "#7c5c20";
          light_yellow = "#986801";
          dark_blue = "#204593";
          light_blue = "#4078f2";
          dark_magenta = "#79428a";
          light_magenta = "#a626a4";
          dark_teal = "#2b5d63";
          light_teal = "#0184bc";
        };
        dark = toTerminatorConfig {
          cursor_color = "#abb2bf";
          background_color = "#282c34";
          foreground_color = "#abb2bf";
          dark_grey = "#393f4a";
          grey = "#5c6370";
          light_grey = "#848b98";
          very_light_grey = "#abb2bf";
          dark_red = "#993939";
          light_red = "#e86671";
          dark_green = "#688e4d";
          light_green = "#98c379";
          dark_yellow = "#93691d";
          light_yellow = "#e5c07b";
          dark_blue = "#327ebc";
          light_blue = "#73b8f1";
          dark_magenta = "#8a3fa0";
          light_magenta = "#c678dd";
          dark_teal = "#2b6f77";
          light_teal = "#56b6c2";
        };
      };
    }
    .${theme};

  default-and-dark = ''
    [[default]]
    ${common 10}
    ${themed-dark.dark}
  '';

  transparent = ''
    [[transparent]]
    ${common 12}
      background_darkness = 0.8
      background_type = transparent
      foreground_color = "#ffffff"
  '';

  light = ''
    [[light]]
    ${common 12}
    ${themed-dark.light}
  '';

  white = ''
    [[white]]
    ${common 12}
      background_color = "#ffffff"
      foreground_color = "#000000"
      show_titlebar = False
  '';

  profiles = lib.strings.concatStringsSep "\n" (lib.lists.flatten [default-and-dark transparent light white]);
in {
  config = lib.mkIf emulators.terminator {
    home.packages = [pkgs.terminator];

    xdg.configFile."terminator/config".text = ''
      [global_config]
        handle_size = 5
        always_split_with_profile = True
      [keybindings]
      [profiles]
      ${indent 2 profiles}
      [layouts]
        [[default]]
          [[[window0]]]
            type = Window
            parent = ""
            order = 0
            position = 257:122
            maximised = False
            fullscreen = False
            size = 1105, 645
            last_active_term = 28a660ed-cd85-45b9-908c-7fa368e26171
            last_active_window = True
          [[[terminal1]]]
            type = Terminal
            parent = window0
            order = 0
            profile = default
            uuid = 28a660ed-cd85-45b9-908c-7fa368e26171
      [plugins]
    '';
  };
}
