{
  config,
  pkgs,
  username,
  ...
}: {
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
  };

  # Home Manager is enabled below in the grouped programs block

  # CLI toolkit
  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    bat
    eza
    neovim
    tree
  ];

  programs = {
    home-manager.enable = true;

    git = {
      enable = true;
      userName = username;
      userEmail = "${username}@local";
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      # zsh plugins
      plugins = [
        # You Should Use: prompts to use defined aliases
        {
          name = "you-should-use";
          src = pkgs.zsh-you-should-use;
        }
      ];

      # Useful aliases (including common NixOS/Home-Manager shortcuts)
      shellAliases = {
        ll = "eza -l --git";
        la = "eza -la --git";
        gs = "git status";

        # NixOS / Nix aliases
        nr = "sudo nixos-rebuild switch";
        nru = "sudo nixos-rebuild switch --upgrade";
        nrb = "sudo nixos-rebuild build";
        nrf = "sudo nixos-rebuild switch --flake .#$(hostname)";
        ngc = "sudo nix-collect-garbage -d";

        # Home Manager shortcuts
        hn = "home-manager switch";
        hnf = "home-manager switch --flake .#${username}";

        # Helpers
        editconfig = "nvim ${config.home.homeDirectory}/.config/nixpkgs/home/profiles/common.nix";
        # Home Manager niceties
        hm = "home-manager";
        hmr = "home-manager switch --flake .#${username}"; # quick apply for this user
        hmnews = "home-manager news";

        # Nix / development helpers
        nshell = "nix-shell -p"; # usage: nshell PACKAGE
        nps = "nix profile list"; # list your nix profiles
        nfu = "nix flake update"; # update flake inputs
        ntree = "nix tree"; # requires nix tree command/profile
        nrbf = "sudo nixos-rebuild switch --flake .#$(hostname)"; # rebuild current host via flake
        nixgc = "sudo nix-collect-garbage -d"; # aggressive GC (requires sudo)

        # Additional cool Nix/NixOS commands
        nv = "nixos-version";
        nrebuild = "sudo nixos-rebuild switch";
        nrebuild-boot = "sudo nixos-rebuild boot";
        nrebuild-test = "sudo nixos-rebuild test";
        nprofile-install = "nix profile install"; # usage: nprofile-install PACKAGE
        nprofile-remove = "nix profile remove"; # usage: nprofile-remove PROFILE
        nprofile-list = "nix profile list";
        nsearch = "nix search"; # search flakes / packages
        nflake-check = "nix flake check";
        nflake-show = "nix flake show";
        nflake-info = "nix flake metadata";
        nverify = "sudo nix-store --verify --check-contents"; # verify store integrity
        nfc = "nix run nixpkgs#alejandra -- -q . && nix flake check --show-trace"; # format and lint check

        # Quick helpers for flakes + hosts
        switch-host = "sudo nixos-rebuild switch --flake .#$(hostname)";
        update-flakes-and-rebuild = "nix flake update && sudo nixos-rebuild switch --flake .#$(hostname)";

        # Shortcuts for inspecting GC and store usage
        nix-du = "find /nix/store -maxdepth 1 -mindepth 1 -type d -print0 | xargs -0 du -sh | sort -h"; # rough per-derivation sizes (handles many entries)
      };

      oh-my-zsh = {
        enable = true;
        # Pick any installed/available oh-my-zsh theme (e.g. "agnoster", "robbyrussell", "powerlevel10k")
        theme = "gianu"; #agnoster geoffgarside gianu
        # include alias-tips so zsh will suggest the alias for a long command
        plugins = ["git" "docker" "command-not-found"];
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    # Shared SSH configuration (can be overridden per-host in host HM modules)
    ssh = {
      enable = true;
      # Safe default: do not forward agent globally
      forwardAgent = false;

      matchBlocks = {
        "github.com" = {
          user = "git";
          # identityFile can be added if you use non-default paths
          # identityFile = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
        };
      };

      # Extra SSH client hardening and robustness options (applies to all hosts)
      extraConfig = ''
        Host *
          # Prefer protocol 2 only (modern OpenSSH defaults to this)
          Protocol 2

          # Disallow agent and X11 forwarding by default
          ForwardAgent no
          ForwardX11 no
          ForwardX11Trusted no

          # Prefer publickey auth only; avoid password-based fallbacks
          PreferredAuthentications publickey

          # Keep connections alive but fail fast on dead peers
          ServerAliveInterval 60
          ServerAliveCountMax 3
          TCPKeepAlive no

          # Connection multiplexing for performance
          ControlMaster auto
          ControlPath ~/.ssh/controlmasters/%r@%h:%p
          ControlPersist 10m

          # Disable compression unless explicitly needed
          Compression no

          # Host key checking: be strict by default
          StrictHostKeyChecking ask
          UserKnownHostsFile ~/.ssh/known_hosts

          # Limit rekeying to reasonable boundaries
          RekeyLimit 1G 1h

          # Strong algorithm selection (modern OpenSSH)
          Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
          KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
          HostKeyAlgorithms ssh-ed25519,ecdsa-sha2-nistp256,rsa-sha2-512,rsa-sha2-256
      '';

      # Optionally manage known_hosts entries here (fill in real values or remove)
      # knownHosts = {
      #   "github.com" = "github.com,140.82.112.4 ssh-ed25519 AAAA...";
      # };
    };
  };
  services.ssh-agent.enable = true;

  # sops-nix: use SSH private key(s) as age identities (recommended)
  # The key will be converted to an age identity on the fly.
  sops.age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
  # Alternatively, use a dedicated age key file:
  # sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  # Example secret (uncomment and create an encrypted file under `secrets/` to use):
  # sops.secrets."example_token" = {
  #   # Path to your encrypted file (tracked in git)
  #   sopsFile = ./../../secrets/example_token.yaml;
  #   # Where to place the decrypted file in your HOME
  #   path = "${config.home.homeDirectory}/.config/secrets/example_token";
  # };

  home.stateVersion = "25.05";
}
