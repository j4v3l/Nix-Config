{
  host ? "desktop",
  path,
}: let
  f = builtins.getFlake (toString (../.));
  inherit (f.inputs.nixpkgs) lib;
  cfg = (builtins.getAttr host f.nixosConfigurations).config;
  segs = lib.splitString "." path;
  val = lib.attrsets.getAttrFromPath segs cfg;
in
  val
