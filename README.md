# ansible-playbooks

[![actionlint](https://github.com/vpayno/ansible-playbooks/actions/workflows/gh-actions.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/gh-actions.yaml)
[![ansible](https://github.com/vpayno/ansible-playbooks/actions/workflows/ansible.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/ansible.yaml)
[![json](https://github.com/vpayno/ansible-playbooks/actions/workflows/json.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/json.yaml)
[![markdown](https://github.com/vpayno/ansible-playbooks/actions/workflows/markdown.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/markdown.yaml)
[![spellcheck](https://github.com/vpayno/ansible-playbooks/actions/workflows/spellcheck.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/spellcheck.yaml)
[![woke](https://github.com/vpayno/ansible-playbooks/actions/workflows/woke.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/woke.yaml)
[![yaml](https://github.com/vpayno/ansible-playbooks/actions/workflows/yaml.yaml/badge.svg?branch=main)](https://github.com/vpayno/ansible-playbooks/actions/workflows/yaml.yaml)

Ansible playbook for my home lab.

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
