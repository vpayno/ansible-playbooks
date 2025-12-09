# hosts/common/service-docker.nix
#
# Notes:
# - can't manage users, you'll need to manually run
#     sudo usermod -a -G docker name
#   to add docker to a user's supplemental group list
{
  context,
  config,
  pkgs,
  ...
}@args:
let
  scripts = {
    dockerSetup = pkgs.writeShellApplication {
      name = "docker-setup";
      runtimeInputs = with pkgs; [
        coreutils
        getent
        shadow
      ];
      text = ''
        declare -i account_uid=${builtins.toString config.users.users.docker.content.uid}
        declare -i account_gid=${builtins.toString config.users.groups.docker.content.gid}

        declare service_name="${config.users.users.docker.content.name}";
        declare service_home="${config.users.users.docker.content.home}";

        if ! getent group "''${service_name}" >&/dev/null; then
          printf "Creating %s service group...\n" "''${service_name}"
          groupadd --gid "''${account_gid}" --system "''${service_name}"
        else
          printf "Service group %s already exists.\n" "''${service_name}"
        fi

        if ! getent passwd "''${service_name}" >&/dev/null; then
          printf "Creating %s service user...\n" "''${service_name}"
          useradd --comment "''${service_name^} service account" --home-dir "''${service_home}" --gid "''${account_gid}" --system --uid "''${account_uid}" "''${service_name}"
        else
          printf "Service account %s already exists.\n" "''${service_name}"
        fi

        printf "Account: "
        id "''${service_name}"
      '';
    };
  };
in
{
  config = {
    environment = {
      systemPackages = with pkgs; [
        dive
        docker
        docker-buildx
        docker-color-output
        docker-compose
        docker-credential-helpers
        docker-gc
        docker-sbom
        docker-slim
        dockerfmt
      ];

      etc = {
        "docker/daemon.json" = {
          text = ''
            {
              "storage-driver": "zfs",
              "storage-opts": []
            }
          '';
          mode = "0644";
          user = "root";
          group = "root";
        };
      };
    };

    systemd = {
      services = {
        docker-setup = {
          enable = true;
          description = "Runs setup script for docker service";
          before = [
            "docker.service"
            "docker.socket"
          ];
          wantedBy = [
            "multi-user.target"
          ];
          serviceConfig = {
            ExecStart = "${pkgs.lib.getExe scripts.dockerSetup}";
            Type = "oneshot";
            RemainAfterExit = "yes";
          };
        };
      };

      units = {
        "docker.service" = {
          name = "docker.service";
          enable = true;
          text = builtins.readFile "${pkgs.docker}/etc/systemd/system/docker.service";
        };
        "docker.socket" = {
          name = "docker.socket";
          enable = true;
          text = builtins.readFile "${pkgs.docker}/etc/systemd/system/docker.socket";
        };
      };
    };
  };
}
