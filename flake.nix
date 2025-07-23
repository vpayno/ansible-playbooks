# flake.nix
{
  description = "Homelab Ansible playbooks flake";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-unstable";

    systems.url = "github:vpayno/nix-systems-default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    treefmt-conf = {
      url = "github:vpayno/nix-treefmt-conf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-conf,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pname = "ansible-playbooks";
        version = "20250520.0.0";
        name = "${pname}-${version}";

        pkgs = nixpkgs.legacyPackages.${system};

        metadata = {
          homepage = "https://github.com/vpayno/ansible-playbooks";
          description = "Homelab Ansible playbooks flake";
          license = with pkgs.lib.licenses; [ mit ];
          # maintainers = with pkgs.lib.maintainers; [vpayno];
          maintainers = [
            {
              email = "vpayno@users.noreply.github.com";
              github = "vpayno";
              githubId = 3181575;
              name = "Victor Payno";
            }
          ];
          mainProgram = "showUsage";
        };

        data = {
          usageMessage = ''
            Available ${name} flake commands:

             nix run .#usage
          '';
        };

        scripts = {
          showUsage = pkgs.writeShellApplication {
            name = "showUsage";

            runtimeInputs = with pkgs; [
              coreutils
            ];

            text = ''
              printf "%s" "${data.usageMessage}"
            '';
          };
        };
      in
      {
        formatter = treefmt-conf.formatter.${system};

        apps = {
          default = self.apps.${system}.usage;

          usage = {
            type = "app";
            pname = "usage";
            inherit version;
            name = "${pname}-${version}";
            program = "${pkgs.lib.getExe scripts.showUsage}";
            meta = metadata;
          };
        };
      }
    );
}
