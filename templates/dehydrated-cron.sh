#!/bin/sh

set -e

# Certificate file to check for expire date.
: "${CERT:={{unbound.server.directory}}/{{unbound.server.ssl_service_pem}}}"
# Try to find dehydrated in $PATH.
: "${DEHYDRATED:=$(command -v dehydrated)}"
# Fallback dehydrated binary path.
: "${DEHYDRATED:={{unbound_tls_dehydrated_src}}/dehydrated}"
# Arguments passed to dehydrated.
# -c/--cron = Sign/renew non-existent/changed/expiring certificates.
: "${DEHYDRATED_ARGS:=-c}"
# OpenSSL binary name.
: "${OPENSSL:=openssl}"
# Unbound restart command.
# Note: 'unbound-control reload' is not enough.
# unbound needs to reload file desciptors becaurse unbound does not
# have the permissions to read the certificate file while running.
: "${RESTART_CMD:=service unbound restart}" # MacOS: sudo brew services restart unbound
# File to save current unbound cache.
: "${UNBOUND_CACHE:={{unbound.server.directory}}/unbound_cache.dmp}"

check_commad_exists() {
    if ! command -v "${1}" >/dev/null 2>&1; then
        echo "Error: command '${1}' not found."
        exit 1
    fi
}

check_commad_exists "${OPENSSL}"
check_commad_exists "${DEHYDRATED}"

if [ ! -f "${CERT}" ]; then
    echo "Error: Cannot find Certificate file at '${CERT}'."
    exit 1
fi

# 86400 seconds in a day * 30 days
if ! "${OPENSSL}" x509 -checkend $((30 * 86400)) -noout -in "${CERT}"; then
    echo "Certificate will not expire in the next 30 days. Skipping renewal!"
    exit 0 # not an error
fi

if ! ${DEHYDRATED} ${DEHYDRATED_ARGS}; then
    echo "Error:  Dehydrated failed to renew certificate."
    exit 1
fi

echo "Restarting unbound to load new certificate..."

# Put this at the bottom just in-case the script is used without unbound.
check_commad_exists unbound-control

if ! unbound-control status; then
    # unbound-control is not setup, unbound is not running or some local network error
    exit  # exit with error code from unbound-control status
fi

unbound-control dump_cache > "${UNBOUND_CACHE}"
$RESTART_CMD
unbound-control load_cache < "${UNBOUND_CACHE}"
