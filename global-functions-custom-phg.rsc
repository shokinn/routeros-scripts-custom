#!rsc by RouterOS
# RouterOS script: global-functions-custom-phg
# Copyright (c) 2025 Philip 'ShokiNN' Henning <mail@philip-henning.com>
# https://git.s1q.dev/phg/routeros-scripts-custom/about/COPYING.md
#
# requires RouterOS, version=7.14
#
# global functions for my custom scripts
# https://git.s1q.dev/phg/routeros-scripts-custom/about

:local ScriptName [ :jobname ];

# global variables not to be changed by user
:global GlobalFunctionsCustomPhgReady false;

# global functions
:global SafelyResolve

# Function: safelyResolve
#  - Takes a DNS string (e.g. "example.com")
#  - Takes an IP type [ipv4, ipv6]
#  - Returns a string of and IP address or false if it can't be resolved
:set SafelyResolve do={
  :do {
    :local DomainName [ :tostr $1 ];
    :if ( [ :tostr $2 ] = "ipv4" or [ :tostr $2 ] = "ipv6" ) do={
      :local IPType [ :tostr $2 ];
    } else={
      :local IPType "ipv4";
    }
    :local IP [:resolve domain-name="$DomainName" type=$IPType];
    :return "$IP";
  } on-error={
    return false;
  }
}

# signal we are ready
:set GlobalFunctionsCustomPhgReady true;