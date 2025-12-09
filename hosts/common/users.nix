# hosts/common/users.nix
{
  config,
  pkgs,
  lib,
  ...
}@args:
let
  configs = {
    userbornConfig = pkgs.writeTextFile {
      name = "userborn.json";
      text = builtins.toJSON {
        users = [
          {
            isNormal = !config.users.users.vpayno.isSystemUser;
            name = config.users.users.vpayno.name;
            group = config.users.users.vpayno.name;
            home = config.users.users.vpayno.home;
            uid = config.users.users.vpayno.uid;
            shell = "${pkgs.lib.getExe pkgs.bashInteractive}";
            initialHashedPassword = "$2b$05$sOQIg3je3OtGQtX3nbciA.7uGLrvdBSXki1DfbAtjNzpdSvSZeXqe";
          }
        ];
        groups = [
          {
            name = "docker";
            isNormal = false;
            members = [
              "vpayno"
            ];
          }
        ];
      };
    };
  };

  scripts = {
    userbornActivation = pkgs.writeShellApplication {
      name = "userborn-activation-script";
      runtimeInputs = with pkgs; [
        coreutils
        userborn
      ];
      text = ''
        declare config="${configs.userbornConfig}";

        printf "Running: userborn %s\n" "$config"
        exec userborn "$config"
      '';
    };
  };
in
{
  config = {
    systemd = {
      services = {
        userborn = {
          enable = true;
          description = "Activation script for userborn account management";
          wantedBy = [
            "system-manager.target"
          ];
          serviceConfig = {
            ExecStart = "${pkgs.lib.getExe scripts.userbornActivation}";
            Type = "oneshot";
            RemainAfterExit = "yes";
          };
        };
      };
    };

    # noop under system-manager, leaving it here for reference via config
    # system-manager doesn't merge multiple instances of config.user so we have
    # to include them all here.
    users = {
      users = {
        docker = lib.mkIf config.systemd.services.docker-setup.enable {
          name = "docker";
          enable = true;
          uid = 900;
          isSystemUser = true;
          home = "/var/lib/docker";
          group = "docker";
        };
        vpayno = {
          name = "vpayno";
          enable = true;
          uid = 1000;
          isSystemUser = false;
          home = "/home/vpayno";
          group = "vpayno";
        };
      };
      groups = {
        docker = lib.mkIf config.systemd.services.docker-setup.enable {
          name = "docker";
          gid = 900;
        };
        vpayno = {
          name = "vpayno";
          gid = 1000;
        };
      };
    };
  };
}
