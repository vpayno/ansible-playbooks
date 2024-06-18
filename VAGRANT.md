# Vagrant Notes

Notes on how to use Vagrent from inside the Dev Container to test Ansible playbooks.

- [Debian Boxes](https://app.vagrantup.com/debian)

## Setup

```bash
$ mkdir vagrant

$ cd vagrant

$ vagrant init debian/bookworm64
A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.

$ vagrant up --provider=docker

config.nfs.functional = false
config.vm.synced_folder '../', '/workspace', type: 'sshfs', reverse: true

```

```ini
# /etc/libvirt/qemu.conf
namespaces = []

user = "root"
group = "root"
remember_owner = 0
```
