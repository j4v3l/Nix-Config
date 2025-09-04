{user ? "vmware"}: let
  f = builtins.getFlake (toString (../.));
  users = f.homeConfigurations;
  cfg = builtins.getAttr user users;
in
  cfg.activationPackage.drvPath
