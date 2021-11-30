# profile_lmod

NCSA Common Puppet Profiles - configure Lmod and default modules

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with profile_lmod](#setup)
    * [What profile_lmod affects](#what-profile_lmod-affects)
    * [Beginning with profile_lmod](#beginning-with-profile_lmod)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Development - Guide for contributing to the module](#development)

## Description

This profile includes the lmod module but also adds on (optional) management
of some default modules and a default SitePackage.lua file, which configures
basic logging of modules usage (to syslog).

## Setup

### What profile_lmod affects

This module requires and includes [treydock/lmod][4]. See docs for that module
to understand what it affects (but in short, it configures and can install
Lmod from source or package).

Additionally, this module (by default, but optionally) manages a few default
module files as well as a custom SitePackage.lua file, which configures basic
logging to syslog. Additional custom module files can be managed as well.
The intent/suggestion is to simply manage a few default module files that
will live local to the node and which can point to shared storage for a more
complete offering of modules.

Users should understand how the treydock/lmod module works and then assess
how their usage of that module combines with usage of this profile.

### Beginning with profile_lmod

The profile assumes and does the following:
- assumes that the managed files will be in /usr/share/modulefiles/{Core,Site}
  - these are created if they don't exist
- assumes additional common (and private) modules are in a shared /sw/...
- assumes StdEnv.lua is the default module
- assumes the lmod Puppet module is configured and Lmod is installed/configured
- adds/manages the following module files:
  - Core/StdEnv.lua
  - Core/group_paths
  - Site/SitePackage.lua (the special site package, configuring usage logging)
- StdEnv.lua in turn loads the following modules by default:
  - lmod
  - group_paths

Assuming that all works, it is only necessary to include profile_lmod:
```
include ::profile_lmod
```

## Usage

The following examples assume that the lmod Puppet module is being used in a
fairly default way, with the following in Hiera:
```
lmod::modulepaths:
  - "Core"
lmod::set_default_module: true
lmod::set_lmod_package_path: true
lmod::site_name: "MyOrg"
lmod::system_name: "MyCluster"
```
On a Red Hat-like system this means (as of present) that Lmod will be
installed via RPM/Yum from EPEL, and that EPEL will be managed by the epel
Puppet module. Additionally, some dependencies on RH8 will need to come from
the Red Hat codeready-builder repo.

But essentially this assumes Lmod is installed and configured, and that
- LMOD_PACKAGE_PATH=/usr/share/modulefiles/Site
- MODULEPATH=...:/usr/share/modulefiles/Core:...
- the default module in Lmod is 'StdEnv'

As outlined earlier, simply including 'profile_lmod' with the above
configuration for the lmod Puppet module should create a working Lmod
implementation.

Customizations (driven by Hiera) might include:

### Disable management of the default, managed module files:
```
profile_lmod::modules:
  "/usr/share/modulefiles/Core/group_paths":
    manage: false
  "/usr/share/modulefiles/Core/StdEnv.lua":
    manage: false
  "/usr/share/modulefiles/Site/SitePackage.lua":
    manage: false
```

### Override, but still manage, the StdEnv.lua module file:
```
profile_lmod::modules:
  "/usr/share/modulefiles/Core/StdEnv.lua":
    data:
      content: |
        -- -*- lua -*-
        whatis("Description: Load system standard modules")
        load("lmod", "group_paths", "custom/module/version")
```

Manage StdEnv.lua but use a different path:
```
# you will likely need to add the parent directories:
profile_lmod::directories:
  "/some": {}
  "/some/other": {}
  "/some/other/path": {}

profile_lmod::modules:
  "/usr/share/modulefiles/Core/StdEnv.lua":
    manage: false
  "/some/other/path/StdEnv.lua":
    data:
      content: |
        -- -*- lua -*-
        whatis("Description: Load system standard modules")
        ...
    manage: true
```

Manage a custom module file:
```
# you will likely need to add the parent directories:
profile_lmod::directories:
  "/usr/share/modulefiles/Core/custom": {}
  "/usr/share/modulefiles/Core/custom/module": {}

profile_lmod::modules:
  "/usr/share/modulefiles/Core/custom/module/version":
    data:
      content: |
        -- -*- lua -*-
        whatis("Description: Load some custom module")
        ...
```

## Reference

See: [REFERENCE.md](REFERENCE.md)

[4]: https://forge.puppet.com/modules/treydock/lmod
