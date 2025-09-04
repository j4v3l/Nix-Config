{
  config,
  username,
  ...
}: {
  home-manager.users.${username} = {
    imports = [./common.nix];
  };
}
