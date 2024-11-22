{
  description = "Darwin system flake - frankievalentine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    #Templ
    templ.url = "github:a-h/templ";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    nixpkgs-unstable,
    nix-homebrew,
    templ,
    home-manager,
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
      nixpkgs.config.input-fonts.acceptLicense = true;
      nixpkgs.overlays = [
        inputs.templ.overlays.default
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
          pkgs.templ
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
          pkgs.mas
          pkgs.navi
          pkgs.tmux
          pkgs.cloudflared
          pkgs.kubernetes-helm
          pkgs.kompose
          pkgs.act
          pkgs.fnm
          pkgs.flyctl
          pkgs._1password
          pkgs.deno
          pkgs.bun
          # Start GUI apps available on nix-pkgs unfree
          pkgs.raycast
          pkgs.stats
          pkgs.vscode
          pkgs.warp-terminal
          pkgs.postman
          pkgs.tableplus
          pkgs.iterm2
          pkgs.utm
          pkgs._1password-gui
          pkgs.slack
          pkgs.zoom-us
          pkgs.discord
          pkgs.obsidian
          pkgs.iina
          pkgs.keka
          pkgs.tart
        ];

      users.users.frankievalentine = {
        name = username;
        home = "/Users/frankievalentine";
      };

      homebrew = {
        enable = true;
        taps = [
          "mongodb/brew"
          "buo/cask-upgrade"
        ];
        brews = [
          "mas"
          "mysql-client"
          "mongodb-community"
          "ccat"
          "libpq"
          "trash"
        ];
        casks = [
          "google-chrome"
          "brave-browser"
          "arc"
          "cursor"
          "dbngin"
          "transmit"
          "orbstack"
          "github"
          "vagrant"
          "figma"
          "mongodb-compass"
          "framer"
          "obs"
          "spline"
          "httpie"
          "rive"
          "altair-graphql-client"
          "hiddenbar"
          "chatgpt"
          "itsycal"
          "tailscale"
          "notion"
          "reminders-menubar"
          "timemachineeditor"
          "numi"
          "pictogram"
          "nucleo"
          "protonvpn"
          "signal"
          "webull"
          "tradingview"
        ];
        masApps = {
          "Magnet" = 441258766;
          "Klack" = 6446206067;
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

      # Enable postgres
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_16;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      system.defaults = {
        dock = {
          autohide  = true;
          autohide-time-modifier = 1.2;
          autohide-delay = 0.01;
          
          showhidden = true;
          mru-spaces = false;
          tilesize = 55;
          wvous-br-corner = 4;
          persistent-apps = [
            "/System/Applications/Utilities/Activity Monitor.app"
            "/Applications/Arc.app"
            "${pkgs.obsidian}/Applications/Obsidian.app"
            "${pkgs.vscode}/Applications/Visual Studio Code.app"
            "${pkgs.iterm2}/Applications/iTerm2.app"
            "/Applications/Figma.app"
            "/Applications/Framer.app"
          ];
        };
        finder = {
          FXPreferredViewStyle = "clmv";
          FXEnableExtensionChangeWarning = false;
          FXRemoveOldTrashItems = true;
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          AppleShowAllFolders = true;
          AppleShowAllLibraries = true;
          AppleShowAllMountedVolumes = true;
          AppleShowAllPackages = true;
          AppleShowAllUsers = true;
          ShowHardDrivesOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowPathbar = true;
          ShowTabView = true;
          ShowToolbar = true;
          ShowSidebar = true;
        };
        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          KeyRepeat = 2;
          AppleShowAllFiles = true;
          NSAutomaticWindowAnimationsEnabled = false;
          "com.apple.mouse.tapBehavior" = 1;
          "com.apple.sound.beep.feedback" = 0;
          NSAutomaticSpellingCorrectionEnabled = false;
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
        };
        loginwindow.GuestEnabled = false;
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
        hostName = "Frankies-Mac-Mini";
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
        home-manager.darwinModules.home-manager
        {
          # `home-manager` config
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.frankievalentine = import ./home.nix;
        }
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
