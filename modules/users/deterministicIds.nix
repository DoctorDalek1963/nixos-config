# This code was taken from this excellent blog post:
# https://blog.withsam.org/blog/nixos-deterministic-ids/
# We want to make user and group IDs deterministic based on the sha1 hash of
# the name. This makes it easy to transfer files between my machines, for example,
# since even system users will have consistent, deterministic uids and gids
{lib, ...}:
with builtins; let
  userFilter = lib.filterAttrs (_user: opts: (opts.uid == null));
  groupFilter = lib.filterAttrs (_group: opts: (opts.gid == null));

  hexChars = listToAttrs (lib.imap0 (i: v: {
    name = v;
    value = i;
  }) (lib.stringToCharacters "0123456789abcdef"));

  hexToInt = s: lib.foldl (a: b: a * 16 + hexChars."${b}") 0 (lib.stringToCharacters s);

  # Reserve 0-65535 for manual use
  genHash = s: (hexToInt (substring 0 8 (hashString "sha1" s))) * 65535 / 65536 + 65536;

  genId = outAttr: name: opts: opts // {"${outAttr}" = genHash name;};
  genIds = outAttr: sets: mapAttrs (genId outAttr) sets;
in {
  options.users = {
    users = lib.mkOption {
      apply = v: v // (genIds "uid" (userFilter v));
    };
    groups = lib.mkOption {
      apply = v: v // (genIds "gid" (groupFilter v));
    };
  };
}
