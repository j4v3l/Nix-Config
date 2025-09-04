let
  f = builtins.getFlake (toString (../.));
  hosts = builtins.attrNames f.nixosConfigurations;
  hasExample = host: builtins.pathExists (../. + "/secrets/" + host + "/example_token.yaml");
  mk = h: {
    name = h;
    value = {example_token = hasExample h;};
  };
in
  builtins.listToAttrs (map mk hosts)
