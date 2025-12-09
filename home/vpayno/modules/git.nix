# home/vpayno/modules/git.nix
{
  pkgs,
  ...
}:
{
  programs = {
    git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        user = {
          mame = "Victor Payno";
          email = "vpayno@users.noreply.github.com";
        };
        init = {
          defaultBranch = "main";
        };
        alias = {
          tags = "tag --list | sort -V";
          ci = "commit";
          lc = "log ORIG_HEAD.. --stat --no-merges --color";
          llog = "log --date=local --color";
          lg-mc = "log --color=never --graph --pretty=format:'%h -%d %s (%cr) <%an>' --abbrev-commit --decorate";
          lg = "log --color=auto --graph --pretty=format:'%Cred%<(8)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an> [%ce] %Creset%C(cyan)[gpg: %G?]%Creset' --abbrev-commit --decorate";
          lt = "tag --list -n1";
          lu = "!git lg $(git tag --list -n0 | tail -n1)..";
          lh = "log -n 10 --color --graph --pretty=format:'%Cred%<(8)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --decorate";
          cl = "log --pretty=format:'- %s' --abbrev-commit --decorate";
          co = "checkout";
          ds = "diff --staged";
          di = "diff";
          fetchall = "fetch -v --all";
          st = "status";
          amend = "commit --amend";
          rhr = "!f() { echo git push origin +HEAD~$1:$2; git push origin +HEAD~$1:$2; }; f";
          br = "branch";
          ab = "branch -av";
          nb = "!f() { git pull ; git checkout -B $1 && git push -u origin $1; }; f";
          fb = "!f() { git pull ; git fetch origin $1 && git branch -f $1 origin/$1 && git checkout $1; }; f";
          rb = "!f() { { git checkout main || git checkout master; } && git branch -D $1; git push origin :$1; }; f";
          log-fancy = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(cyan)<%an>%Creset' --abbrev-commit --date=relative --decorate";
          log-me = "!UN=$(git config user.name)&& git log --author=\"$UN\" --pretty=format:'%h %cd %s' --date=short";
          log-nice = "log --graph --decorate --pretty=oneline --abbrev-commit";
        };
        push = {
          default = "matching";
          followTags = "true";
        };
        commit = {
          verbose = "true";
          gpgSign = "true";
        };
        "core" = {
          editor = "vim";
          # pager = "less | cat";
          logAllRefUpdates = "true";
          excludesfile = "~/.gitignore";
          whitespace = "trailing-space,space-before-tab";
          autocrlf = "false";
        };
        "apply" = {
          whitespace = "fix";
        };
        color = {
          ui = "true";
        };
      };
    };

    delta = {
      # sets core.pager
      enable = false; # https://github.com/dandavison/delta
      options = {
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-decoration-style = "none";
          file-style = "bold yellow ul";
        };
        features = "decorations";
        whitespace-error-style = "22 reverse";
      };
    };

    difftastic = {
      enable = true;
      git = {
        enable = false;
      };
      options = {
        background = "dark";
        color = "auto";
        display = "inline"; # "side-by-side-show-both" "side-by-side" "inline"
      };
    };

    diff-so-fancy = {
      enable = false;
    };

    diff-highlight = {
      enable = false;
      pagerOpts = [
        "--tabs=4"
        "-RFX"
      ];
    };

    patdiff = {
      enable = false;
    };

    gitui = {
      enable = true;
      theme = ''
        (
          selected_tab: Reset,
          command_fg: White,
          selection_bg: Blue,
          selection_fg: White,
          cmdbar_bg: Blue,
          cmdbar_extra_lines_bg: Blue,
          disabled_fg: DarkGray,
          diff_line_add: Green,
          diff_line_delete: Red,
          diff_file_added: LightGreen,
          diff_file_removed: LightRed,
          diff_file_moved: LightMagenta,
          diff_file_modified: Yellow,
          commit_hash: Magenta,
          commit_time: LightCyan,
          commit_author: Green,
          danger_fg: Red,
          push_gauge_bg: Blue,
          push_gauge_fg: Reset,
          tag_fg: LightMagenta,
          branch_fg: LightYellow,
        )
      '';
    };

    lazygit = {
      enable = true;
    };
  };

  home = {
    packages = with pkgs; [
      gitmux
    ];

    file = {
      ".gitmux.conf" = {
        enable = true;
        text = ''
          ---
          # :r! nix run nixpkgs\#gitmux -- -printcfg
          tmux:
              # The symbols section defines the symbols printed before specific elements
              # of Git status displayed in tmux status string.
              symbols:
                  # current branch name.
                  branch: "⎇ "
                  # Git SHA1 hash (in 'detached' state).
                  hashprefix: ":"
                  # 'ahead count' when local and remote branch diverged.
                  ahead: ↑·
                  # 'behind count' when local and remote branch diverged.
                  behind: ↓·
                  # count of files in the staging area.
                  staged: "● "
                  # count of files in conflicts.
                  conflict: "✖ "
                  # count of modified files.
                  modified: "✚ "
                  # count of untracked files.
                  untracked: "… "
                  # count of stash entries.
                  stashed: "⚑ "
                  # count of inserted lines (stats section).
                  insertions: Σ
                  # count of deleted lines (stats section).
                  deletions: Δ
                  # Shown when the working tree is clean.
                  clean: ✔

              # Styles are tmux format strings used to specify text colors and attributes
              # of Git status elements. See the STYLES section of tmux man page.
              # https://man7.org/linux/man-pages/man1/tmux.1.html#STYLES.
              styles:
                  # Clear previous style.
                  clear: "#[none]"
                  # Special tree state strings such as [rebase], [merge], etc.
                  state: "#[fg=red,bold]"
                  # Local branch name
                  branch: "#[fg=white,bold]"
                  # Remote branch name
                  remote: "#[fg=cyan]"
                  # 'divergence' counts
                  divergence: "#[fg=yellow]"
                  # 'staged' count
                  staged: "#[fg=green,bold]"
                  # 'conflicts' count
                  conflict: "#[fg=red,bold]"
                  # 'modified' count
                  modified: "#[fg=red,bold]"
                  # 'untracked' count
                  untracked: "#[fg=magenta,bold]"
                  # 'stash' count
                  stashed: "#[fg=cyan,bold]"
                  # 'insertions' count
                  insertions: "#[fg=green]"
                  # 'deletions' count
                  deletions: "#[fg=red]"
                  # 'clean' symbol
                  clean: "#[fg=green,bold]"

              # The layout section defines what components gitmux shows and the order in
              # which they appear on tmux status bar.
              #
              # Allowed components:
              #  - branch:            local branch name. Examples: `⎇ main`, `⎇ :345e7a0` or `[rebase]`
              #  - remote-branch:     remote branch name, for example: `origin/main`.
              #  - divergence:        divergence between local and remote branch, if any. Example: `↓·2↑·1`
              #  - remote:            alias for `remote-branch` followed by `divergence`, for example: `origin/main ↓·2↑·1`
              #  - flags:             symbols representing the working tree state, for example `✚ 1 ⚑ 1 … 2`
              #  - stats:             insertions/deletions (lines), for example`Σ56 Δ21`
              #  - some string `foo`: any other character of string is directly shown, for example `foo` or `|`
              layout: [branch, remote-branch, divergence, " - ", flags]

              # Additional configuration options.
              options:
                  # Maximum displayed length for local and remote branch names.
                  branch_max_len: 0
                  # Trim left, right or from the center of the branch (`right`, `left` or `center`).
                  branch_trim: right
                  # Character indicating whether and where a branch was truncated.
                  ellipsis: …
                  # Hides the clean flag
                  hide_clean: false
                  # Swaps order of behind & ahead upstream counts - "↓·1↑·1" -> "↑·1↓·1".
                  swap_divergence: false
                  # Add a space between behind & ahead upstream counts.
                  divergence_space: false
                  # Show flags symbols without counts.
                  flags_without_count: false
        '';
      };
    };
  };
}
