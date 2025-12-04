# flake.nix
{
  description = "Homelab Ansible playbooks flake";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-conf = {
      url = "github:vpayno/nix-treefmt-conf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      flake-parts,
      treefmt-conf,
      ...
    }@inputs:
    let
      pname = "ansible-playbooks";
      version = "20250520.0.0";
      name = "${pname}-${version}";
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }@inputs'':
        let
          # pkgs = nixpkgs.legacyPackages.${system};
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };

          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config = {
              allowUnfree = true;
            };
            overlays = [
            ];
          };

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
              program = "${pkgs.lib.getExe scripts.showUsage}";
              meta = metadata // {
                description = "Flake usage screen";
                pname = "usage";
                inherit version;
                name = "${pname}-${version}";
                mainProgram = "showUsage";
              };
            };

            ci-actionlint = {
              type = "app";
              program = "${pkgs.lib.getExe scripts.ci-actionlint}";
              meta = metadata // {
                description = "GitHub action linter";
                pname = "ci-actionlint";
                inherit version;
                name = "${pname}-${version}";
                mainProgram = "ci-actionlint";
              };
            };

            ci-check = {
              type = "app";
              program = "${pkgs.lib.getExe scripts.ci-check}";
              meta = metadata // {
                description = "Ansible checks";
                pname = "ci-check";
                inherit version;
                name = "${pname}-${version}";
                mainProgram = "ci-check";
              };
            };

            ci-format = {
              type = "app";
              program = "${pkgs.lib.getExe scripts.ci-format}";
              meta = metadata // {
                description = "Yaml Formatter";
                pname = "ci-format";
                inherit version;
                name = "${pname}-${version}";
                mainProgram = "ci-format";
              };
            };

            ci-lint = {
              type = "app";
              program = "${pkgs.lib.getExe scripts.ci-lint}";
              meta = metadata // {
                description = "Yaml and Markdown formatter";
                pname = "ci-lint";
                inherit version;
                name = "${pname}-${version}";
                mainProgram = "ci-lint";
              };
            };
          };

          devShells = {
            default = pkgs.mkShell {
              packages =
                with pkgs;
                [
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
                ]
                ++ [
                  inputs.system-manager.packages.${system}.default
                ];

              # usually not needed in nixos, needed everywhere else
              LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
              LANG = "en_US.UTF-8";

              shellHook = ''
                ${pkgs.cowsay}/bin/cowsay "Welcome to ${name} devShell"
              '';
            };
          };
        };

      # old legacy flake (migrate to modules and perSystem)
      # also for nixosConfiguration, darwinConfigurations, etc
      flake =
        let
          system = "aarch64-linux";

          pkgs-unstable = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };

          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };
        in
        {
          systemConfigs =
            let
              context = {
                nix = {
                  cache = {
                    fqdn = "cache.nix.homelab.local";
                    publicKey = "cache.nix.homelab.local-1:Cdd9HwAEeDiKLkZQqnYs/J2co04AQ8PpfBrIVIYfpPA=";
                  };
                  cacheUpstream = {
                    fqdn = "cache.nixos.org";
                    publicKey = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
                    # fqdnSource = "cache.nixos.org";
                  };
                };
              };
            in
            {
              aarch64-linux = {
                raspianServer = inputs.system-manager.lib.makeSystemConfig {
                  extraSpecialArgs = {
                    pkgs = pkgs-unstable;
                    inherit
                      context
                      inputs
                      system
                      pkgs-stable
                      ;
                  };
                  modules = [
                    ./hosts/aarch64/raspianServer/default.nix
                  ];
                };
              };
            };
        };
    };
}
