{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in {
  programs.home-manager.enable = false;

  home.username = "frankievalentine";
  home.homeDirectory = "/Users/frankievalentine";

  home.stateVersion = "23.11";

  programs = {
    # zsh = import ../home/zsh.nix {inherit config pkgs lib; };
    # starship = import ../home/starship.nix {inherit config pkgs lib; };
    # zoxide = (import ../home/zoxide.nix { inherit config pkgs; });
    # tmux = import ../home/tmux.nix {inherit pkgs;};
  };
}
