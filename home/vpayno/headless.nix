# home/vpayno/headless.nix
{
  pkgs,
  ...
}@args:
{
  imports = [
    args.inputs.nix-colors.homeManagerModules.default

    ./modules/git.nix
    ./modules/shell.nix
    ./modules/tmux.nix
  ];

  colorScheme = args.inputs.nix-colors.colorSchemes.gruvbox-dark-medium;

  home = {
    stateVersion = "25.11";

    username = "vpayno";
    homeDirectory = "/home/vpayno";

    packages = with pkgs; [
      bashInteractive
      devbox
      tmux
    ];

    sessionVariables = {
      EDITOR = "vim";
    };

    file = {
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };
  };

  systemd.user.startServices = "sd-switch"; # or "legacy" if "sd-switch" breaks again
}
