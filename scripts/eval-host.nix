{host ? "desktop"}: let
  f = builtins.getFlake (toString (../.));
  hosts = f.nixosConfigurations;
  cfg = builtins.getAttr host hosts;
in
  cfg.config.system.build.toplevel.drvPath
