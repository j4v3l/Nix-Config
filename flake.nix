{
  description = "Personal NixOS + Home Manager flake with Desktop, Laptop, and VM hosts";

  inputs = {
    # Stable nixpkgs channel. You can switch to nixos-unstable if you prefer.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Home Manager release that matches nixpkgs above
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # sops-nix for secrets in HM
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix-native Git hooks (pre-commit) integration
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    git-hooks,
    ...
  }: let
    # Adjust if you have a different architecture
    system = "x86_64-linux";
    username = "vmware"; # default login; can be overridden per host below

    # Optionally customize usernames per host
    hostUsers = {
      desktop = username;
      laptop = username;
      vm = username;
    };

    inherit (nixpkgs) lib;

    mkHost = hostName: hostPath:
      lib.nixosSystem {
        inherit system;
        specialArgs = {
          username = hostUsers.${hostName};
          inputs = {inherit nixpkgs home-manager;};
        };
        modules =
          [
            hostPath
            # Home Manager as a NixOS module
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                # Pass args into HM modules, so we can read `username` there too
                extraSpecialArgs = {username = hostUsers.${hostName};};
                # Make sops-nix HM module available to all HM configs on this host
                sharedModules = [sops-nix.homeManagerModules.sops];
              };
            }
          ]
          # Optional locally-tracked private module for secure user settings
          # Provide a no-op template at ./private/secure-users.nix
          ++ lib.optional (builtins.pathExists ./private/secure-users.nix) ./private/secure-users.nix;
      };

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in {
    nixosConfigurations = {
      desktop = mkHost "desktop" ./hosts/desktop;
      laptop = mkHost "laptop" ./hosts/laptop;
      vm = mkHost "vm" ./hosts/vm;
    };

    # Optional: a standalone Home Manager config target (useful for non-NixOS)
    homeConfigurations = let
      uniqueUsers = lib.unique (builtins.attrValues hostUsers);
    in
      lib.listToAttrs (map (u: {
          name = u;
          value = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [./home/profiles/common.nix sops-nix.homeManagerModules.sops];
            extraSpecialArgs = {username = u;};
          };
        })
        uniqueUsers);

    # Formatter for `nix fmt`
    formatter.${system} = pkgs.alejandra;

    # Checks for `nix flake check`
    checks.${system} = let
      preCommit = git-hooks.lib.${system}.run {
        src = self;
        hooks = {
          alejandra.enable = true;
        };
      };
    in {
      fmt = pkgs.runCommand "fmt-check" {buildInputs = [pkgs.alejandra];} ''
        alejandra -c ${self}
        touch $out
      '';
      statix = pkgs.runCommand "statix-check" {buildInputs = [pkgs.statix];} ''
          statix check \
            --config ${self}/statix.toml \
            --ignore 'hosts/*/hardware-configuration.nix' \
            ${self}
        touch $out
      '';

      # Runs Nix-native pre-commit hooks (alejandra, statix, deadnix) over the repo
      pre-commit = preCommit;
    };

    # Minimal dev environment when you run `nix develop`
    devShells.${system}.default = pkgs.mkShell (
      let
        preCommit = git-hooks.lib.${system}.run {
          src = self;
          hooks = {
            alejandra.enable = true;
          };
        };
      in {
        packages = with pkgs;
          [
            git
            direnv
            nix-direnv
            alejandra
            statix
          ]
          ++ preCommit.enabledPackages;

        # Auto-configure Git hooks on shell entry; disable by unsetting GIT_HOOKS
        inherit (preCommit) shellHook;
      }
    );
  };
}
