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
        };

        data = {
          usageMessage = ''
            Available ${name} flake commands:

             nix run .#usage

             nix run .#ci-actionlit
             nix run .#ci-check
             nix run .#ci-format
             nix run .#ci-lint
          '';

          gitignoreConfig = ./.gitignore;
          yamlfixConfig = ./.yamlfix.toml;
          yamlintConfig = ./.yamllint.yaml;
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

          ci-actionlint = pkgs.writeShellApplication {
            name = "ci-actionlint";

            runtimeInputs = with pkgs; [
              actionlint
            ];

            text = ''
              printf "Running %s...\n"
              actionlint ./.github/workflows/*yaml
            '';
          };

          ci-check = pkgs.writeShellApplication {
            name = "ci-check";

            runtimeInputs = with pkgs; [
              ansible-lint
            ];

            text = ''
              printf "Running ansible-lint...\n"
              # ansible-lint wants "bad" yaml formatting, ignoring
              ansible-lint --skip-list=formatting ./playbooks/ ./tasks/ ./templates/ ./files/ ./tools/
            '';
          };

          ci-format = pkgs.writeShellApplication {
            name = "ci-format";

            runtimeInputs = with pkgs; [
              yamlfix
            ];

            text = ''
              printf "Using yamlfix to format yaml files...\n"
              yamlfix --config-file ${data.yamlfixConfig} ./.github/ ./playbooks/ ./tasks/ ./templates/ ./files/ ./tools/
            '';
          };

          ci-lint = pkgs.writeShellApplication {
            name = "ci-lint";

            runtimeInputs = with pkgs; [
              markdownlint-cli
              yamllint
            ];

            text = ''
              printf "Linting Markdown files...\n"
              markdownlint --ignore-path ${data.gitignoreConfig} .
              printf "\n"

              printf "Linting Yaml files...\n"
              yamllint --config-file ${data.yamlintConfig} ./.github/ ./playbooks/ ./tasks/ ./files/ ./tools/
              printf "\n"
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
            meta = metadata // {
              description = "Flake usage screen";
              mainProgram = "showUsage";
            };
          };

          ci-actionlint = {
            type = "app";
            pname = "ci-actionlint";
            inherit version;
            name = "${pname}-${version}";
            program = "${pkgs.lib.getExe scripts.ci-actionlint}";
            meta = metadata // {
              description = "GitHub action linter";
              mainProgram = "ci-actionlint";
            };
          };

          ci-check = {
            type = "app";
            pname = "ci-check";
            inherit version;
            name = "${pname}-${version}";
            program = "${pkgs.lib.getExe scripts.ci-check}";
            meta = metadata // {
              description = "Ansible checks";
              mainProgram = "ci-check";
            };
          };

          ci-format = {
            type = "app";
            pname = "ci-format";
            inherit version;
            name = "${pname}-${version}";
            program = "${pkgs.lib.getExe scripts.ci-format}";
            meta = metadata // {
              description = "Yaml Formatter";
              mainProgram = "ci-format";
            };
          };

          ci-lint = {
            type = "app";
            pname = "ci-lint";
            inherit version;
            name = "${pname}-${version}";
            program = "${pkgs.lib.getExe scripts.ci-lint}";
            meta = metadata // {
              description = "Yaml and Markdown formatter";
              mainProgram = "ci-lint";
            };
          };
        };

        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              actionlint
              ansible-builder
              ansible-cmdb
              ansible-doctor
              ansible-lint
              ansible-navigator
              gh
              glab
              glibcLocales
              glow
              jq
              runme
              shellcheck
              shfmt
              yamlfix
              yamllint
              yq-go
            ];

            # usually not needed in nixos, needed everywhere else
            LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
            LANG = "en_US.UTF-8";

            shellHook = ''
              ${pkgs.cowsay}/bin/cowsay "Welcome to ${name} devShell"
            '';

          };
        };
      }
    );
}
