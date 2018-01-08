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
I recommend that you copy and paste the variables below to your `group_vars/all/configs` file and that you look at unbound's documentation: https://unbound.net/documentation/unbound.conf.html

```yml
---
# Whether to compile unbound from source or to use the package manager.
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
# Common name for cert signing request
unbound_tls_domain: example.com
# Certificate generation method. Must be one of: selfsigned or acme.
# The 'acme-cf' option (implemented with dehydrated) is deprecated in favor of the new 'acme' option (implemented with acme.sh)
unbound_tls_cert_provider: selfsigned
## acme.sh options https://github.com/Neilpang/acme.sh/wiki/Options-and-Params
# Option to automatically update the acme.sh script, 0 = false, 1 = true
unbound_tls_acme_auto_upgrade: 0
# Certificate Authority. The default is the Let's Encrypt API v1, v2 is coming in 27th of Feb 2018 (--server)
# https://community.letsencrypt.org/t/staging-endpoint-for-acme-v2/49605
# - https://acme-v02.api.letsencrypt.org/directory
unbound_tls_acme_ca: https://acme-v01.api.letsencrypt.org/directory
# Use staging server for testing (--staging, --test)
# https://letsencrypt.org/docs/staging-environment/
# NOTE: when changing from staging to production you need to set 'unbound_tls_acme_force' to true.
unbound_tls_acme_staging: false
# Force create a cert (ignore expiation date)
unbound_tls_acme_force: false
# Domain validation mode. Available modes are standalone, stateless, tls, apache, dns [dns_cf|dns_dp|dns_cx|/path/to/api/file]
unbound_tls_acme_mode: dns dns_cf
# Set env variables for using DNS as domain validation
# Please see https://github.com/limaomei1986/acme.sh/blob/master/dnsapi/README.md for details
unbound_tls_acme_dns_acc:
  # CloudFlare email address
  CF_Email:
  # CloudFlare 'Global' API key <https://www.cloudflare.com/a/profile>
  # DO NOT paste your plaintext key! <https://docs.ansible.com/ansible/latest/playbooks_vault.html>
  CF_Key:
  # CloudFlare API url
  CF_Api: https://api.cloudflare.com/client/v4
# Keylength [2048, 3072, 4096, 8192 or ec-256, ec-384] (--keylength, -k)
unbound_tls_acme_keysize: 4096
# Create a ECC (Elliptic Curve Cryptography) Certificate (--ecc)
unbound_tls_acme_ecc: false
# Output debug info (--debug)
unbound_tls_acme_debug: false
# Any additional commands. https://github.com/Neilpang/acme.sh/wiki/Options-and-Params
# e.g --dnssleep 300, --webroot /path/to/webroot/
unbound_tls_acme_custom:

### OpenNic <https://www.opennic.org/>
## The address and port for the authorative server e.g. nsd <https://nlnetlabs.nl/projects/nsd/>
# opennic_address: "127.0.0.1@5300"
## The TLDs served by the authorative server and OpenNic
# opennic_tlds: [ free, geek, oss, ... ]
#
## Example of Retrieving OpenNIC TLDs
##
## - name: Get OpenNIC TLDs
##   shell: "dig @45.56.115.189 TXT tlds.opennic.glue +short | grep -v '^;' | sed s/\\\"//g | tr \" \" \"\\n\""
##   register: opennic_tlds_temp
##   check_mode: false
## - name: Set OpenNIC TLDs - https://wiki.opennic.org/opennic/dot
##   set_fact:
##     opennic_tlds: "{{opennic_tlds_temp.stdout_lines}}"

## Main unbound configuration
# See <https://unbound.net/documentation/unbound.conf.html> for more options and detailed descriptions
# Note: In Ansible the variables must use underscores (_) not dashes (-) as separators
unbound:
  server:
    verbosity: 1
    # interface: [127.0.0.1, "::1"]
    # access_control: [0.0.0.0/0 allow, "::0 allow"]
    # use_syslog: no
    # log_time_ascii: yes
    logfile: unbound.log
    auto_trust_anchor_file: root.key
    root_hints: root.hints
    pidfile: "{{_unbound.pidfile|default('unbound.pid')}}"
    username: "{{_unbound.user}}"
    # If not compiling use distribution default directory else use unbound default directory
    directory: "{{_unbound.conf_dir if unbound_compile == false else \"/usr/local/etc/unbound\"}}"
    chroot: "{{_unbound.conf_dir if unbound_compile == false else \"/usr/local/etc/unbound\"}}"
    ## DNS-over-TLS
    # interface: [0.0.0.0@853, '::0@853']
    # ssl_service_key: "private.key"
    # ssl_service_pem: "certificate.pem"
    # ssl_port: 853
  remote_control:  # unbound-control
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
