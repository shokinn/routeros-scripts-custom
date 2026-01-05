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

The update script does server certificate verification, so first step is to download the certificates. If you intend to download the scripts from a different location (for example from github.com) install the corresponding certificate chain.

```rsc
/tool/fetch "https://letsencrypt.org/certs/isrgrootx1.pem" dst-path="isrgrootx1.pem";
```

Note that the commands above do not verify server certificate, so if you want to be safe download with your workstations's browser and transfer the file to your MikroTik device.

- [ISRG Root X1](https://letsencrypt.org/certificates/)
  - You'll need the ISRG Root X1 (self-signed) certificate in pem format

Then we import the certificate.

```rsc
/certificate/import file-name=isrgrootx1.pem passphrase="";
```

Do not worry that the command is not shown - that happens because it contains a sensitive property, the passphrase.

For basic verification we rename the certificate and print it by fingerprint. Make sure exactly this one certificate ("ISRG-Root-X1") is shown.

```rsc
/certificate/set name="ISRG-Root-X1" [ find where common-name="ISRG Root X1" ];
/certificate/print proplist=name,fingerprint where fingerprint="96bcec06264976f37460779acf28c5a7cfe8a3c0aae11a8ffcee05c0bddf08c6";
```

Always make sure there are no certificates installed you do not know or want!

All following commands will verify the server certificate. For validity the certificate's lifetime is checked with local time, so make sure the device's date and time is set correctly!

### Initial Setup

Download the `global-functions-custom-phg.rsc` script:

```rsc
$ScriptInstallUpdate global-functions-custom-phg "base-url=https://git.s1q.dev/phg/routeros-scripts-custom/raw/branch/main/";
```

And finally load my custom functions and add a scheduler to load them on each startup.

```rsc
/system/script/run global-functions-custom-phg;
/system/scheduler/add name="global-scripts-custom-phg" start-time=startup on-event="/system/script/run global-functions-custom-phg;";
```

### Adding a script

To add a script from the repository run function `$ScriptInstallUpdate` with a comma separated list of script names, as well as the parameter `"base-url=https://git.s1q.dev/phg/routeros-scripts-custom/raw/branch/main/"`.

```rsc
$ScriptInstallUpdate ddns-hetzner,dns-to-ipv6-subnet-resolver "base-url=https://git.s1q.dev/phg/routeros-scripts-custom/raw/branch/main/";
```

## Available scripts

- [Hello World](doc/hello-world.md)
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
