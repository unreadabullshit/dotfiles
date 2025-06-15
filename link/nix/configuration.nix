{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
	      consoleMode = "auto";
      };
      efi.canTouchEfiVariables = true;
    };
  };
  
  # Network
  networking = {
    hostName = "pix";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
    };
  };

  # Location Stuff
  time.timeZone = "America/Sao_Paulo";
  console.keyMap = "br-abnt2";
  i18n = {
    defaultLocale = "pt_BR.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };
  fonts.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Compatibility Stuff
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Hardware
  hardware = {
    pulseaudio.enable = false;

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    opentabletdriver = {
      enable = true;
    };
  };

  # Services
  services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    desktopManager.plasma6.enable = true;
    printing.enable = true;

    xserver = {
      enable = true;
      videoDrivers = ["nvidia"];
      xkb = {
        layout = "br";
        variant = "nodeadkeys";
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

  };

  # Programs
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    gamemode = {
      enable = true;
    };

    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
    };

    starship = {
      enable = true; # seems like this wasn't enough to install starship automagically so i'll be adding it to systemPackages as well
      settings = pkgs.lib.importTOML "${config.users.users.unreadabullshit.home}/.config/starship.toml";
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
    };
  };

  # Environment
  environment = {
    plasma6.excludePackages = with pkgs.kdePackages; [
      konsole
      plasma-browser-integration
      kate
      khelpcenter
    ];

    systemPackages = with pkgs; [
	    starship
      git
      tmux
      librewolf
      hplip
      # floorp
      protonup
      ruby
      localsend
      ripgrep
      gh
      fzf
      networkmanagerapplet
      colorls
      lutris
      cowsay
      protontricks
      fortune
      lazygit
      rar
      btop
      fastfetch
      osu-lazer-bin
      zig
      wine
      kitty
      mangohud
      discord
      nodejs_22
      gparted
    ];

    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${config.users.users.unreadabullshit.home}/.steam/root/compatibilitytools.d";
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };
  };


  # Users
  users = {
    defaultUserShell = pkgs.zsh;
    users.unreadabullshit = {
      isNormalUser = true;
      description = "unreadabullshit";
      extraGroups = [ "networkmanager" "wheel" "input" ];
    };
  };

  # System
  system = {
    stateVersion = "24.05";
    autoUpgrade = {
      enable = true;
      dates = "daily";
      channel = "https://nixos.org/channels/nixos-24.05";
    };
  };


  # Nix
  nix = {
    # settings.experimental-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 20d";
    };
  };

  # Ungrouped
  security.rtkit.enable = true;
  sound.enable = true;
  nixpkgs.config.allowUnfree = true;
}
