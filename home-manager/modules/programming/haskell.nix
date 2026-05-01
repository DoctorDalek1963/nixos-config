{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.programming.haskell {
    home.file.".ghci".text = ''
      :set prompt "\ESC[1;35m\STXλ> \ESC[m\STX"
      :set editor "${config.setup.shared.nvim.path}"
    '';
  };
}
