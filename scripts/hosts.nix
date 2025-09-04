let
  f = builtins.getFlake (toString (../.));
in
  builtins.attrNames f.nixosConfigurations
