let
  f = builtins.getFlake (toString (../.));
  names = builtins.attrNames f.inputs;
  toInfo = n: {
    name = n;
    value = let
      si = f.inputs.${n}.sourceInfo or {};
    in {
      url = si.url or null;
      rev = si.rev or null;
      lastModified = si.lastModified or null;
    };
  };
in
  builtins.listToAttrs (map toInfo names)
