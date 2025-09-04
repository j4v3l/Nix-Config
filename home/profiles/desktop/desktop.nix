{
  config,
  pkgs,
  lib,
  username,
  ...
}: {
  home-manager.users.${username} = {
    # Desktop-specific user packages or settings can go here
    home.packages =
      (with pkgs; [vlc])
      ++ lib.optional (lib.hasAttrByPath ["kdePackages" "spectacle"] pkgs) pkgs.kdePackages.spectacle;
    # Host-specific secrets (only if file exists)
    # Place encrypted file at secrets/desktop/example_token.yaml
    # To create: sops --age <pub> -e -i secrets/desktop/example_token.yaml
    sops.secrets.example_token_desktop = lib.mkIf (builtins.pathExists (../../../. + "/secrets/desktop/example_token.yaml")) {
      sopsFile = ../../../secrets/desktop/example_token.yaml;
      path = "${config.home.homeDirectory}/.config/secrets/example_token";
    };

    # Optional SSH overrides for desktop only (uncomment to use)
    # programs.ssh.matchBlocks."corp-git" = {
    #   hostname = "git.corp.example";
    #   user = "git";
    #   identityFile = [ "${config.home.homeDirectory}/.ssh/id_ed25519_corp" ];
    # };
  };
}
