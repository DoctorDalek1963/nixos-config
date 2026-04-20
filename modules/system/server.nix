{
  flake.aspects =
    { aspects, ... }:
    {
      system-server = {
        includes = [ aspects.system-core ];

        nixos = { };
      };
    };
}
