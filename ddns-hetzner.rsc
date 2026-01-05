#!rsc by RouterOS
# RouterOS script: ddns-hetzner
# Version 2.0.1
# Copyright (c) 2024-2026 Philip 'ShokiNN' Henning <mail@philip-henning.com>
# https://git.s1q.dev/phg/routeros-scripts-custom/about/COPYING.md
#
# requires RouterOS, version=7.18
#
# Updates periodically DNS entries on Hetzner's DNS service with the Router's public IPs
# https://git.s1q.dev/phg/routeros-scripts-custom/src/branch/main/doc/ddns-hetzner.md

:local ExitOK false;
onerror Err {
  :global GlobalConfigReady; :global GlobalFunctionsReady; :global GlobalFunctionsCustomPhgReady;
  :retry { :if ($GlobalConfigReady != true || $GlobalFunctionsReady != true || $GlobalFunctionsCustomPhgReady != true) \
      do={ :error ("Global config and/or functions not ready."); };
  } delay=500ms max=50;

  :local ScriptName [ :jobname ];

  :global LogPrint;
  :global ParseKeyValueStore;
  :global ScriptLock;
  :global SafeResolve;

  # Local/global script specific variables
  :global PhgDDNSHetznerAPIToken;
  :global PhgDDNSHetznerDomainEntryConfig;
  :local APIUrl "https://api.hetzner.cloud/v1";

  :if ([ $ScriptLock $ScriptName ] = false) do={
    :set ExitOK true;
    :error false;
  }

  :local GetLocalIPv4 do={
    :local IP [/ip/address/get [:pick [find interface="$WANInterface"] 0] address];
    :return [:pick $IP 0 [:find $IP /]];
  }

  :local GetLocalIPv6 do={
    :local IP [/ipv6/address/get [:pick [find interface="$WANInterface" from-pool="$PublicIPv6Pool" !link-local] 0] address];
    :return [:pick $IP 0 [:find $IP /]];
  }

  :local GetAnnouncedIP do={
    :local Records;
    :local AnnouncedIP;

    :onerror GetAnnouncedIPErr in={
      $LogPrint debug $ScriptName ("GetAnnouncedIP - started");
        [/system/script/run "JParseFunctions"; global JSONLoad; global JSONLoads; global JSONUnload];
        $LogPrint debug $ScriptName ("GetAnnouncedIP - JParseFunctions loaded");

        :set Records ([$JSONLoads ([/tool/fetch "$APIUrl/zones/$ZoneName/rrsets/$RecordName/$RecordType" http-method=get http-header-field="Authorization: Bearer $APIToken" output=user as-value]->"data")]->"rrset"->"records");
        $LogPrint debug $ScriptName ("GetAnnouncedIP - Records received: " . [:len $Records]);
        foreach rec in=$Records do={
          $LogPrint debug $ScriptName ("GetAnnouncedIP - Record: Name: \"" . $RecordName . "\", Type: \"" . $RecordType . "\", Value: \"" . ($rec->"value") . "\", Comment: \"" . ($rec->"comment") . "\"");
        }

        :if ([:len $Records] > 1) do={
          :error ("Multiple records found for \"$RecordName.$ZoneName\", RecordType: $RecordType. This is not supported.");
        } else={
          :if ([:len $Records] = 1) do={
            :set AnnouncedIP ($Records->0->"value");
          }
        }
        $LogPrint debug $ScriptName ("GetAnnouncedIP - Announced IP is: " . $AnnouncedIP);

        :return $AnnouncedIP;
    } do={
      $LogPrint debug $ScriptName ("GetAnnouncedIP - Error Message: " . $GetAnnouncedIPErr);

      :if ([:find "$GetAnnouncedIPErr" "status 404";] >= 1) do={
        $LogPrint debug $ScriptName ("GetAnnouncedIP - Announced IP is not set");
        :return false;
      }
      :error ("GetAnnouncedIP - API Error - $GetAnnouncedIPErr");
    }
    :return $AnnouncedIP;
  }

  :local APISetRecord do={
    :local APIResponse;

    :onerror APISetRecordErr in={
      $LogPrint debug $ScriptName ("APISetRecord - started");
      [/system/script/run "JParseFunctions"; global JSONLoad; global JSONLoads; global JSONUnload];
      $LogPrint debug $ScriptName ("APISetRecord - JParseFunctions loaded");

      :local Records;
      :local Record;
      :local Payload;

      :onerror GetRecordsErr in={
        :set Records ([$JSONLoads ([/tool/fetch "$APIUrl/zones/$ZoneName/rrsets/$RecordName/$RecordType" http-method=get http-header-field="Authorization: Bearer $APIToken" output=user as-value]->"data")]->"rrset"->"records");
      } do={
        :if ([:find "$GetRecordsErr" "status 404";] >= 1) do={
          :set Records [:toarray ""];
        } else={
          $LogPrint error $ScriptName ("APISetRecord - Could not get record from API - $GetRecordsErr");
        }
      }
      $LogPrint debug $ScriptName ("APISetRecord - Records received: " . [:len $Records]);
      foreach rec in=$Records do={
        $LogPrint debug $ScriptName ("APISetRecord - Record: Name: \"" . $RecordName . "\", Type: \"" . $RecordType . "\", Value: \"" . ($rec->"value") . "\", Comment: \"" . ($rec->"comment") . "\"");
      }

      :if ([:len $Records] > 1) do={
        :error ("Multiple records found for \"$RecordName.$ZoneName\", RecordType: $RecordType. This is not supported.");
      } else={
        :if ([:len $Records] = 1) do={
          :set Record ($Records->0);
        }
      }

      :local RecordDebugLogOutput;
      foreach key,value in=$Record do={
        :if ([:typeof $RecordDebugLogOutput ] != "str" || $RecordDebugLogOutput = "") do={
          :set RecordDebugLogOutput ($key . ": \"" . $value . "\"");
        } else={
          :set RecordDebugLogOutput ($RecordDebugLogOutput . ", " . $key . ": \"" . $value . "\"");
        }
      }
      $LogPrint debug $ScriptName ("APISetRecord - Picked Record: " . $RecordDebugLogOutput);

      :if ([:typeof $Record] != "nothing") do={
        :set Payload "{\"records\":[{\"value\":\"$InterfaceIP\",\"comment\":\"Updated by RouterOS DDNS Script\"}]}";
        $LogPrint debug $ScriptName ("APISetRecord - Payload: " . $Payload);
        $LogPrint debug $ScriptName ("APISetRecord - Updating existing record - URL: $APIUrl/zones/$ZoneName/rrsets/$RecordName/$RecordType/actions/set_records");
        :set APIResponse ([/tool/fetch "$APIUrl/zones/$ZoneName/rrsets/$RecordName/$RecordType/actions/set_records" http-method=post http-header-field="Content-Type: application/json,Authorization: Bearer $APIToken" http-data=$Payload output=user as-value]->"status");
      } else={
        :set Payload "{\"name\":\"$RecordName\",\"type\":\"$RecordType\",\"ttl\":$([:tonum $RecordTTL]),\"records\":[{\"value\":\"$InterfaceIP\",\"comment\":\"Updated by RouterOS DDNS Script\"}]}";
        $LogPrint debug $ScriptName ("APISetRecord - Payload: " . $Payload);
        $LogPrint debug $ScriptName ("APISetRecord - Creating new record - URL: $APIUrl/zones/$ZoneName/rrsets");
        :set APIResponse ([/tool/fetch "$APIUrl/zones/$ZoneName/rrsets" http-method=post http-header-field="Content-Type: application/json,Authorization: Bearer $APIToken" http-data=$Payload output=user as-value]->"status");
      }
      $LogPrint debug $ScriptName ("APISetRecord - APIResponse: " . $APIResponse);

      $JSONUnload;
      $LogPrint debug $ScriptName ("APISetRecord - JSONUnload done");
      $LogPrint debug $ScriptName ("APISetRecord - finished");
      :return $APIResponse;
    } do={
      #TODO Send error via Notification system
      $LogPrint error $ScriptName ("Could not set record - Zone: " . $ZoneName . ", RecordName: " . $RecordName . ", RecordType: " . $RecordType . " - API Error: " . $APISetRecordErr);
    }
    :return $APIResponse;
  }


  $LogPrint debug $ScriptName ("Begin DDNS update process");

  :local index 0;
  :foreach i in=$PhgDDNSHetznerDomainEntryConfig do={
    :local WANInterface ("$($i->0)");
    :local PublicIPv6Pool ("$($i->1)");
    :local ZoneName ("$($i->2)");
    :local RecordType ("$($i->3)");
    :local RecordName ("$($i->4)");
    :local RecordTTL ("$($i->5)");
    :local FQDN;
    :local InterfaceIP;
    :local DNSIP;
    :local StartLogMsg "Start configuring domain: ";
    :local EndLogMsg "Finished configuring domain: ";

    :if ($RecordName = "@") do={
      :set FQDN ("$($i->2)");
    } else={
      :set FQDN ("$($i->4).$($i->2)");
    }

    :if ($RecordType = "A") do={
      $LogPrint debug $ScriptName ($StartLogMsg . $FQDN . " - Type A Record");

      :set InterfaceIP [$GetLocalIPv4 WANInterface=$WANInterface];
      :set DNSIP [$GetAnnouncedIP APIUrl=$APIUrl APIToken=$PhgDDNSHetznerAPIToken ZoneName=$ZoneName RecordType=$RecordType RecordName=$RecordName LogPrint=$LogPrint ScriptName=$ScriptName];
      $LogPrint debug $ScriptName ("Domain: " . $FQDN . " - Announced DNS IP: " . $DNSIP);

      :if ($InterfaceIP != $DNSIP) do={
        :if ($DNSIP = false) do={
          $LogPrint debug $ScriptName ("Domain: " . $FQDN . " - local IP: " . $InterfaceIP . ", differs from DNS IP: none");
        } else={
          $LogPrint debug $ScriptName ("Domain: " . $FQDN . " - local IP: " . $InterfaceIP . ", differs from DNS IP: " . $DNSIP);
        }
        $LogPrint debug $ScriptName ("Domain: " . $FQDN . " - Updating A Record to " . $InterfaceIP);

        :local ResponseSetRecord [$APISetRecord APIUrl=$APIUrl APIToken=$PhgDDNSHetznerAPIToken ZoneName=$ZoneName RecordType=$RecordType RecordName=$RecordName RecordTTL=$RecordTTL InterfaceIP=$InterfaceIP LogPrint=$LogPrint ScriptName=$ScriptName];
        $LogPrint debug $ScriptName ("ResponseSetRecord: " . $ResponseSetRecord);

        :if ($ResponseSetRecord = "finished") do={
          $LogPrint info $ScriptName ("Domain: " . $FQDN . " - Updating A Record to " . $InterfaceIP . " successful");
        }
      } else={
        $LogPrint debug $ScriptName ("Domain: " . $FQDN . " - local IP: " . $InterfaceIP . ", is equal to DNS IP: " . $DNSIP . " - Nothing to do");
      }

      $LogPrint debug $ScriptName ($EndLogMsg . $FQDN . " - Type A Record");
    }

    :if ($RecordType = "AAAA") do={
      $LogPrint debug $ScriptName ($StartLogMsg . $FQDN . " - Type AAAA Record");

      :set InterfaceIP [$GetLocalIPv6 WANInterface=$WANInterface PublicIPv6Pool=$PublicIPv6Pool];
      :set DNSIP [$GetAnnouncedIP APIUrl=$APIUrl APIToken=$PhgDDNSHetznerAPIToken ZoneName=$ZoneName RecordType=$RecordType RecordName=$RecordName LogPrint=$LogPrint ScriptName=$ScriptName];
      $LogPrint debug $ScriptName ("Domain: " . $FQDN . " - Announced DNS IP: " . $DNSIP);

      :if ($InterfaceIP != $DNSIP) do={
        :if ($DNSIP = false) do={
          $LogPrint debug $ScriptName ("Domain: " . $FQDN . " - local IP: " . $InterfaceIP . ", differs from DNS IP: none");
        } else={
          $LogPrint debug $ScriptName ("Domain: " . $FQDN . " - local IP: " . $InterfaceIP . ", differs from DNS IP: " . $DNSIP);
        }
        $LogPrint debug $ScriptName ("Domain: " . $FQDN . " - Updating AAAA Record to " . $InterfaceIP);

        :local ResponseSetRecord [$APISetRecord APIUrl=$APIUrl APIToken=$PhgDDNSHetznerAPIToken ZoneName=$ZoneName RecordType=$RecordType RecordName=$RecordName RecordTTL=$RecordTTL InterfaceIP=$InterfaceIP LogPrint=$LogPrint ScriptName=$ScriptName];
        $LogPrint debug $ScriptName ("ResponseSetRecord: " . $ResponseSetRecord);

        :if ($ResponseSetRecord = "finished") do={
          $LogPrint info $ScriptName ("Domain: " . $FQDN . " - Updating AAAA Record to " . $InterfaceIP . " successful");
        }
      } else={
        $LogPrint debug $ScriptName ("Domain: " . $FQDN . " - local IP: " . $InterfaceIP . ", is equal to DNS IP: " . $DNSIP . " - Nothing to do");
      }

      $LogPrint debug $ScriptName ($EndLogMsg . $FQDN . " - Type AAAA Record");
    }


    :if (($RecordType != "A") && ($RecordType != "AAAA")) do={
      $LogPrint error $ScriptName ("Wrong Record type for array index number " . $index . " (Value: " . $RecordType . ")");
    }

    :set index ($index+1);
  }
  :set index;

  $LogPrint debug $ScriptName ("Finished DDNS update process");

} do={
  :global ExitError; $ExitError $ExitOK [ :jobname ] $Err;
}
