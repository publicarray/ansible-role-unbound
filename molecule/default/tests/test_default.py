import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_unbound_is_running(Service):
    unbound = Service("unbound")
    assert unbound.is_running
    assert unbound.is_enabled
