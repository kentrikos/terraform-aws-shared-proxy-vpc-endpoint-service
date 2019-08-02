#!/bin/bash

# Helper script for Terraform external data source,
# that will attempt to resolve hostnames to IPs.
# requires to be installed: jq, dig

# FUNCTIONS:
function error_exit() {
  echo "ERROR: ${1}" 1>&2
  exit 1
}

# VALIDATE INPUT (QUERY):
eval "$(jq -r '@sh "export DNS_NAME=\(.dns_name) DNS_SERVER_IP=\(.dns_server_ip)"')"
if [ -z "${DNS_NAME}" ]; then
  error_exit "Error, incorrect input: $*"
fi

# VALIDATE AND RESOLVE DNS NAME (SKIP RESOLUTION IF IP WAS PASSED):
if [[ $DNS_NAME =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  IP="${DNS_NAME}"
else
  if [[ "${DNS_SERVER_IP}" =~ ^(null){0,1}$ ]]; then
    # Attempt to use locally configured DNS server:
    export DNS_SERVER_IP="$(cat /etc/resolv.conf | sed -ne 's/^nameserver //p' | head -1)"
  fi
  IP="$(dig +short ${DNS_NAME} @${DNS_SERVER_IP} | grep '^[.0-9]\+$')"
  if ! [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    error_exit "Error, could not resolve: ${DNS_NAME}"
  fi
fi

# PRODUCE OUTPUT (JSON):
jq -n --arg ip "${IP}" '{"ip":$ip}'
