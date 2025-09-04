{
  config,
  pkgs,
  lib,
  username,
  ...
}: {
  home-manager.users.${username} = {
    # Host-specific secrets (only if file exists)
    # Place encrypted file at secrets/vm/example_token.yaml
    sops.secrets.example_token_vm = lib.mkIf (builtins.pathExists (../../../. + "/secrets/vm/example_token.yaml")) {
      sopsFile = ../../../secrets/vm/example_token.yaml;
      path = "${config.home.homeDirectory}/.config/secrets/example_token";
    };
    # Mark VM sessions and keep user home clutter-free
    home.sessionVariables.VM = "1";
    xdg.userDirs = {
      enable = true;
      createDirectories = false;
    };

    # Add a tiny helper alias; heavier additions can be done per need
    programs.zsh.shellAliases = {
      isvm = "echo VM=$VM host=$HOSTNAME";
    };

    # Keep VM profile lean by default; extend if needed
    # home.packages = with pkgs; [ fastfetch ];

    # Optional SSH overrides for VM only (uncomment to use)
    # programs.ssh.matchBlocks."internal" = {
    #   hostname = "internal.example";
    #   forwardAgent = false;
    # };
  };
}
