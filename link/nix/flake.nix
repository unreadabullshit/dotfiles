{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      mac-app-util,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.typescript-language-server
            pkgs.vscode
            pkgs.qbittorrent
            pkgs.tmux
            pkgs.git
            pkgs.kotlin-language-server
            pkgs.starship
            pkgs.zig
            pkgs.cargo
            pkgs.eza
            pkgs.neovim
            pkgs.nodejs_22
            pkgs.iina
            pkgs.discord
            pkgs.ripgrep
            pkgs.fzf
            pkgs.fd
            pkgs.zls
            pkgs.tree-sitter
            pkgs.zoxide
            pkgs.yazi
          ];

          fonts.packages = [
            pkgs.nerd-fonts.commit-mono
          ];

          nixpkgs.config.allowUnfree = true;

          homebrew = {
            enable = true;
            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;

            brews = [
              "lazygit"
              "helix"
              "luarocks"
              "jq"
              "ffmpeg"
              "sevenzip"
              "poppler"
              "imagemagick"
              "pnpm"
              "zsh-syntax-highlighting"
              "zsh-autosuggestions"
            ];

            casks = [
              "ghostty"
              "librewolf"
              "rar"
              "linearmouse"
              "stats"
            ];

            masApps = {
              "DayProgress" = 6450280202;
              "TickTick" = 966085870;
              "Remote Desktop" = 1295203466;
            };
          };


          system.primaryUser = "unreadabullshit";

          system.defaults = {
            dock = {
              autohide = true;
              persistent-apps = [
                "/Applications/LibreWolf.app"
                "/Applications/Ghostty.app"
              ];
              tilesize = 48;
              launchanim = true;
              static-only = false;
              showhidden = false;
              show-recents = false;
              show-process-indicators = true;
              orientation = "bottom";
              mru-spaces = false;
              wvous-tr-corner = 5;
              largesize = 64;
              magnification = true;
              mineffect = "genie";
              minimize-to-application = true;
            };
            loginwindow.GuestEnabled = false;
            NSGlobalDomain = {
              AppleICUForce24HourTime = true;
              AppleInterfaceStyle = "Dark";
              KeyRepeat = 2;
            };
          };

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      darwinConfigurations."air" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          mac-app-util.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "unreadabullshit";

              # Optional: Declarative tap management
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };

              # Optional: Enable fully-declarative tap management
              #
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
            };
          }
        ];
      };
    };
}
