#!rsc by RouterOS
# RouterOS script: global-functions.d/phg.rsc
# Copyright (c) 2025-2026 Philip 'ShokiNN' Henning <mail@philip-henning.com>
# https://git.s1q.dev/phg/routeros-scripts-custom/about/COPYING.md
#
# requires RouterOS, version=7.14
#
# global functions for my custom scripts
# https://git.s1q.dev/phg/routeros-scripts-custom

:local ScriptName [ :jobname ];

# global variables not to be changed by user
:global GlobalFunctionsCustomPhgReady false;

# global functions
:global SafeResolve

# Function: safelyResolve
#  - Takes a DNS string (e.g. "example.com")
#  - Takes an IP type [ipv4, ipv6]
#  - Returns a string of an IP address or false if it can't be resolved
:set SafeResolve do={
  :do {
    :local DomainName [ :tostr $1 ];
    :local IPType;
    :if ( ([ :tostr $2 ] = "ipv4") or ([ :tostr $2 ] = "ipv6") ) do={
      :set IPType [ :tostr $2 ];
    } else={
      :global ExitError; $ExitError false $0;
    }
    :local ResolvedIP [:resolve domain-name="$DomainName" type=$IPType];
    :return "$ResolvedIP";
  } on-error={
    :return false;
  }
}

# signal we are ready
:set GlobalFunctionsCustomPhgReady true;
