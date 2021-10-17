#!/bin/bash
# Copyright (c) 2000-2020 Synology Inc. All rights reserved.

source /pkgscripts/include/pkg_util.sh

package="RoonServer"
displayname="Roon Server"
version=`date +%Y%m%d`
description="Roon is architected differently than most audio systems out there. Roon consists of a single core and as many controls and outputs as you need. This means you get the same Roon experience whether you're running on a single PC or on multiple devices around your home."
description_ger="Roon ist anders konzipiert als die meisten verfügbaren Audiosysteme. Roon besteht aus einem einzigen Core und beliebig vielen Steuerungs- und Wiedergabegeräten zusammen. Somit erhältst du immer das gleiche Erlebnis, egal ob du nur einen einzelnen PC verwendest oder verschiedene Geräte, die in deinem Wohnbereich zur Verfügung stehen."
arch="x86_64"
maintainer="Christopher Rieke"
maintainer_url="https://roononnas.org"
support_url="https://community.roonlabs.com"
helpurl="https://community.roonlabs.com"
os_min_ver="7.0-40000"
beta="yes"
thirdparty="yes"
[ "$(caller)" != "0 NULL" ] && return 0
pkg_dump_info
