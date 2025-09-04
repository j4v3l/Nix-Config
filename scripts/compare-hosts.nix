{
  a ? "desktop",
  b ? "laptop",
  path ? "networking.hostName",
}: let
  f = builtins.getFlake (toString (../.));
  inherit (f.inputs.nixpkgs) lib;
  get = host: let cfg = (builtins.getAttr host f.nixosConfigurations).config; in lib.attrsets.getAttrFromPath (lib.splitString "." path) cfg;
  va = get a;
  vb = get b;
in {
  inherit a b path va vb;
  equal = lib.equal va vb;
}
