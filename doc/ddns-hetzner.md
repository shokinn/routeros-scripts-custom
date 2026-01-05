# DDNS (DynDNS) Hetzner update script

[⬅️ Go back to main README](../README.md)

> ℹ️ **Info**: This script can not be used on its own but requires the base
> installation. See [main README](../README.md) for details.

## Table of Contents

- [DDNS (DynDNS) Hetzner update script](#ddns-dyndns-hetzner-update-script)
  - [Table of Contents](#table-of-contents)
  - [Description](#description)
  - [Requirements and installation](#requirements-and-installation)
    - [Dependencies](#dependencies)
      - [Installation](#installation)
    - [Pre requisites](#pre-requisites)
    - [Installation](#installation-1)
  - [Configuration](#configuration)
    - [`PhgDDNSHetznerAPIToken`](#phgddnshetznerapitoken)
    - [`PhgDDNSHetznerDomainEntryConfig`](#phgddnshetznerdomainentryconfig)
  - [Usage and invocation](#usage-and-invocation)
  - [See also](#see-also)

## Description

This Mikrotik RouterOS 7 script for updating DNS entries via Hetzner's Cloud API.

The script is currently only compatible with RouterOS 7.  
RouterOS 6 isn't and won't be supported!

## Requirements and installation

### Dependencies

This script requires [Winand](https://github.com/Winand)'s [mikrotik-json-parser](https://github.com/Winand/mikrotik-json-parser) to be installed.

#### Installation

Create another new script:

   1. Name: `JParseFunctions`
   2. Policy: `read`, `write`, `test` uncheck everything else
   3. Source: The content of [mikrotik-json-parser](https://github.com/Winand/mikrotik-json-parser/blob/master/JParseFunctions)

### Pre requisites

> [!IMPORTANT]
> **It's strongly recommended to create a separate Project just for your DNS Zone!**
> Because the API Token you will create will have Read/Write access to the whole Project it can't be restricted to specific services like DNS.

Create a [API token for Hetzner's Cloud API](https://docs.hetzner.cloud/reference/cloud#getting-started).

The API token can be created at:  
`Your cloud project` -> `Security` -> `API-Tokens`

### Installation

Just install the script:

```rsc
$ScriptInstallUpdate ddns-hetzner "base-url=https://git.s1q.dev/phg/routeros-scripts-custom/raw/branch/main/";
/system/script/set [find name="ddns-hetzner"] policy=read,write,test
```

## Configuration

Edit `global-config-overlay` and add the following variables.

| Variable name                     | Requried | Data type             | Example                                                                                                        | Description                                                                                                                                                                          |
| :-------------------------------- | :------- | :-------------------- | :------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `PhgDDNSHetznerAPIToken`          | true     | `string`              | `LRK9DAWQ1ZAEFSrCNEEzLCUwhYX1U3g7wMg4dTlkkDC96fyDuyJ39nVbVjCKSDfj`                                             | This variable requires a valid API token for the [Hetzner DNS API](https://docs.hetzner.cloud/reference/cloud#getting-started). You can create an API token in you project settings. |
| `PhgDDNSHetznerDomainEntryConfig` | true     | `array`s of `string`s | `{{"pppoe-out1";"";"example.com";"A";"@";"300";};{"pppoe-out1";"pool-ipv6";"example.com";"AAAA";"@";"300";};}` | See below how to format the arrays correctly.                                                                                                                                        |

### `PhgDDNSHetznerAPIToken`

Example:

```rsc
:global PhgDDNSHetznerAPIToken "LRK9DAWQ1ZAEFSrCNEEzLCUwhYX1U3g7wMg4dTlkkDC96fyDuyJ39nVbVjCKSDfj";
```

### `PhgDDNSHetznerDomainEntryConfig`

The `domainEntryConfig` array consists of multiple arrays. Each of the is configuring a DNS record for a given domain in a zone.

The data sheet below describes the formatting of the DNS records arrays.


| Array index | Data          | Data type | Example        | Description                                                                                                                                                              |
| ----------: | :------------ | :-------- | :------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|         `0` | `interface`   | `string`  | `"pppoe-out1"` | Name of the interface where the IP which is currently configured is fetched from.                                                                                        |
|         `1` | `pool`        | `string`  | `"pool-ipv6"`  | The prefix delegation pool which is used to automatically setup the IPv6 interface IP. Use "" when you don't use a pool to set your interface ip or for a type A record. |
|         `2` | `zone`        | `string`  | `"domain.com"` | Zone which should be used to set a record to.                                                                                                                            |
|         `3` | `record type` | `string`  | `"A"`          | Valid values `A`, `AAAA`. The type of record which will be set. Also determines which IP (v4/v6) will be fetched.                                                        |
|         `4` | `record name` | `string`  | `"@"`          | The record name which should be updated. Use `@` for the root of your domain.                                                                                            |
|         `5` | `record TTL`  | `string`  | `"300"`        | TTL value of the record in seconds, for a dynamic entry a short lifetime like 300 is recommended.                                                                        |

Example:

```rsc
:global PhgDDNSHetznerDomainEntryConfig {
  {
    "pppoe-out1";
    "";
    "example.com";
    "A";
    "@";
    "300";
  };
  {"pppoe-out1";"pool-ipv6";"example.com";"AAAA";"@";"300";};
  {"pppoe-out1";"";"example.net";"A";"ddns";"300";};
  {"pppoe-out1";"pool-ipv6";"example.org";"AAAA";"ddns";"300";};
};
```

This example will create & update those DNS records:

- example.com
  - IPv4
  - IPv6
- example.net
  - IPv4
- example.org
  - IPv6

## Usage and invocation

How to run the script manually:

```rsc
/system/script/run ddns-hetzner;
```

Setup a Scheduler to run the script regularly:

```rsc
/system/scheduler/add name="ddns-hetzner" interval="00:05:00" policy="read,write,test" on-event="/system/script/run ddns-hetzner;";
```

## See also

* ...

---
[⬅️ Go back to main README](../README.md)
[⬆️ Go back to top](#top)
