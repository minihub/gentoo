# Gentoo Stage3 Downloader Script


A simple and convenient way to download the latest Gentoo Stage3 tarball for a specified architecture.

## What is this script?


This script downloads the latest Gentoo Stage3 tarball for a specified architecture. It provides a simple and convenient way to obtain the latest Gentoo Stage3 tarball, which can be used to install Gentoo Linux on a new system.

## Features


* Downloads the latest Gentoo Stage3 tarball for a specified architecture
* Provides a simple and convenient way to obtain the latest Gentoo Stage3 tarball
* Supports multiple architectures (alpha, amd64, arm, arm64, hppa, ia64, loong, m68k, mips, ppc, riscv, s390, sh, sparc, x86)
* Verifies the integrity of the downloaded tarball using SHA256 checksums

## Usage


To use this script, simply run it with the following command:
```bash
./gentoo-stage3-downloader.sh
```
You will be prompted to select an architecture and a stage3 tarball to download.

## Options


* `-v` : Show version information
* `-h` : Show this help message

## Requirements


* Bash 4.0 or later
* curl 7.0 or later
* sha256sum 1.0 or later

## Installation


To install this script, simply clone this repository and make the script executable:
```bash
git clone https://github.com/your-username/gentoo-stage3-downloader.git
cd gentoo-stage3-downloader
chmod +x gentoo-stage3-downloader.sh
```
## Contributing


Contributions are welcome! If you have any suggestions or bug reports, please open an issue or submit a pull request.

## License


This script is licensed under the MIT License. See the LICENSE file for more information.

I hope this README helps! Let me know if you need any further assistance.
