let
  f = builtins.getFlake (toString (../.));
  hosts = builtins.attrNames f.nixosConfigurations;
  hasHW = host: builtins.pathExists (../. + "/hosts/" + host + "/hardware-configuration.nix");
  mk = h: {
    name = h;
    value = hasHW h;
  };
in
  builtins.listToAttrs (map mk hosts)
