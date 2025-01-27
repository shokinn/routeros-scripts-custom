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
