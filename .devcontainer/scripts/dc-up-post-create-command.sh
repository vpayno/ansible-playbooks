#!/usr/bin/env bash

set -x
set -e

# shellcheck disable=SC1091 source=.devcontainer/scripts/data.tmp
source /workspaces/ansible-playbooks/.devcontainer/scripts/data.tmp

# process name:value args
declare NEWUSER
for arg in "${@}"; do
	if [[ $arg =~ ^user: ]]; then
		NEWUSER="${arg#*:}"
	fi
done

# shellcheck disable=SC2154
{
	groupadd --gid "${devcontainer_gid}" "${devcontainer_username}"
	useradd --uid "${devcontainer_uid}" --gid "${devcontainer_gid}" --no-create-home --groups docker,sudo "${devcontainer_username}"
	chsh --shell /bin/bash "${devcontainer_username}"
	printf "%s\n%s\n" "${devcontainer_password}" "${devcontainer_password}" | passwd "${devcontainer_username}"
	id "${devcontainer_username}"
}

declare -a cargo_pkgs=(
	git-cliff
)

declare -a go_pkgs=(
	github.com/charmbracelet/glow@latest
	github.com/charmbracelet/gum@latest
	github.com/keewek/ansible-pretty-print@latest
	github.com/mikefarah/yq/v4@latest
	github.com/stateful/runme/v3@v3
)
declare go_pkg

declare -a pip_pkgs=(
	yamllint
	yamlfix
)
declare pip_pkg

declare -a ansible_galaxy_pkgs=(
	community.general
)
declare ag_pkg

declare -a npm_pkgs=(
	@ansible/ansible-language-server
)
declare npm_pkg

declare -a apt_pkgs=(
	ansible
	ansible-lint
	jqp
	libvirt-clients-qemu
	libvirt-daemon
	libvirt-daemon-config-network
	libvirt-daemon-driver-qemu
	nala
	vagrant
	vagrant-hostmanager
	xq
)

# these commands also run as root

if [[ -n ${NEWUSER} ]]; then
	printf "Allowing password-less sudo for user %s\n" "${NEWUSER}"
	tee > /etc/sudoers.d/020_user-nopasswd <<- EOF
		${NEWUSER} ALL=(ALL) NOPASSWD: ALL
	EOF
fi

tee > /usr/local/bin/dc-user-setup-ssh-agent <<- EOF
	#!/usr/bin/env bash

	# this script assumes that you will run it once and then start tmux which
	# will inherit the environment on all future shells.

	if [[ -z \${SSH_AUTH_SOCK} ]]; then
		ssh-agent | tee ~/.ssh-agent-settings-dc.txt
		chmod -v 0600 ~/.ssh-agent-settings-dc.txt
		printf "\n"

		source ~/.ssh-agent-settings-dc.txt
		printf "\n"

		sleep 1s

		ssh-add -L
		printf "\n"

		printf "Please use\n\n\tssh-add ~/.ssh/id_keyname\n\nto add keys to your ssh-agent.\n"
	else
		source ~/.ssh-agent-settings-dc.txt
		printf "\n"

		sleep 1s

		ssh-add -L
		printf "\n"
	fi
EOF
chmod -v 0755 /usr/local/bin/dc-user-setup-ssh-agent

# https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-debian
curl -sS "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
apt update
time apt install -y "${apt_pkgs[@]}"
printf "\n"

time cargo install --locked "${cargo_pkgs[@]}"
printf "\n"

# time cargo install --git https://github.com/helix-editor/helix.git --tag "$(git ls-remote --tags https://github.com/helix-editor/helix.git | sed -r -e 's:.*/::g' | grep -E '^[0-9]+[.][0-9]+([.][0-9]+)?$' | sort -rV | head -n 1)" helix-term
# printf "\n"

time for go_pkg in "${go_pkgs[@]}"; do
	time go install "${go_pkg}"
	printf "\n"
done

time for pip_pkg in "${pip_pkgs[@]}"; do
	time pip install "${pip_pkg}"
	printf "\n"
done

time for ag_pkg in "${ansible_galaxy_pkgs[@]}"; do
	ansible-galaxy collection install "${ag_pkg}"
done

time for npm_pkg in "${npm_pkgs[@]}"; do
	npm install -g "${npm_pkg}"
done
