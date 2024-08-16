{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.programming.haskell {
    home = {
      packages = [pkgs.ghc];

      file.".ghci".text =
        # haskell
        ''
          :set prompt "\ESC[1;35m\STXλ> \ESC[m\STX"
          naturals = [1..]
          sieve (p : xs) = p : sieve [ x | x <- xs, x `mod` p > 0 ]
          primes = 2 : sieve [3,5..]
        '';
    };
  };
}
