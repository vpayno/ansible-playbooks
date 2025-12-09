# home/vpayno/modules/tmux.nix
{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs = {
    fzf = {
      tmux = {
        enableShellIntegration = true;
        shellIntegrationOptions = [ ];
      };
    };

    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      extraConfig = ''
        # programs.tmux.extraConfig

        set-option -g set-titles on
        set-option -g set-titles-string '[#H #S:#I] #W:#P | #T'
        set-window-option -g automatic-rename off

        # xterm
        setw -g xterm-keys on
        set -g terminal-overrides 'xterm*:smcup@:rmcup@'

        # Misc. key bindings
        bind        : command-prompt
        bind        ? list-keys
        bind        i display-message
        bind        t clock-mode
        bind        '~' show-messages
        # bind        R source-file ''${HOME}/.tmux.conf \; display 'Reloaded ~/.tmux.conf'
        bind        T clear-history

        # Session key bindings
        bind        s choose-session
        # bind       $ command-prompt -I #S "rename-session '%%'"

        # Client key bindings
        bind        C-z suspend-client
        bind        ( switch-client -p
        bind        ) switch-client -n
        bind        D choose-client
        bind        L switch-client -l
        bind        d detach-client
        bind        r refresh-client

        # Buffer key bindings
        bind        [ copy-mode
        bind        PPage copy-mode -u
        bind        '#' list-buffers
        bind        - delete-buffer
        bind        = choose-buffer
        bind        ] paste-buffer
        bind        C-c run "tmux save-buffer - | xclip -i -sel clipboard"
        bind        C-v run "tmux set-buffer \"$(xclip -o -sel clipboard)\" \; tmux paste-buffer"

        # Layout key bindings
        bind        Space next-layout
        bind        M-1 select-layout even-horizontal
        bind        M-2 select-layout even-vertical
        bind        M-3 select-layout main-horizontal
        bind        M-4 select-layout main-vertical
        bind        M-5 select-layout tiled

        # Window key bindings
        bind        & confirm-before -p "kill-window #W? (y/n)" kill-window
        bind        "'" command-prompt -p index "select-window -t ':%%'"
        # bind       ',' command-prompt -I #W "rename-window '%%'"
        bind        . command-prompt "move-window -t '%%'"
        bind        f command-prompt "find-window '%%'"
        # bind       f command-prompt -p "Go To Window:" "find-window -N %%"
        # bind       | split-window -v
        # bind       - split-window -h
        bind        '"' split-window -c "#{pane_current_path}"
        bind        % split-window -h -c "#{pane_current_path}"
        bind        c new-window
        bind        l last-window
        bind        F11 previous-window
        bind        F12 next-window
        bind -n     F11 previous-window
        bind -n     F12 next-window
        bind        n next-window
        bind        p previous-window
        bind        w choose-window
        bind        0 select-window -t :0
        bind        1 select-window -t :1
        bind        2 select-window -t :2
        bind        3 select-window -t :3
        bind        4 select-window -t :4
        bind        5 select-window -t :5
        bind        6 select-window -t :6
        bind        7 select-window -t :7
        bind        8 select-window -t :8
        bind        9 select-window -t :9
        bind        M-n next-window -a
        bind        M-o rotate-window -D
        bind        M-p previous-window -a
        bind        S set-window-option synchronize-panes

        # Pane key bindings
        bind        q display-panes
        bind        '!' break-pane
        # bind       ';' last-pane
        bind        F9 select-pane -t :.-
        bind        F10 select-pane -t :.+
        bind -n     F9 select-pane -t :.-
        bind -n     F10 select-pane -t :.+
        bind        x confirm-before -p "kill-pane #P? (y/n)" kill-pane

        # Usage: swap-pane [-dDUZ] [-s src-pane] [-t dst-pane]
        # bind        { swap-pane -U
        # bind        } swap-pane -D

        # bind -r j select-pane -U
        # bind -r k select-pane -D
        # bind -r h select-pane -L
        # bind -r l select-pane -R
        bind -r Up    select-pane -U
        bind -r Down  select-pane -D
        bind -r Left  select-pane -L
        bind -r Right select-pane -R
        bind -r M-Up    resize-pane -U 5
        bind -r M-Down  resize-pane -D 5
        bind -r M-Left  resize-pane -L 5
        bind -r M-Right resize-pane -R 5
        bind -r C-Up    resize-pane -U
        bind -r C-Down  resize-pane -D
        bind -r C-Left  resize-pane -L
        bind -r C-Right resize-pane -R

        # Mouse stuff - not supported in v2.1
        # setw -g mode-mouse off
        # set -g mouse-select-pane off
        # set -g mouse-resize-pane off
        # set -g mouse-select-window off

        # Colors
        # set -g status-fg black
        set -g status-bg cyan
        set -g status-style "bg=colour220,fg=colour0"
        set-option -g status-position bottom

        # setw -g window-status-fg cyan
        # setw -g window-status-bg default
        # setw -g window-status-attr dim
        # setw -g window-status-current-fg white
        # setw -g window-status-current-bg red
        # setw -g window-status-current-attr bright

        # set -g pane-border-fg=green
        # set -g pane-border-bg=black
        # set -g pane-active-border-fg=white
        # set -g pane-active-border-bg=black
        # set pane-style "bg=black,fg=red"
        # set pane-style "bg=black fg=red"

        # set -g message-fg white
        # set -g message-bg black
        # set -g message-attr bright

        # status bar
        # #H - fqdn
        # #h - short hostname
        # #F - current window flag
        # #I - current window index
        # #P - current pane index
        # #S - current session name
        # #T - current window title
        # #W - current window name
        # ## - literal #
        # #(shell command)
        # #[attributes] - attribute or color change

        # set-option -g status-utf8 on
        # set-window-option -g utf8 on
        set -g status-justify centre
        set -g status-interval 1

        # status bar - left panel
        set -g status-left-length 50
        # set -g status-left '#h | '

        # status bar - middle panel

        # status bar - right panel
        set -g status-right "%a %b %e %Y %H:%M:%S"
        # set -g status-right 'CPU:#{cpu_percentage} | %a %b %e %Y %H:%M:%S'

        # set -g status-right '#{cpu_bg_color} CPU: #{cpu_icon} #{cpu_percentage} | %a %h-%d %H:%M '
        # set -g status-right '#{battery_status_bg} Batt: #{battery_icon} #{battery_percentage} #{battery_remain} | %a %h-%d %H:%M '
        set -g status-right-length 50
        # set -g status-right "#{cpu_bg_color} CPU: #{cpu_icon} #{cpu_percentage} | %a %b %e %Y %H:%M:%S"
        # set -g status-right "CPU:#{cpu_percentage} | Batt:#{battery_percentage}:#{battery_remain} | %a %b %e %Y %H:%M:%S"
        # set -g status-right "CPU:#{cpu_percentage} | %a %b %e %Y %H:%M:%S"
        # set -g status-right "(tmux-mem-cpu-load --colors 2) # %a %b %e %Y %H:%M:%S"
        # set -g status-right "#S #[fg=green,bg=black]#(tmux-mem-cpu-load --colors 2)#[default]"

        setw -g monitor-activity off
        set -g visual-activity on

        # Pop a pane into it's own window.
        # unbind F5
        # bind -n F5 new-window -d -n tmp \; swap-pane -s tmp.1 \; select-window -t tmp

        # Attach a pane to the previous window.
        # unbind F6
        # bind -n F6 last-window \; swap-pane -s tmp.1 \; kill-window -t tmp

        # Switch sessions
        bind -n F7 switch-client -p
        bind -n F8 switch-client -n

        # Kill current session
        bind        * confirm-before -p "kill-session #S? (y/n)" kill-session

        # Toggled logging to ~/#h-RIM_MOP-main-1-vpayno@vpayno:~/tk/pcr-rim1304-mop-prod.log
        # Toggled logging to ~/#h-RIM_MOP-main-1-%83.log
        # Toggled logging to ~/vpayno.dev.local-RIM_MOP-main-1_%83.log
        # #h - short hostname
        # #F - window flag
        # #I - window index
        # #D - pane uniq id
        # #P - pane index
        # #S - session name
        # #T - pane title
        # #W - window name
        #bind -n F2 pipe-pane -o "cat >>~/#H-#S-#W-#P_#D.log" \; display "Toggled logging to ~/#H-#S-#W-#P_#D.log"
        bind H pipe-pane -o "cat | tee ''${HOME}/tmux-'#{session_name}-#{window_name}-#{pane_name}-%Y%m%dT%H%M%S.log' | ansifilter > ''${HOME}/tmux-'#{session_name}-#{window_name}-#{pane_name}-%Y%m%dT%H%M%S.txt'" \; display-message "Toggled logging to '#{host}:~/tmux-#{session_name}-#{window_name}-#{pane_name}-%Y%m%dT%H%M%S.{log,txt}'"
        bind h pipe-pane \; display-message "Ended logging to '#{host}:~/tmux-#{session_name}-#{window_name}-#{pane_name}-%Y%m%dT%H%M%S.{log,txt}'"

        # bind -n F3 synchronize-panes

        # Send command to all windows
        bind C-e command-prompt -p "session?,message?" "run-shell \"tmux list-windows -t %1 \| cut -d: -f1\|xargs -I\{\} tmux send-keys -t %1:\{\} %2\""

        # bind-key -n PPage if-shell -F "#{alternate_on}" "send-keys PPage" "copy-mode -e -u"
        # unbind-key -n PPage

        # bind f command-prompt -p "content:" "run-shell \"''${HOME}/bin/tmux_goto_window content '#{session_id}' '%%'\""
        # bind g command-prompt -p "window:" "run-shell \"''${HOME}/bin/tmux_goto_window window '#{session_id}' '%%'\""
        bind w run-shell 'tmux choose-tree -Nwf"##{==:##{session_name},#{session_name}}"'

        # bind z resize-pane -Z\; if-shell -F "#{window_zoomed_flag}" "set-window-option synchronize-panes off" "set-window-option synchronize-panes on"
        bind z resize-pane -Z

        # set -g default-command ${pkgs.lib.getExe config.programs.bash.package}  # new panes are not login shells
        set -g default-command "" # new panes are login shells - breaks PATH on MacOS
        # set -g default-shell ${pkgs.lib.getExe config.programs.bash.package} # programs.tmux.shell
      '';
      escapeTime = 1;
      focusEvents = false;
      historyLimit = 10000;
      keyMode = "vi"; # emacs
      mouse = false;
      newSession = false;
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.tmux-fzf;
          extraConfig = ''
            # tmux-fzf plugin  for quick movement along windows
            # Alt+o keybinding to open fzf list of open windows
            bind G run-shell -b "${pkgs.tmuxPlugins.tmux-fzf}/share/tmux-plugins/tmux-fzf/scripts/window.sh switch"
            TMUX_FZF_ORDER="window|session|pane|command|keybinding|clipboard|process"
            TMUX_FZF_WINDOW_FORMAT="#{pane_current_command} | #{pane_current_path}"
            TMUX_FZF_PANE_FORMAT="#{pane_current_command} | #{pane_current_path}"
            TMUX_FZF_PREVIEW=0
          '';
        }
        {
          plugin = tmuxPlugins.cpu;
          extraConfig = ''
            set -g status-left "#h | CPU:#{cpu_percentage}"
          '';
        }
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
          '';
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '60' # minutes
          '';
        }
      ];
      prefix = lib.mkDefault "C-b";
      secureSocket = false; # true doesn't survive user logout
      terminal = "screen-256color";
      shell = "${pkgs.lib.getExe config.programs.bash.package}";
    };
  };
}
