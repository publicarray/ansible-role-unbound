Ansible-Role-Unbound
=========

[![Build Status](https://travis-ci.org/publicarray/ansible-role-unbound.svg?branch=master)](https://travis-ci.org/publicarray/ansible-role-unbound)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-publicarray.unbound-blue.svg?style=flat)](https://galaxy.ansible.com/publicarray/unbound/)

Highly-configurable Ansible role for Unbound DNS resolver

 - Ansible 2.2+
 - Compatible with systems that have systemd as their init system. Latest versions of Ubuntu/Debian, RHEL/CentOS 6.x and freeBSD

Contents
--------

 1. [Installation](#installation)
 1. [Examples / common use-cases](#examples--common-use-cases)
 1. [Requirements](#requirements)
 1. [Role Variables](#role-variables)
 1. [Dependencies](#dependencies)
 1. [Example Playbook](#example-playbook)
 1. [Testing](#testing)
    1. [with molecule](#with-molecule)
    1. [with geerlingguy's script](#with-geerlingguys-script)

Installation
------------

```bash
$ ansible-galaxy install publicarray.unbound
```

Examples / common use-cases
--------

See the wiki: [Examples](https://github.com/publicarray/ansible-role-unbound/wiki/Examples)

Requirements
------------

none

Role Variables
--------------

Here is a list of the default variables for this role. They are also available in `defaults/main.yml`.

```yml
---
# Whether or not to compile unbound from source
unbound_compile: false
# The unbound version to download the source from <https://unbound.net/download.html>
unbound_compile_version: 1.6.7
# Checksum to compare the download the file against <https://unbound.net/download.html>
unbound_compile_sha256: 4e7bd43d827004c6d51bef73adf941798e4588bdb40de5e79d89034d69751c9f
# The arguments given to the `./configure` command. <!--Solaris users should use --with-solaris-threads -->
unbound_compile_config: "--enable-dnscrypt --with-username={{unbound.server.username|default(unbound)}} --with-libevent --with-run-dir={{unbound.server.directory}} --with-conf-file={{unbound.server.directory}}/unbound.conf"

# Whether to use the optimisation guidelines from <http://unbound.nlnetlabs.nl/documentation/howto_optimise.html>
unbound_optimise: false
# Percentage of physical memory to use for unbound. Only used when `unbound_optimise` is true
unbound_optimise_memory: 100

## DNS-over-TLS settings
# see <https://github.com/publicarray/ansible-role-unbound/wiki/Examples#dns-over-tls> for an example
# common name for cert signing request
unbound_tls_domain: example.com
# must be one of: selfsigned,assertonly,acme. no other provider than selfsigned implemented just yet
unbound_tls_cert_provider: selfsigned

## Main unbound configuration
# See <https://unbound.net/documentation/unbound.conf.html> for more options and detailed descriptions
# Note: In Ansible the variables must use underscores (_) not dashes (-) as separators
unbound:
  server:
    verbosity: 1
    # interface: [127.0.0.1, "::1"]
    # access_control: 0.0.0.0/0 allow
    # use_syslog: no
    # log_time_ascii: yes
    logfile: "unbound.log"
    auto_trust_anchor_file: "root.key"
    # Please update root.hints every six months or so. For example:
    # wget -O /usr/local/etc/unbound/root.hints https://www.internic.net/domain/named.cache
    root_hints: "root.hints"
    pidfile: "/var/run/unbound.pid"
    username: "{{_unbound.user}}"
    # if not compiling use distribution default directory else use unbound default directory
    directory: "{{_unbound.conf_dir if unbound_compile == false else \"/usr/local/etc/unbound\"}}"
    chroot: "{{_unbound.conf_dir if unbound_compile == false else \"/usr/local/etc/unbound\"}}"
    ## DNS-over-TLS
    # interface: [0.0.0.0@853, '::0@853']
    # ssl_service_key: "private.key"
    # ssl_service_pem: "certificate.pem"
    # ssl_port: 853
  remote_control: # unbound-control
    control_enable: false
```



Dependencies
------------

none

Example Playbook
----------------

```yml
---
- hosts: all
  roles:
    - { role: publicarray.unbound }
  vars:
    - unbound_optimise: true
```

```bash
$ ansible-playbook -i dns.example.com, playbook.yml
```

[License](LICENSE)
-------

[MIT](https://opensource.org/licenses/MIT)/[BSD](https://opensource.org/licenses/BSD-2-Clause)

Testing
-------

### with [molecule](https://molecule.readthedocs.io)

Requires python 2.7 and docker

```bash
virtualenv --no-setuptools venv
source venv/bin/activate or source venv/bin/activate.fish
pip install docker-py molecule
molecule test # --debug - for verbose output
deactivate
```

### with [geerlingguy's script](https://gist.githubusercontent.com/geerlingguy/73ef1e5ee45d8694570f334be385e181)

  1. Install and start Docker.
  1. Download the test shim into `tests/test.sh`:
    - `wget -O tests/test.sh https://gist.githubusercontent.com/geerlingguy/73ef1e5ee45d8694570f334be385e181/raw/`
  1. Make the test shim executable: `chmod +x tests/test.sh`.
  1. Run (from the role root directory) `distro=[distro] playbook=[playbook] ./tests/test.sh`.
     If you don't want the container to be automatically deleted after the test playbook is run, add the following environment variables: `cleanup=false container_id=$(date +%s)`

Credits for the test script go to @geerlingguy

Distros:
 + centos7
 + ubuntu1604
 + ubuntu1404
 + debian9
 + debian8

Playbooks: are located in `tests` directory
 + `test.yml` Test the default configuration
 + `compile-test.yml` Test compiling of unbound
 + `package-test.yml` Test dns-over-dns and optimised configuration

Example in bash/sh:

```bash
$ distro=debian9 playbook=package-test.yml cleanup=false container_id=$(date +%s) ./tests/test.sh
$ distro=debian9 playbook=compile-test.yml cleanup=false container_id=$(date +%s) ./tests/test.sh
```

Example in fish shell:

```fish
$ set -x distro debian9; set -x playbook package-test.yml; set -x cleanup false; set -x container_id (date +%s); ./tests/test.sh
$ set -x distro debian9; set -x playbook compile-test.yml; set -x cleanup false; set -x container_id (date +%s); ./tests/test.sh
```
