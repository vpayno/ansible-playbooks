---
runme:
  shell: bash
  terminalRows: 80
---

# ansible-playbooks

[![actionlint](https://github.com/vpayno/ansible-playbooks/actions/workflows/gh-actions.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/gh-actions.yaml)
[![ansible](https://github.com/vpayno/ansible-playbooks/actions/workflows/ansible.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/ansible.yaml)
[![json](https://github.com/vpayno/ansible-playbooks/actions/workflows/json.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/json.yaml)
[![markdown](https://github.com/vpayno/ansible-playbooks/actions/workflows/markdown.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/markdown.yaml)
[![spellcheck](https://github.com/vpayno/ansible-playbooks/actions/workflows/spellcheck.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/spellcheck.yaml)
[![woke](https://github.com/vpayno/ansible-playbooks/actions/workflows/woke.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/woke.yaml)
[![yaml](https://github.com/vpayno/ansible-playbooks/actions/workflows/yaml.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/yaml.yaml)

Ansible playbook for my home lab.

## Nix, system-manager & home-manager

Tired of Ansible+Apt+ManualHacks when managing anything other than `NixOS`.

Also tired of Dev Containers so switching to using `nix develop`/`devbox shell`
for the development environment.

Using `system-manager` to handle "OS/System" configurations and `home-manager`
to manage "User" configurations.

### Runme Playbooks

Show the system-manager and home-manager latest profile diffs.

```bash { name=nix-nvd-diff-latest }
declare target_host=rpi11

echo Running: \ssh "${target_host}" '/run/system-manager/sw/bin/nvd diff $(find /nix/var/nix/profiles/system-manager-profiles/ -type l -regextype posix-extended -regex '^.*/system-manager-[0-9]+-link$' | sort -V | tail -n 2 | tr "\n" " ")'
time \ssh "${target_host}" '/run/system-manager/sw/bin/nvd diff $(find /nix/var/nix/profiles/system-manager-profiles/ -type l -regextype posix-extended -regex '^.*/system-manager-[0-9]+-link$' | sort -V | tail -n 2 | tr "\n" " ")'
printf "\n"

echo Running: \ssh "${target_host}" "nvd diff \$(home-manager generations | head -n 2 | sed -r -e 's;^[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ : id [0-9]+ -> (/nix/store/[a-z0-9]+-home-manager-generation).*$;\1;g' | tac)"
time \ssh "${target_host}" "nvd diff \$(home-manager generations | head -n 2 | sed -r -e 's;^[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ : id [0-9]+ -> (/nix/store/[a-z0-9]+-home-manager-generation).*$;\1;g' | tac)"
```

Update both system-manager and home-manager on remote host.

```bash { name=nix-sm-hm-update-push-repo-and-update }
declare target_host=rpi11

echo Running: \rsync --delete --progress --archive --hard-links --sparse --chown=root:root --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ root@"${target_host}":.config/system-manager/
time \rsync --delete --progress --archive --hard-links --sparse --chown=root:root --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ root@"${target_host}":.config/system-manager/
printf "\n"

echo Running: \ssh "root@${target_host}" "cd ~/.config/system-manager && /nix/var/nix/profiles/default/bin/nix run github:numtide/system-manager -- switch --flake .#raspianServer"
printf "\n"

if time \ssh "root@${target_host}" "cd ~/.config/system-manager && /nix/var/nix/profiles/default/bin/nix run github:numtide/system-manager -- switch --flake .#raspianServer"; then
    printf "INFO: system-manager ran sucessfully!\n"
    printf "\n"
    time \ssh "${target_host}" '/run/system-manager/sw/bin/nvd diff $(find /nix/var/nix/profiles/system-manager-profiles/ -type l -regextype posix-extended -regex '^.*/system-manager-[0-9]+-link$' | sort -V | tail -n 2 | tr "\n" " ")'
else
    printf "ERROR: system-manager failed!\n"
fi

echo Running: \rsync --delete --progress --archive --hard-links --sparse --chown=vpayno:vpayno --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ vpayno@"${target_host}":.config/home-manager/
time \rsync --delete --progress --archive --hard-links --sparse --chown=vpayno:vpayno --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ vpayno@"${target_host}":.config/home-manager/
printf "\n"

echo Running: \ssh "vpayno@${target_host}" "home-manager -b before-home-manager switch --flake ~/.config/home-manager#vpayno"
printf "\n"

if time \ssh "vpayno@${target_host}" "home-manager -b before-home-manager switch --flake ~/.config/home-manager#vpayno"; then
    printf "INFO: home-manager ran sucessfully!\n"
    printf "\n"
    time \ssh "${target_host}" "nvd diff \$(home-manager generations | head -n 2 | sed -r -e 's;^[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ : id [0-9]+ -> (/nix/store/[a-z0-9]+-home-manager-generation).*$;\1;g' | tac)"
else
    printf "ERROR: home-manager failed!\n"
fi
```

Sync system-manager repo to remote host.

```bash { name=nix-sm-update-push-repo }
declare target_host=rpi11

echo Running: \rsync --delete --progress --archive --hard-links --sparse --chown=root:root --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ root@"${target_host}":.config/system-manager/
time \rsync --delete --progress --archive --hard-links --sparse --chown=root:root --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ root@"${target_host}":.config/system-manager/
printf "\n"
```

Sync repo and run system-manager on remote host.

```bash { name=nix-sm-update-push-repo-and-update }
declare target_host=rpi11

echo Running: \rsync --delete --progress --archive --hard-links --sparse --chown=root:root --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ root@"${target_host}":.config/system-manager/
time \rsync --delete --progress --archive --hard-links --sparse --chown=root:root --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ root@"${target_host}":.config/system-manager/
printf "\n"

echo Running: \ssh "root@${target_host}" "cd ~/.config/system-manager && /nix/var/nix/profiles/default/bin/nix run github:numtide/system-manager -- switch --flake .#raspianServer"
printf "\n"

if time \ssh "root@${target_host}" "cd ~/.config/system-manager && /nix/var/nix/profiles/default/bin/nix run github:numtide/system-manager -- switch --flake .#raspianServer"; then
    printf "INFO: system-manager ran sucessfully!\n"
    printf "\n"
    time \ssh "${target_host}" '/run/system-manager/sw/bin/nvd diff $(find /nix/var/nix/profiles/system-manager-profiles/ -type l -regextype posix-extended -regex '^.*/system-manager-[0-9]+-link$' | sort -V | tail -n 2 | tr "\n" " ")'
else
    printf "ERROR: system-manager failed!\n"
fi
```

```bash { name=nix-sm-update-from-local-to-remote }
declare target_host=rpi11

echo Running: system-manager --target-host "root@${target_host}" switch --flake .#systemConfigs.aarch64-linux.raspianServer
printf "\n"

if time system-manager --target-host "root@${target_host}" switch --flake .#systemConfigs.aarch64-linux.raspianServer; then
    printf "INFO: system-manager ran sucessfully!\n"
    printf "\n"
    time \ssh "${target_host}" '/run/system-manager/sw/bin/nvd diff $(find /nix/var/nix/profiles/system-manager-profiles/ -type l -regextype posix-extended -regex '^.*/system-manager-[0-9]+-link$' | sort -V | tail -n 2 | tr "\n" " ")'
else
    printf "ERROR: system-manager failed!\n"
fi
```

Using github.com as the repo source:

- To specify a tag, use `?ref=refs/tags/yyyymmdd.serial.patch#raspianServer`.
- To specify a branch, use `?ref=refs/heads/BRANCH_NAME#raspianServer`.

```bash { name=nix-sm-update-from-github }
declare target_host=rpi11

echo Running: system-manager --target-host "root@${target_host}" switch --flake github.com:vpayno/ansible-playbooks#systemConfigs.aarch64-linux.raspianServer
printf "\n"

if time system-manager --target-host "root@${target_host}" switch --flake github.com:vpayno/ansible-playbooks#systemConfigs.aarch64-linux.raspianServer; then
    printf "INFO: system-manager ran sucessfully!\n"
    printf "\n"
    time \ssh "${target_host}" '/run/system-manager/sw/bin/nvd diff $(find /nix/var/nix/profiles/system-manager-profiles/ -type l -regextype posix-extended -regex '^.*/system-manager-[0-9]+-link$' | sort -V | tail -n 2 | tr "\n" " ")'
else
    printf "ERROR: system-manager failed!\n"
fi
```

### Home-Manager

Push home-manager repo to remote host.

```bash { name=nix-hm-update-push-repo }
declare target_host=rpi11

echo Running: \rsync --delete --progress --archive --hard-links --sparse --chown=vpayno:vpayno --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ vpayno@"${target_host}":.config/home-manager/
time \rsync --delete --progress --archive --hard-links --sparse --chown=vpayno:vpayno --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ vpayno@"${target_host}":.config/home-manager/
printf "\n"
```

Push repo to remote host and update home-manager configuration from remote host.

```bash { name=nix-hm-update-push-repo-and-update }
declare target_host=rpi11

echo Running: \rsync --delete --progress --archive --hard-links --sparse --chown=vpayno:vpayno --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ vpayno@"${target_host}":.config/home-manager/
time \rsync --delete --progress --archive --hard-links --sparse --chown=vpayno:vpayno --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ vpayno@"${target_host}":.config/home-manager/
printf "\n"

echo Running: \ssh "vpayno@${target_host}" "home-manager -b before-home-manager switch --flake ~/.config/home-manager#vpayno"
printf "\n"

if time \ssh "vpayno@${target_host}" "home-manager -b before-home-manager switch --flake ~/.config/home-manager#vpayno"; then
    printf "INFO: home-manager ran sucessfully!\n"
    printf "\n"
    time \ssh "${target_host}" "nvd diff \$(home-manager generations | head -n 2 | sed -r -e 's;^[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ : id [0-9]+ -> (/nix/store/[a-z0-9]+-home-manager-generation).*$;\1;g' | tac)"
else
    printf "ERROR: home-manager failed!\n"
fi
```

Using github.com as the repo source:

- To specify a tag, use `?ref=refs/tags/yyyymmdd.serial.patch#vpayno`.
- To specify a branch, use `?ref=refs/heads/BRANCH_NAME#vpayno`.

```bash { name=nix-hm-update-from-github }
declare target_host=rpi11

echo Running: \ssh "vpayno@${target_host}" "home-manager -b before-home-manager switch --flake github.com:vpayno/ansible-playbooks#vpayno"
printf "\n"

if time \ssh "vpayno@${target_host}" "home-manager -b before-home-manager switch --flake github.com:vpayno/ansible-playbooks#vpayno"; then
    printf "INFO: home-manager ran sucessfully!\n"
    printf "\n"
    time \ssh "${target_host}" "nvd diff \$(home-manager generations | head -n 2 | sed -r -e 's;^[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ : id [0-9]+ -> (/nix/store/[a-z0-9]+-home-manager-generation).*$;\1;g' | tac)"
else
    printf "ERROR: home-manager failed!\n"
fi
```

### Runme Playbooks - HomeLab

The `system` value has to match on both hosts if you use the shortcut
`.#raspianServer`. To target a different architecture, specify the full path:
`systemConfigs.aarch64-linux.raspianServer`.

```bash { name=nix-sm-hm-update-rpi }
export target_host=rpi11

echo Running: \rsync --delete --progress --archive --hard-links --sparse --chown=root:root --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ root@"${target_host}":.config/system-manager/
time \rsync --delete --progress --archive --hard-links --sparse --chown=root:root --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ root@"${target_host}":.config/system-manager/
printf "\n"

echo Running: \ssh "root@${target_host}" "cd ~/.config/system-manager && /nix/var/nix/profiles/default/bin/nix run github:numtide/system-manager -- switch --flake .#raspianServer"
printf "\n"

if time \ssh "root@${target_host}" "cd ~/.config/system-manager && /nix/var/nix/profiles/default/bin/nix run github:numtide/system-manager -- switch --flake .#raspianServer"; then
    printf "INFO: system-manager ran sucessfully!\n"
    printf "\n"
    time \ssh "${target_host}" '/run/system-manager/sw/bin/nvd diff $(find /nix/var/nix/profiles/system-manager-profiles/ -type l -regextype posix-extended -regex '^.*/system-manager-[0-9]+-link$' | sort -V | tail -n 2 | tr "\n" " ")'
else
    printf "ERROR: system-manager failed!\n"
fi

echo Running: \rsync --delete --progress --archive --hard-links --sparse --chown=vpayno:vpayno --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ vpayno@"${target_host}":.config/home-manager/
time \rsync --delete --progress --archive --hard-links --sparse --chown=vpayno:vpayno --exclude={.venv,.devbox,node_modules,result*} ~/git_vpayno/ansible-playbooks/ vpayno@"${target_host}":.config/home-manager/
printf "\n"

echo Running: \ssh "vpayno@${target_host}" "home-manager -b before-home-manager switch --flake ~/.config/home-manager#vpayno"
printf "\n"

if time \ssh "vpayno@${target_host}" "home-manager -b before-home-manager switch --flake ~/.config/home-manager#vpayno"; then
    printf "INFO: home-manager ran sucessfully!\n"
    printf "\n"
    time \ssh "${target_host}" "nvd diff \$(home-manager generations | head -n 2 | sed -r -e 's;^[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+ : id [0-9]+ -> (/nix/store/[a-z0-9]+-home-manager-generation).*$;\1;g' | tac)"
else
    printf "ERROR: home-manager failed!\n"
fi
```

## RunMe Playbook

This and other read-me files in this repo are RunMe Playbooks.

Use this playbook step/task to update the [RunMe](https://runme.dev) CLI.

If you don't have RunMe installed, you'll need to copy/paste the command. :)

```bash { background=false category=runme closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=setup-runme-install promptEnv=true terminalRows=10 }
go install github.com/stateful/runme/v3@v3
```

You can also install `runme` with the command `devbox add runme` and run it with
`devbox run runme`.

### Setup command auto-completion

```bash { background=false category=runme closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=setup-runme-autocompletion promptEnv=true terminalRows=10 }
if [[ -d ~/.bash_libs.d ]]; then
    runme completion bash > ~/.bash_libs.d/19.00-completion-runme.sh
    printf "Don't forget to run: %s\n" "source ~/.bash_libs.d/19.00-completion-runme.sh"
else
    runme completion bash >> ~/.bash_completion_runmme.sh
    printf "%s\n" "source ~/.bash_completion_runmme.sh" >> ~/.bashrc
    printf "Don't forget to run: %s\n" "source ~/.bashrc"
fi
```

### Install Playbook dependencies

```bash { background=false category=runme closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=setup-runme-deps promptEnv=true terminalRows=10 }
go install github.com/keewek/ansible-pretty-print@latest
go install github.com/charmbracelet/gum@latest
go install github.com/mikefarah/yq/v4@latest
go install github.com/charmbracelet/glow@latest
```

These commands are now deprecated in favor of using `devbox` instead.

## Dev Container

This project has a dev-container to make it easier to run ansible commands from
any workstation, it just needs [Docker](https://docs.docker.com/engine/install/)
and the [Dev Container CLI](https://github.com/devcontainers/cli) installed to
get setup to run ansible playbooks.

Note: deprecated in favor of using `devbox` instead.

## Devbox

Benefits over dev containers?

- Tooling is less complicated.
- It's also easier/faster to make changes and "redeploy".
- Easy way to start learning Nix!
- Sets up a Python virtualenv in the root of the project that you can use to
  install packages with pip when they aren't available in Nix or for
  local/private dependencies you haven't added a flake.nix file to.

### Devbox Help

- use `devbox search name` to search for packages
- use `devbox info name` to show the info for a package
- use `devbox add name` to add a package to the shell
- use `devbox update` to update the lock file and environemnt
- use `devbox shell` to start the `nix-shell`
- use `devbox run command` to run a command inside the `nix-shell`

### Running CI commands

To run `ansible-lint` to lint the ansible files:

```bash { name=ci-01-ansible-lint }
devbox run test
```

To run `actionlint` to check the GitHub workflow files:

```bash { name=ci-02-action-lint }
devbox run actionlint
```

To run `yamlfix` to format yaml files:

```bash { name=ci-03-format-yaml }
devbox run format
```

To run `misspell` to spellcheck files:

```bash { name=ci-04-spellcheck }
devbox run spellcheck
```

To run `markdownlint` to lint markdown files:

```bash { name=ci-05-md-lint }
devbox run mdlint
```

## Ansible

The Ansible notes are located in the file [ANSIBLE.md](./ANSIBLE.md).

To run ansible playbooks run:

```bash
devbox run ansible-playbook playbooks/main.yaml --limit=host
```

## Notes

### Duplicate ipv6 addresses issue on systemd hosts

After cloning a `systemd` host, you need to run the following commands on the
clone to fix the duplicate ipv6 address collision issue:

```bash { name=fix-systemd-ipv6-collision }
cat /etc/machine-id
rm -fv /etc/machine-id
systemd-machine-id-setup  # generates random number
cat /etc/machine-id
reboot
```

Note to self: remove `/etc/machine-id` from source host before cloning.
