# hosts/common/nix-client.nix
{
  context,
  config,
  pkgs,
  lib,
  ...
}@args:
{
  config = {
    environment = {
      systemPackages = with pkgs; [
        nh
        nix-btm
        nix-doc
        nix-du
        nix-index
        nix-info
        nix-output-monitor
        nix-top
        nixci
        nixdoc
        nvd
      ];

      etc = {
        "nix/nix.conf-example".text = ''
          build-users-group = nixbld
          experimental-features = nix-command flakes ca-derivations cgroups fetch-closure pipe-operators
          trusted-users = root @wheel @sudo
          download-buffer-size = ${toString (128 * 1024 * 1024)}
          min-free = 10485760   # 1GB
          keep-outputs = false
          keep-derivations = false
          substituters = https://cache.nix.homelab.local/ https://upstream-cache.nix.homelab.local/
          trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.nix.homelab.local-1:fyHToZKInrOcP7trkbnHcoWArXTj9CMLAK8YFTfYOXA=
          trusted-substituters = https://cache.nix.homelab.local/ https://upstream-cache.nix.homelab.local/
        '';

        "nix/machines".text = ''
          # /etc/nix/machines
          #
          # host       platforms           ssh-identity                 max-builds speed-factor features                              host-ssh-id
          ssh://build1 aarch64-linux       /root/.ssh/id_ecdsa-build1   8          5            kvm,nixos-test,big-parallel,benchmark -
        '';

        "hosts".text = ''
          # managed by nix/system-manager
          127.0.0.1       localhost
          ::1             localhost ip6-localhost ip6-loopback
          ff02::1         ip6-allnodes
          ff02::2         ip6-allrouters

          192.168.86.142 cache.nix.homelab.local cache
          192.168.86.142 upstream-cache.nix.homelab.local upstream-cache

          192.168.86.142 build1.homelab.local

          192.168.86.58  nas1.homelab.local
          192.168.86.21  nas2.homelab.local

          192.168.86.71  cloud1.homelab.local

          192.168.86.66  desktop1.homelab.local
          192.168.86.70  gaming1.homelab.local
          192.168.86.69  frame16.homelab.local
        '';
      };
    };

    nix = {
      settings = {
        allowed-users = [
          "root"
          "@nixbld"
          "@sudo"
        ];
        trusted-users = [
          # "root" # added automatically
          "@sudo"
        ];
        max-jobs = "auto";
        substituters = lib.mkForce [
          "http://${context.nix.cache.fqdn}/"
          "https://${context.nix.cacheUpstream.fqdn}/"
          # "https://${context.nix.cacheUpstream.fqdnSource}/"  # added automatically unless lib.mkForce is used
        ];
        trusted-substituters = [
          "http://${context.nix.cache.fqdn}/"
          "https://${context.nix.cacheUpstream.fqdn}/"
        ];
        trusted-public-keys = [
          "${context.nix.cache.publicKey}"
          "${context.nix.cacheUpstream.publicKey}"
        ];
      };

      # first line is intentionally blank
      extraOptions = ''

        #
        # nix.extraOptions
        #

        experimental-features = nix-command flakes ca-derivations cgroups fetch-closure pipe-operators

        # run GC when running out of space
        min-free = ${toString (50 * 1024 * 1024)} # 50GB
        max-free = ${toString (1024 * 1024 * 1024)} # 1TB

        builders-use-substitutes = true
        download-buffer-size = ${toString (512 * 1024 * 1024)}
        keep-outputs = false
        keep-derivations = false
        auto-optimise-store = true
        require-sigs = true
        sandbox = true
        sandbox-fallback = false
      '';
    };
  };
}
