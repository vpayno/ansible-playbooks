# hosts/aarch64/raspianServer/default.nix
{
  inputs,
  pkgs,
  ...
}@args:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  imports = [
    ../../common/nix-client.nix
    ../../common/shell.nix
    ../../common/system.nix
    ../../common/users.nix

    ../../common/services-docker.nix
  ];

  config = {
    nixpkgs.hostPlatform = system;

    system-manager.allowAnyDistro = true;

    environment = {
      systemPackages = [
        inputs.system-manager.packages.${system}.default
      ]
      ++ (with pkgs; [
        neofetch
      ]);

      etc = {
      };
    };

    systemd = {
    };
  };
}
