# DNS to IPv6 subnet resolver

[⬅️ Go back to main README](../README.md)

> ℹ️ **Info**: This script can not be used on its own but requires the base
> installation. See [main README](../README.md) for details.

## Table of Contents

- [DNS to IPv6 subnet resolver](#dns-to-ipv6-subnet-resolver)
  - [Table of Contents](#table-of-contents)
  - [Description](#description)
  - [Requirements and installation](#requirements-and-installation)
  - [Configuration](#configuration)
    - [`PhgIpv6AddressList`](#phgipv6addresslist)
    - [`PhgDomainToIpv6Subnet`](#phgdomaintoipv6subnet)
    - [`PhgIpv6AddressListCommentPrefix`](#phgipv6addresslistcommentprefix)
  - [Usage and invocation](#usage-and-invocation)

## Description

This script resolved IPv6 addresses from a domain and calculates the Subnet from the configured subnet length.

## Requirements and installation

Just install the script:

```rsc
$ScriptInstallUpdate dns-to-ipv6-subnet-resolver "base-url=https://git.s1q.dev/phg/routeros-scripts-custom/raw/branch/main/";
/system/script/set [find name="dns-to-ipv6-subnet-resolver"] policy=read,write,test
```

## Configuration

Edit `global-config-overlay` and Add the following variables.

| Variable name                     | Required | Data type | Example                             | Description                                                                  |
| :-------------------------------- | :------- | :-------- | :---------------------------------- | :--------------------------------------------------------------------------- |
| `PhgIpv6AddressList`              | true     | String    | `resolved_ipv6_subnets`             | IPv6 address list (address list which will contain the resolved subnets)     |
| `PhgDomainToIpv6Subnet`           | true     | tuple     | `{"example.com";64;"example.com"};` | Object containing a domain, a prefix length and a comment for the List entry |
| `PhgIpv6AddressListCommentPrefix` | false    | String    | `Resolved subnet for`               | If set, prefixes the comment for the address list                            |

### `PhgIpv6AddressList`

Example:

```rsc
:global PhgIpv6AddressList "resolved_ipv6_subnets";
```

### `PhgDomainToIpv6Subnet`

Example:

```rsc
:global PhgDomainToIpv6Subnet {
  {"example.com";64;"example.com"};
  {"example.net";56;"example.net - Home IP of John Doe"};
};
```

`PhgDomainToIpv6Subnet` tuple variables:

| Object variable | Data type | Example         | Description                                                                           |
| :-------------- | :-------- | :-------------- | :------------------------------------------------------------------------------------ |
| Domain          | String    | `"example.com"` | The domain which the IPv6 address should be resolved                                  |
| Prefix length   | Integer   | `64`            | The prefix length for the resolved IPv6 address. Used to calculate the subnet address |
| Comment         | String    | `"example.com"` | Comment for the list entry                                                            |

### `PhgIpv6AddressListCommentPrefix`

Example:

```rsc
:global PhgIpv6AddressListCommentPrefix "Resolved subnet for";
```

## Usage and invocation

How to run the script manually:

```rsc
/system/script/run dns-to-ipv6-subnet-resolver;
```

Setup a Scheduler to run the script regularly:

```rsc
/system/scheduler/add name="dns-to-ipv6-subnet-resolver" interval="00:05:00" policy="read,write,test" on-event="/system/script/run dns-to-ipv6-subnet-resolver;";
```

---
[⬅️ Go back to main README](../README.md)
[⬆️ Go back to top](#top)
