# Custom RouterOS Scripts

[RouterOS](https://mikrotik.com/software) is the operating system developed
by [MikroTik](https://mikrotik.com/aboutus) for networking tasks. This
repository holds a number of [scripts](https://wiki.mikrotik.com/wiki/Manual:Scripting)
to manage RouterOS devices or extend their functionality.

*Use at your own risk*, pay attention to
[license and warranty](#license-and-warranty)!

## Table of Contents

- [Custom RouterOS Scripts](#custom-routeros-scripts)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Installation](#installation)
    - [Prerequisites (a.k.a. Install certificates)](#prerequisites-aka-install-certificates)
    - [Initial Setup](#initial-setup)
    - [Adding a script](#adding-a-script)
  - [Available scripts](#available-scripts)
  - [License and warranty](#license-and-warranty)
  - [Upstream](#upstream)

## Requirements

This is a repository containing **custom** RouterOS scripts. These do depend
on upstream project. Visit
[RouterOS-Scripts](https://git.eworm.de/cgit/routeros-scripts/about/) and
follow the instructions there for the basic installation and setup.

## Installation

### Prerequisites (a.k.a. Install certificates)

The update script does server certificate verification, so first step is to download the certificates. If you intend to download the scripts from a different location (for example from git.s1q.dev or github.com) install the corresponding certificate chain.  
Depending from where you want to install my RouterOS scripts, you need to import a
Let's Encrypt root certificate (git.s1q.dev) or the USERTrust root certificate (github.com).

`git.s1q.dev`:

```rsc
$CertificateAvailable "ISRG Root X1" "fetch";
```

`github.com`:

```rsc
$CertificateAvailable "USERTrust ECC Certification Authority" "fetch";
```

> [!IMPORTANT]
> Always make sure there are no certificates installed you do not know or want!

All following commands will verify the server certificate. For validity the certificate's lifetime is checked with local time, so make sure the device's date and time is set correctly!

> [!TIP]
> In Christian's RouterOS scripts there is tooling to easily install additional certificates.  
> <https://github.com/eworm-de/routeros-scripts/blob/main/CERTIFICATES.md>

### Initial Setup

Download the `global-functions.d/phg.rsc` script:

```rsc
$ScriptInstallUpdate global-functions.d/phg "base-url=https://git.s1q.dev/phg/routeros-scripts-custom/raw/branch/main/";
```

### Adding a script

To add a script from the repository run function `$ScriptInstallUpdate` with a comma separated list of script names, as well as the parameter `"base-url=https://git.s1q.dev/phg/routeros-scripts-custom/raw/branch/main/"`.

```rsc
$ScriptInstallUpdate ddns-hetzner,dns-to-ipv6-subnet-resolver "base-url=https://git.s1q.dev/phg/routeros-scripts-custom/raw/branch/main/";
```

## Available scripts

- [DDNS (DynDNS) Hetzner update script](doc/ddns-hetzner.md)
- [DNS to IPv6 subnet resolver](doc/dns-to-ipv6-subnet-resolver.md)

## License and warranty

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
[GNU General Public License](COPYING.md) for more details.

## Upstream

URL:
[git.s1q.dev](https://git.s1q.dev/phg/routeros-scripts-custom)

Mirror:
[GitHub.com](https://github.com/shokinn/routeros-scripts-custom)

---
[⬆️ Go back to top](#top)
