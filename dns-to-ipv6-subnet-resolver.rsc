#!rsc by RouterOS
# -------------------------------------------------------------------------------
# Script to grab IPv6 Addresses from DNS an converting them to subnets
#
# by Philip 'ShokiNN' Henning <mail@philip-henning.com>
# RouterOS compatibility: 7+
# Version 1.1
# last update: 03.01.2026
# https://git.s1q.dev/phg/routeros-scripts-custom/about/doc/dns-to-ipv6-subnet-resolver.md
# -------------------------------------------------------------------------------

:local ExitOK false;
onerror Err {
  :global GlobalConfigReady; :global GlobalFunctionsReady; :global GlobalFunctionsCustomPhgReady;
  :retry { :if ($GlobalConfigReady != true || $GlobalFunctionsReady != true || $GlobalFunctionsCustomPhgReady != true) \
      do={ :error ("Global config and/or functions not ready."); }; } delay=500ms max=50;
  :local ScriptName [ :jobname ];

  :global LogPrint;
  :global ParseKeyValueStore;
  :global ScriptLock;
  :global SafeResolve;
  :global PhgDomainToIpv6Subnet;
  :global PhgIpv6AddressList;
  :global PhgIpv6AddressListCommentPrefix;

  :if ([ $ScriptLock $ScriptName ] = false) do={
    :set ExitOK true;
    :error false;
  }

  :if ([:typeof $PhgDomainToIpv6Subnet ] != "array" || ([:len $PhgDomainToIpv6Subnet ] = 0)) do={
    $LogPrint error $ScriptName ("Variable 'PhgDomainToIpv6Subnet' is not set or not of type 'array'. Please set it to an array of domain/subnet-length/comment tuples.");
    :error true;
  }

  :if ([:typeof $PhgIpv6AddressList ] != "str" || $PhgIpv6AddressList = "") do={
    $LogPrint error $ScriptName ("Variable 'PhgIpv6AddressList' is not set or not of type 'string'. Please set it to the name of the IPv6 address list to use.");
    :error true;
  }

  # Log "run of script"
  $LogPrint info $ScriptName ("running");

  :local index 0;
  :foreach i in=$PhgDomainToIpv6Subnet do={
    onerror SubnetErr {
      :local configDomain ("$($i->0)");
      :local configSubnetLength ("$($i->1)");
      :local configComment "";
      if ([:typeof $PhgIpv6AddressListCommentPrefix ] != "str" || $PhgIpv6AddressListCommentPrefix = "") do={
        :set configComment ("$($i->2)");
      } else={
        :set configComment ("$PhgIpv6AddressListCommentPrefix" . " " . "$($i->2)");
      }
      :local dnsIp "";

      $LogPrint info $ScriptName ("Start configuring domain: $configDomain");
      /ipv6/firewall/address-list/remove [/ipv6/firewall/address-list/find list="$PhgIpv6AddressList" comment="$configComment"];

      :set dnsIp [$SafeResolve $configDomain ipv6];
      :if ($dnsIp != false) do={
        /ipv6/firewall/address-list/add list="$PhgIpv6AddressList" address="$dnsIp/$configSubnetLength" comment="$configComment";
        :local addedSubnet [:pick [/ipv6/firewall/address-list/get [/ipv6/firewall/address-list/find list="$PhgIpv6AddressList" comment="$configComment"]] 1];
        $LogPrint info $ScriptName ("domain: $configDomain - Set to: $addedSubnet");
      }

      $LogPrint info $ScriptName ("Finished configuring domain: $configDomain");
    } do={
      #TODO Send error via Notification system
      $LogPrint error $ScriptName ("Error processing entry index $index: $i - $SubnetErr");
    }
  };
  :set index;

  $LogPrint info $ScriptName ("finished");
} do={
  :global ExitError; $ExitError $ExitOK [ :jobname ] $Err;
}
