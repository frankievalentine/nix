{
  description = "Darwin system flake - frankievalentine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    nixpkgs-unstable,
    nix-homebrew,
    ...
  } @ inputs: let
    add-unstable-packages = final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = "aarch64-darwin";
      };
    };
    username = "frankievalentine";
    configuration = {
      pkgs,
      lib,
      config,
      ...
    }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        add-unstable-packages
      ];
      environment.systemPackages =
        [
          pkgs.coreutils
          pkgs.findutils
          pkgs.gnugrep
          pkgs.gnused
          pkgs.mkalias
          pkgs.openssh
          pkgs.wget
          pkgs.curl
          pkgs.ruby
          pkgs.zsh
          pkgs.zsh-completions
          pkgs.zsh-autosuggestions
          pkgs.zsh-autocomplete
          pkgs.starship
          pkgs.bash
          pkgs.bash-completion
          pkgs.neovim
          pkgs.btop
          pkgs.bottom
          pkgs.lazygit
          pkgs.gdu
          pkgs.libgcc
          pkgs.git
          pkgs.hub
          pkgs.gh
          pkgs.fd
          pkgs.uv
          pkgs.bat
          pkgs.httpstat
          pkgs.zoxide
          pkgs.atuin
          pkgs.mkcert
          pkgs.postgresql_16
          pkgs.mongodb
          pkgs.trashy
          pkgs.mas
          pkgs.navi
          pkgs.tmux
          pkgs.cloudflared
          pkgs.kubernetes-helm
          pkgs.kompose
          pkgs.tart
          pkgs.vagrant
          pkgs.act
          pkgs.fnm
          pkgs.flyctl
          pkgs._1password-cli
          pkgs.deno
          pkgs.bun
          # Start GUI apps available on nix-pkgs unfree
          pkgs.raycast
          pkgs.stats
          pkgs.vscode
          pkgs.warp-terminal
          pkgs.iterm2
          pkgs.github-desktop
          pkgs.httpie
          pkgs.postman
          pkgs.altair
          pkgs.tailscale
          pkgs.tableplus
          pkgs.mongodb-compass
          pkgs.utm
          pkgs._1password-gui
          pkgs.slack
          pkgs.zoom-us
          pkgs.discord
          pkgs.obsidian
          pkgs.obs-studio
          pkgs.iina
          pkgs.keka
        ];

      users.users.frankievalentine = {
        name = username;
        home = "/Users/frankievalentine";
      };

      homebrew = {
        enable = true;
        brews = [
          "mas"
          "mysql-client"
          "ccat"
          "libpq"
        ];
        taps = [
          "homebrew/cask"
          "homebrew/cask-versions"
          "buo/cask-upgrade"
        ];
        casks = [
          "google-chrome"
          "brave-browser"
          "arc"
          "cursor"
          "dbngin"
          "transmit"
          "orbstack"
          "figma"
          "framer"
          "spline"
          "rive"
          "hiddenbar"
          "chatgpt"
          "itsycal"
          "notion"
          "reminders-menubar"
          "timemachineeditor"
          "numi"
          "pictogram"
          "nucleo"
          "protonvpn"
          "signal"
          "ledger-live"
          "webull"
          "tradingview"
        ];
        masApps = {
          "Magnet" = 441258766;
          "Klack" = 2143728525;
          "KeyStroke Pro" = 1572206224;
          "Cursor Pro" = 1447043133;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      fonts.packages = [
        (pkgs.nerdfonts.override { fonts = [
            "JetBrainsMono" 
          ]; 
        })
        pkgs.google-fonts
        pkgs.input-fonts
        pkgs.monaspace
        pkgs.cascadia-code
        pkgs.monoid
        pkgs.geist-font
      ];

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          # Set up applications.
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

      # Disable Mac startup chime
      system.startup.chime = false;

      # Enable TouchID for sudo
      security.pam.enableSudoTouchIdAuth = true;

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      system.defaults = {
        dock.autohide  = true;
        dock.autohide-time-modifier = 0.4;
        dock.showhidden = true;
        dock.mru-spaces = false;
        dock.tilesize = 40;
        dock.wvous-br-corner = 4;
        dock.persistent-apps = [
          "/System/Applications/Utilities/Activity Monitor.app"
          "/Applications/Arc.app"
          "${pkgs.obsidian}/Applications/Obsidian.app"
          "${pkgs.vscode}/Applications/Visual Studio Code.app"
          "${pkgs.iterm2}/Applications/iTerm.app"
          "/Applications/Figma.app"
          "/Applications/Framer.app"
        ];
        finder.FXPreferredViewStyle = "clmv";
        finder.AppleShowAllExtensions = true;
        finder.AppleShowAllFiles = true;
        finder.FXEnableExtensionChangeWarning = false;
        finder.FXRemoveOldTrashItems = true;
        finder.ShowHardDrivesOnDesktop = true;
        finder.ShowMountedServersOnDesktop = true;
        finder.ShowPathbar = true;
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.AppleInterfaceStyle = "System";
        NSGlobalDomain.KeyRepeat = 2;
        NSGlobalDomain.AppleShowAllFiles = true;
        NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
        NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
        WindowManager.AutoHide = true;
        smb.NetBIOSName = "Frankie's Mac Mini";
      };

      networking = {
        computerName = "Frankie's Mac Mini";
        knownNetworkServices = [
          "Wi-Fi"
          "Ethernet"
          "Thunderbolt Bridge"
        ];
        dns = [
          "1.1.1.1"
          "1.0.0.1"
        ];
        hostName = "Frankie's Mac Mini";
        localHostName = "Frankies-Mac-Mini";
      };

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."mini" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            # Apple Silicon Only
            enableRosetta = false;
            # User owning the Homebrew prefix
            user = "frankievalentine";
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."mini".pkgs;
  };
}
