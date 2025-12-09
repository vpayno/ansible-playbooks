# home/vpayno/modules/shell.nix
{
  config,
  pkgs,
  ...
}:
let
  data = {
    btop = ../../../configs/btop.conf;
  };

  scripts = {
    ns-tui = pkgs.writeShellApplication {
      name = "ns-tui";
      runtimeInputs = with pkgs; [
        fzf
        nix-index
        nix-search-tv
      ];
      text = ''
        if [[ ! -f ''${HOME}/.cache/nix-index/files ]]; then
          nix-index
        fi
      ''
      + builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
      excludeShellChecks = [
        "SC2016"
      ];
    };

    ns-fzf = pkgs.writeShellApplication {
      name = "ns-fzf";
      runtimeInputs = with pkgs; [
        fzf
        nix-search-tv
      ];
      text = ''
        nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history
      '';
    };
  };
in
{
  home = {
    file = {
      ".config/btop/btop.conf" = {
        enable = true;
        source = data.btop;
      };
    };

    packages =
      with pkgs;
      [
        devbox
      ]
      ++ (with scripts; [
        ns-fzf
        ns-tui
      ]);
  };

  programs = {
    bash = {
      enable = true;
      bashrcExtra = ''
        # ~/bashrc - interactive
        # programs.bash.bashrcExtra

        # colors
        FG_RED="\[\033[0;31m\]"
        FG_GREEN="\[\033[0;32m\]"
        FG_YELLOW="\[\033[0;33m\]"
        FG_BLUE="\[\033[0;34m\]"
        FG_PURPLE="\[\033[0;35m\]"
        FG_CYAN="\[\033[0;36m\]"
        FG_GRAY="\[\033[0;37m\]"
        FG_LIGHT_RED="\[\033[1;31m\]"
        FG_LIGHT_GREEN="\[\033[1;32m\]"
        FG_LIGHT_YELLOW="\[\033[1;33m\]"
        FG_LIGHT_BLUE="\[\033[1;34m\]"
        FG_LIGHT_PURPLE="\[\033[1;35m\]"
        FG_LIGHT_CYAN="\[\033[1;36m\]"
        FG_WHITE="\[\033[1;37m\]"
        RESET="\[\033[0m\]"

        # helper functions
        declare -f -x __prompt_git
        declare -f -x __prompt_uptime
        declare -f -x __prompt_nix_shell
        declare -f -x __prompt_smos_version
        declare -f -x __prompt_venv
        declare -f -x __prompt_user_host
        declare -f -x __prompt_job_count
        declare -f -x __prompt_unit_failed_count

        __prompt_git() {
          source ${config.programs.git.package}/share/git/contrib/completion/git-prompt.sh
          printf "%s" " $(__git_ps1 '(%s)')"
        } # __prompt_git()

        __prompt_uptime() {
          local -r MY_TZ="America/Los_Angeles"
          local uptime_args

          # procps under darwin is missing uptime with --pretty
          if uptime --help |& grep -q pretty; then
            uptime_args+="--pretty "
          fi

          echo "UTC: $(TZ='UTC' date +%Y-%m-%d)$(TZ='UTC' uptime)"

          # shellcheck disable=SC2086
          echo "$(TZ="''${MY_TZ}" date '+%Z'): $(TZ="''${MY_TZ}" date '+%Y-%m-%d %H:%M:%S') $(uptime ''${uptime_args})"
        } # __prompt_uptime()

        __prompt_nix_shell() {
          if [[ -n ''${IN_NIX_SHELL} ]]; then
            printf "%s" " (nix-develop)"
          fi
        } # __prompt_nix_shell()

        __prompt_smos_version() {
          local -i SM_GEN
          local NIXOS_LABEL
          local SM_SYSTEM

          if [[ -d /nix/var/nix/profiles/system-manager-profiles/system-manager ]]; then
            SM_GEN="$(readlink /nix/var/nix/profiles/system-manager-profiles/system-manager | sed -r -e 's/^system-manager-([0-9]+)-link$/\1/'g)"
            SM_SYSTEM="aarch64-linux"
            source /etc/os-release
            printf "%s" "Nix System: ''${SM_SYSTEM} | SysMgr Gen: ''${SM_GEN} | OS Label: ''${ID^} ''${VERSION}"
          fi
        } # __prompt_smos_version()

        __prompt_venv() {
          if [[ -n ''${VIRTUAL_ENV} ]]; then
            printf "%s" " (virtualenv: $(basename "$VIRTUAL_ENV"))"
          fi
        } # __prompt_venv()

        __prompt_user_host() {
            printf "%s" "$USER@$HOSTNAME"
        } # __prompt_user_host()

        __prompt_job_count() {
          local -i bg_job_count="$(jobs | grep -c -v -E "(Done|Exit)")"

          [[ ''${bg_job_count: -0} -gt 0 ]] && printf "%s" " (jobs: ''${bg_job_count: -0})"
        }  # __prompt_job_count()

        __prompt_unit_failed_count() {
          local -i bg_count="$(systemctl list-units --failed --output=json | jq '. | length')"

          [[ ''${bg_count: -0} -gt 0 ]] && printf "%s" " (failed units: ''${bg_count: -0})"
        }  # __prompt_unit_failed_count()

        declare __PS1_STATUS_BAR=""

        __PS1_STATUS_BAR+="$FG_LIGHT_YELLOW\$(__prompt_git)"
        __PS1_STATUS_BAR+="$FG_LIGHT_YELLOW\$(__prompt_nix_shell)"
        __PS1_STATUS_BAR+="$FG_LIGHT_YELLOW\$(__prompt_venv)"
        __PS1_STATUS_BAR+="$FG_LIGHT_RED\$(__prompt_job_count)"
        __PS1_STATUS_BAR+="$FG_LIGHT_RED\$(__prompt_unit_failed_count)"
        __PS1_STATUS_BAR+="$RESET"

        PROMPT_COMMAND=__prompt_command

        __prompt_command() {
          local -i EC="$?"
          if [[ $EC -eq 0 ]]; then
            EXIT="$FG_LIGHT_GREEN$EC ✓$RESET"
          else
            EXIT="$FG_LIGHT_RED$EC ✗$RESET"
          fi

          # shell prompt
          read -r -d "" PS1 <<EOF
        \r
        $FG_YELLOW\$(__prompt_uptime)$RESET

        $FG_LIGHT_CYAN\$(__prompt_smos_version)$RESET

        $EXIT $FG_LIGHT_GREEN\$(__prompt_user_host) $FG_LIGHT_BLUE\w $__PS1_STATUS_BAR \$(if [[ \$USER != "root" ]]; then echo -en "$FG_LIGHT_GREEN"; else echo -en "$FG_LIGHT_RED"; fi)
        \$ $RESET
        EOF
          export PS1
        }
      '';
      enableCompletion = true;
      historyControl = [ "ignoreboth" ]; # "erasedups", "ignoredups", "ignorespace", "ignoreboth"
      initExtra = ''
        # ~/.bashrc - interactive shell
        # programs.bash.initExtra
      '';
      logoutExtra = ''
        # ~/.bash_logout
        # programs.bash.logoutExtra
      '';
      profileExtra = ''
        # ~/.profile - login shell
        # programs.bash.profileExtra
      '';
      # https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#:~:text=4.3.2%20The%20Shopt%20Builtin
      shellOptions = [
        "checkjobs"
        "checkwinsize"
        "extglob"
        "globstar"
        "histappend"
      ];
    };

    bashmount = {
      enable = true;
    };

    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batgrep
        batwatch
      ];
      syntaxes = {
        gleam = {
          src = pkgs.fetchFromGitHub {
            owner = "molnarmark";
            repo = "sublime-gleam";
            rev = "ff9638511e05b0aca236d63071c621977cffce38";
            hash = "sha256-94moZz9r5cMVPWTyzGlbpu9p2p/5Js7/KV6V4Etqvbo=";
          };
          file = "syntax/gleam.sublime-syntax";
        };
      };
      themes = {
        dracula = {
          src = pkgs.fetchFromGitHub {
            owner = "dracula";
            repo = "sublime"; # Bat uses sublime syntax for its themes
            rev = "456d3289827964a6cb503a3b0a6448f4326f291b";
            sha256 = "sha256-8mCovVSrBjtFi5q+XQdqAaqOt3Q+Fo29eIDwECOViro=";
          };
          file = "Dracula.tmTheme";
        };
      };
      config = {
        map-syntax = [
          "*.conf:INI"
          ".*ignore:Git Ignore"
        ];
        pager = "less -FR";
        tabs = "4";
        theme = "auto:system"; # solorized auto:system
        theme-dark = "gruvbox-dark";
        theme-light = "gruvbox-light";
      };
    };

    broot = {
      enable = true;
      enableBashIntegration = true;
    };

    dircolors = {
      enable = true;
      enableBashIntegration = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      config = {
        global = {
          warn_timeout = "0";
        };
      };
      nix-direnv = {
        enable = true;
      };
    };

    carapace = {
      enable = true;
      enableBashIntegration = true;
    };

    eza = {
      enable = true;
      enableBashIntegration = true;
      colors = "auto";
      icons = "never";
      git = true;
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      colors = {
        bg = "#1e1e1e";
        "bg+" = "#1e1e1e";
        fg = "#d4d4d4";
        "fg+" = "#d4d4d4";
      };
    };

    jq = {
      enable = true;
      colors = {
        arrays = "1;37";
        false = "0;37";
        null = "1;30";
        numbers = "0;37";
        objectKeys = "1;34";
        objects = "1;37";
        strings = "0;32";
        true = "0;37";
      };
    };

    jqp = {
      enable = true;
      settings = {
      };
    };
  };
}
