# Runme playbook - Initial Host Setup After Installation

The playbooks necessary to setup a host after it has been installed.

## Setup connectivity

Add your public SSH key(s) to `~/.ssh/authorized_keys` on the server(s).

```bash { background=false category=setup-host closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=setup-host-authorized_keys promptEnv=true terminalRows=25 }
# adds one or more public ssh keys to one or more servers
# all paths are relative to the directory of the playbook markdown file

set -e

stty cols 80
stty rows 25

declare -a HOSTS

gum format "# Please enter a space-delimited list of FQDNs or IP addresses:"
read -r -a HOSTS < <(gum input --width=79)
printf "\n"

gum format "# Pushing authorized_keys to:"
printf -- "  - %s\n" "${HOSTS[@]}"
printf "\n"

if [[ ${#HOSTS[@]} -eq 0 ]] || [[ -z ${HOSTS[0]} ]]; then
    gum format "# ERROR: we need a list of hosts to continue"
    printf "\n"
    exit 1
fi

echo Running: tools/setup-push-ssh-keys "${HOSTS[@]}"
tools/setup-push-ssh-keys "${HOSTS[@]}"
printf "\n"

gum format "# Testing Ansible connectivity to host(s):"
printf "\n"

for h in "${HOSTS[@]}"; do
    # gets the inventory path from ./ansible.cfg
    ansible "${h}" -m ping -u "${USER}"
done
```
