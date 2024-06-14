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

This and other readme files in this repo are RunMe Playbooks.

Use this playbook step/task to update the [RunMe](https://runme.dev) CLI.

If you don't have RunMe installed, you'll need to copy/paste the command. :)

```bash { background=false category=runme closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=setup-runme-install promptEnv=true terminalRows=10 }
go install github.com/stateful/runme/v3@v3
```

Setup command autocompletion:

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
go install github.com/charmbracelet/gum@latest
go install github.com/mikefarah/yq/v4@latest
```
