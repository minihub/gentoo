# Gentoo Stage3 Downloader Script

A simple and convenient way to download the latest Gentoo Stage3 tarball for a specified architecture.

## What is this script?

This script downloads the latest Gentoo Stage3 tarball for a specified architecture. It provides a simple and convenient way to obtain the latest Gentoo Stage3 tarball, which can be used to install Gentoo Linux on a new system.

## Features

- **Downloads the latest Gentoo Stage3 tarball** for a specified architecture.
- **Supports multiple architectures**:
  - alpha, amd64, arm, arm64, hppa, ia64, loong, m68k, mips, ppc, riscv, s390, sh, sparc, x86.
- **Verifies the integrity of the downloaded tarball** using SHA256 checksums, GPG signatures, and DIGESTS files.
- **Automatic retries** for failed downloads with configurable retry count and timeout.
- **Logging** with support for debug, info, warn, and error levels.
- **Colorized output** (if the terminal supports it) for better readability.
- **Interactive architecture selection** with descriptions for each architecture.
- **Checks for required dependencies** (curl, awk, mktemp, stat, sha256sum).
- **Supports both color and non-color terminals** for compatibility.

## Usage

To use this script, simply run it with the following command:

```bash
./gentoo-stage3-downloader.sh
```

You will be prompted to select an architecture and a stage3 tarball to download.

### Options

- `-v` : Show version information.
- `-h` : Show this help message.
- `-d` : Enable debug mode (verbose logging).

### Example

```bash
./gentoo-stage3-downloader.sh
```

1. Select an architecture (e.g., `amd64`).
2. Choose a stage3 tarball from the list.
3. The script will download and verify the tarball.

## Requirements

- **Bash 4.0 or later**
- **curl 7.0 or later**
- **sha256sum 1.0 or later**
- **gpg** (optional, for GPG signature verification)

## Installation

To install this script, simply clone this repository and make the script executable:

```bash
git clone https://github.com/minihub/gentoo.git
cd gentoo
chmod +x gentoo-stage3-downloader.sh
```

## Contributing

Contributions are welcome! If you have any suggestions, bug reports, or feature requests, please open an issue or submit a pull request.

## License

This script is licensed under the MIT License. See the [LICENSE](https://github.com/minihub/github/blob/main/LICENSE) file for more information.
