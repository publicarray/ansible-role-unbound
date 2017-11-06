Ansible-Role-Unbound
=========

Ansible role for Unbound DNS resolver

Requirements
------------

None

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

none

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: dnsservers
      roles:
         - { role: publicarray.unbound }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).


Testing
-------

Requires python 2.7 and docker

```sh
virtualenv --no-setuptools venv
source venv/bin/activate or source venv/bin/activate.fish
pip install docker-py molecule
molecule test
deactivate
```
