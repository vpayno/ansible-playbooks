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

Setup command auto-completion:

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

Install Playbook dependencies:

```bash { background=false category=runme closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=setup-runme-deps promptEnv=true terminalRows=10 }
go install github.com/keewek/ansible-pretty-print@latest
go install github.com/charmbracelet/gum@latest
go install github.com/mikefarah/yq/v4@latest
```

## Dev-Container

This project has a dev-container to make it easier to run ansible commands from any workstation,
it just needs [Docker](https://docs.docker.com/engine/install/)
and the [Dev Container CLI](https://github.com/devcontainers/cli) installed to get setup to run ansible playbooks.

To install the Dev Containers CLI:

```bash { background=false category=devcontainer closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=devcontainer-install promptEnv=true terminalRows=10 }
npm install -g @devcontainers/cli
```

To start the Dev Container:

```bash { background=false category=devcontainer closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=devcontainer-up promptEnv=true terminalRows=10 }
./.devcontainer/scripts/dc-up
```

To run a shell in the Dev Container:

```bash { background=false category=devcontainer closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=devcontainer-run promptEnv=true terminalRows=10 }
./.devcontainer/scripts/dc-run
```

To stop the Dev Container:

```bash { background=false category=devcontainer closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=devcontainer-down promptEnv=true terminalRows=10 }
./.devcontainer/scripts/dc-down
```

To destroy the Dev Container:

```bash { background=false category=devcontainer closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=devcontainer-destroy promptEnv=true terminalRows=10 }
./.devcontainer/scripts/dc-destroy
```

To list the Dev Containers:

```bash { background=false catgory=devcontainer closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=devcontainer-list promptEnv=true terminalRows=10 }
./.devcontainer/scripts/dc-list
```
