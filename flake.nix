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

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors = {
      url = "github:Misterio77/nix-colors";
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

               nix run .#update-host profileName

               nix run .#ci-check
               nix run .#ci-format

               nix run .#ci-actionlint
               nix run .#ci-ansiblelint
               nix run .#ci-markdownlint
               nix run .#ci-yamllint
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

            update-host = pkgs.writeShellApplication {
              name = "nixos-rebuild-host";
              runtimeInputs =
                with pkgs;
                [
                  coreutils
                  flock
                  jq
                  moreutils
                  openssh
                  rsync
                ]
                ++ [
                  inputs'.system-manager.packages.default
                  inputs'.home-manager.packages.default
                ];
              text = ''
                declare target="''${1:-}"
                declare profile="''${2:-raspianServer}"
                declare builder="''${3:-build1}"

                declare lock_file="/tmp/.sysmgr-update-host.lock";

                printf "\n"
                printf "Testing connection to build server: %s\n" "''${builder}"
                printf "\n"
                # shellcheck disable=SC2029
                ssh -t "''${builder}" echo "connected to ''${builder} server from $HOSTNAME"
                printf "\n"
                if [[ "''${target}" != "''${builder}" ]]; then
                  # shellcheck disable=SC2029
                  ssh -t "''${target}" ssh "''${builder}" echo "connected to ''${builder} server from \$HOSTNAME"
                  printf "\n"
                fi

                echo Running: flock --exclusive --verbose "$lock_file" system-manager --target-host root@"''${target}" switch --flake .#systemConfigs.aarch64-linux."''${profile}"
                printf "\n"
                time flock --exclusive --verbose "$lock_file" system-manager --target-host root@"''${target}" switch --flake .#systemConfigs.aarch64-linux."''${profile}"
                printf "\n"

                # shellcheck disable=SC2016,SC2028
                echo Running: ssh "''${target}" "/run/system-manager/sw/bin/nvd diff \$(find /nix/var/nix/profiles/system-manager-profiles/ -type l -regextype posix-extended -regex '^.*/system-manager-[0-9]+-link$' | sort -V | tail -n 2 | tr '\n' ' ')"
                # shellcheck disable=SC2046
                time ssh "''${target}" "/run/system-manager/sw/bin/nvd diff \$(find /nix/var/nix/profiles/system-manager-profiles/ -type l -regextype posix-extended -regex '^.*/system-manager-[0-9]+-link$' | sort -V | tail -n 2 | tr '\n' ' ')"
                printf "\n"

                echo Running: rsync --delete --progress --archive --hard-links --sparse --chown="''${USER}:''${USER}" --exclude={.venv,.devbox,node_modules,result*} ~/git_"''${USER}"/ansible-playbooks/ "''${USER}"@"''${target}":.config/home-manager/
                time rsync --delete --progress --archive --hard-links --sparse --chown="''${USER}:''${USER}" --exclude={.venv,.devbox,node_modules,result*} ~/git_"''${USER}"/ansible-playbooks/ "''${USER}"@"''${target}":.config/home-manager/
                printf "\n"

                echo Running: flock --exclusive --verbose "$lock_file" ssh "''${target}" "home-manager switch -b before-home-manager --flake ~''${USER}/.config/home-manager#''${USER}"
                printf "\n"
                time flock --exclusive --verbose "$lock_file" ssh "''${target}" "home-manager switch -b before-home-manager --flake ~''${USER}/.config/home-manager#''${USER}"
                printf "\n"

                # shellcheck disable=SC2016,SC2028
                echo Running: ssh "''${target}" "nvd diff \$(home-manager generations | head -n 2 | sed -r -e 's;^[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ : id [0-9]+ -> (/nix/store/[a-z0-9]+-home-manager-generation).*$;\1;g' | tac)"
                # shellcheck disable=SC2046
                time ssh "''${target}" "nvd diff \$(home-manager generations | head -n 2 | sed -r -e 's;^[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ : id [0-9]+ -> (/nix/store/[a-z0-9]+-home-manager-generation).*$;\1;g' | tac)"
                printf "\n"
              '';
            };

            ci-actionlint = pkgs.writeShellApplication {
              name = "ci-actionlint";

              runtimeInputs = with pkgs; [
                actionlint
              ];

              text = ''
                printf "Running ci-actionlint...\n"
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

            ci-ansiblelint = pkgs.writeShellApplication {
              name = "ci-ansiblelint";

              runtimeInputs = with pkgs; [
                ansible-lint
              ];

              text = ''
                printf "Running ansible-lint...\n"
                # ansible-lint wants "bad" yaml formatting, ignoring
                ansible-lint --skip-list=formatting ./playbooks/ ./tasks/ ./templates/ ./files/ ./tools/
              '';
            };

            ci-markdownlint = pkgs.writeShellApplication {
              name = "ci-markdownlint";

              runtimeInputs = with pkgs; [
                markdownlint-cli
              ];

              text = ''
                printf "Linting Markdown files...\n"
                markdownlint --ignore-path ${data.gitignoreConfig} .
                printf "\n"
              '';
            };

            ci-yamllint = pkgs.writeShellApplication {
              name = "ci-yamllint";

              runtimeInputs = with pkgs; [
                yamllint
              ];

              text = ''
                printf "Linting Yaml files...\n"
                yamllint --config-file ${data.yamlintConfig} ./.github/ ./playbooks/ ./tasks/ ./files/ ./tools/
                printf "\n"
              '';
            };

            ci-sysmgr-build = pkgs.writeShellApplication {
              name = "ci--sysmgrbuild";

              runtimeInputs = with pkgs; [
                coreutils
                jq
                nix-info
                tree
              ];

              text = ''
                 declare -a sm_names=( "''${@:-raspianServer}" )

                printf "System Info:\n"
                nix-info -m
                printf "\n"

                for sm_name in "''${sm_names[@]}"; do
                  printf "\n#\n# system-manager build --flake .#%s\n#\n\n" "$sm_name"
                  time system-manager build --flake ".#$sm_name"
                  printf "\n"

                  echo tree ./result
                  tree ./result
                  printf "\n"

                  echo jq . ./result/etcFiles/etcFiles.json
                  jq . ./result/etcFiles/etcFiles.json
                  printf "\n"

                  echo jq . ./result/services/services.json
                  jq . ./result/services/services.json
                  printf "\n"
                done
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

            update-host = {
              type = "app";
              program = "${pkgs.lib.getExe scripts.update-host}";
              meta = {
                description = "nixos-rebuild wrapper for updating hosts";
                name = "update-host-${version}";
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

            ci-ansiblelint = {
              type = "app";
              program = "${pkgs.lib.getExe scripts.ci-ansiblelint}";
              meta = metadata // {
                description = "CI Ansible Linter";
                pname = "ci-ansiblelint";
                inherit version;
                name = "${pname}-${version}";
                mainProgram = "ci-ansiblelint";
              };
            };

            ci-markdownlint = {
              type = "app";
              program = "${pkgs.lib.getExe scripts.ci-markdownlint}";
              meta = metadata // {
                description = "CI Markdown Linter";
                pname = "ci-markdownlint";
                inherit version;
                name = "${pname}-${version}";
                mainProgram = "ci-markdownlint";
              };
            };

            ci-yamllint = {
              type = "app";
              program = "${pkgs.lib.getExe scripts.ci-yamllint}";
              meta = metadata // {
                description = "CI Yaml Linter";
                pname = "ci-yamllint";
                inherit version;
                name = "${pname}-${version}";
                mainProgram = "ci-yamllint";
              };
            };

            ci-sysmgr-build = {
              type = "app";
              program = "${pkgs.lib.getExe scripts.ci-sysmgr-build}";
              meta = metadata // {
                description = "Build test all system-manager profiles";
                pname = "ci-sysmgr-build";
                inherit version;
                name = "${pname}-${version}";
                mainProgram = "ci-sysmgr-build";
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
          systemConfigs = {
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

          homeConfigurations = {
            "vpayno" = inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = pkgs-unstable;
              extraSpecialArgs = {
                inherit
                  context
                  inputs
                  system
                  pkgs-stable
                  ;
              };
              modules = [
                ./home/vpayno/headless.nix
              ];
            };
          };
        };
    };
}
