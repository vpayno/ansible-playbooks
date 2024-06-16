# Ansible Notes

Collection of Ansible notes and Runme playbooks.

## Inventory

Inventory is kept in a separate, private, repository.

For example, an inventory file, `hosts.yaml`, would look like this:

```yaml
---
vars:
  var0: zero

role1:
  hosts:
    name1:
    name2:
  vars:
    var1: one

role2:
  hosts:
    name3:
    name4:
  vars:
    var2: two
```

## Testing ssh connectivity

```bash
./tools/ansible-ping-host fqdn
```

## Browse host facts

```bash
./tools/ansible-get-host-facts fqdn
```

## Running all playbooks on a host

```bash
ansible-playbook playbooks/main.yaml --limit=fqdn
```

## Using tags to limit what runs on a host

```bash
ansible-playbook playbooks/main.yaml --limit=fqdn
```
