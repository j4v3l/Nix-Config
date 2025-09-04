{
  config,
  pkgs,
  lib,
  username,
  ...
}: {
  home-manager.users.${username} = {
    # Laptop-specific user packages or settings
    home.packages = builtins.filter (p: p != null) (
      with pkgs; [
        (lib.attrByPath ["gnomeExtensions" "bluetooth-quick-connect"] null pkgs)
      ]
    );
    # Host-specific secrets (only if file exists)
    # Place encrypted file at secrets/laptop/example_token.yaml
    sops.secrets.example_token_laptop = lib.mkIf (builtins.pathExists (../../../. + "/secrets/laptop/example_token.yaml")) {
      sopsFile = ../../../secrets/laptop/example_token.yaml;
      path = "${config.home.homeDirectory}/.config/secrets/example_token";
    };

    # Optional SSH overrides for laptop only (uncomment to use)
    # programs.ssh.matchBlocks."bastion" = {
    #   hostname = "bastion.example";
    #   proxyJump = "jump-host";
    #   forwardAgent = true;
    # };
  };
}
