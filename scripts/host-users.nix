let
  f = builtins.getFlake (toString (../.));
  inherit (f.inputs.nixpkgs) lib;
  hostNames = builtins.attrNames f.nixosConfigurations;
  normalUsers = cfg:
    builtins.attrNames (
      lib.attrsets.filterAttrs (n: u: (u.isNormalUser or false) && n != "root") cfg.config.users.users
    );
  mk = h: {
    name = h;
    value = normalUsers (builtins.getAttr h f.nixosConfigurations);
  };
in
  builtins.listToAttrs (map mk hostNames)
