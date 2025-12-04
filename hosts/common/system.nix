# hosts/common/system.nix
{
  pkgs,
  ...
}@args:
{
  config = {
    environment = {
      systemPackages = with pkgs; [
        btop
        coreutils-full
        git
        glibcLocales
        moreutils
        openssh
        openssl
        tmux
        tree
      ];

      etc = {
        nix-system = {
          text = ''
            ${args.system}
          '';
          target = "nix-system";
          mode = "0644";
          user = "root";
          group = "root";
        };

        "environment" = {
          text = ''
            # /etc/environment
            # shellcheck shell=sh
            PATH="/run/system-manager/sw/bin:/nix/var/nix/profiles/default/bin:/opt/sbin:/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
            LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive";
          '';
        };

        "default/locale" = {
          text = ''
            LANG=en_US.UTF-8
            LANGUAGE=en_US.UTF-8
            LC_ALL=en_US.UTF-8
          '';
        };

        "profile" = {
          source = ../../files/etc/profile;
        };

        "bash.bashrc" = {
          source = ../../files/etc/bash.bashrc;
        };
      };
    };
  };
}
