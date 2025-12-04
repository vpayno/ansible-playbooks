# hosts/common/shell.nix
{
  pkgs,
  ...
}:
{
  config = {
    environment = {
      systemPackages = with pkgs; [
        devbox
        glow
        gum
        jq
        runme
        yq-go
      ];
    };
  };
}
