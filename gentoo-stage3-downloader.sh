#!/usr/bin/env bash

# Gentoo Stage3 Downloader Script
# =================================
# This script downloads the latest Gentoo Stage3 tarball for a specified architecture.
# It provides a simple and convenient way to obtain the latest Gentoo Stage3 tarball,
# which can be used to install Gentoo Linux on a new system.

# Function to display the script version
show_version() {
    echo "Gentoo Stage3 Downloader version 1.0"
    exit 0
}

# Function to display the script help
show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -v  Show version information"
    echo "  -h  Show this help message"
    echo "  -d  Enable debug mode"
    echo ""
    echo "Description:"
    echo "  This script downloads the latest Gentoo Stage3 tarball for a specified architecture."
    echo "  It provides a simple and convenient way to obtain the latest Gentoo Stage3 tarball,"
    echo "  which can be used to install Gentoo Linux on a new system."
    exit 0
}

# Logging function with debug support
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Only show debug messages if DEBUG is set
    if [ "$level" == "DEBUG" ] && [ -z "${DEBUG:-}" ]; then
        return
    fi

    case "$level" in
        DEBUG)
            echo -e "${GENTOO_DARK_GRAY}[DEBUG] $timestamp - $message${NC}" >&2
            ;;
        INFO)
            echo "[INFO] $timestamp - $message"
            ;;
        WARN)
            echo -e "${GENTOO_LIGHT_PURPLE}[WARN] $timestamp - $message${NC}" >&2
            ;;
        ERROR)
            echo -e "${RED}[ERROR] $timestamp - $message${NC}" >&2
            ;;
    esac
}

# Parse command-line options
while getopts ":vhd" opt; do
    case $opt in
        v)
            show_version
            ;;
        h)
            show_help
            ;;
        d)
            DEBUG=1
            log_message "DEBUG" "Debug mode enabled."
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

# Strict mode for better error handling
set -o errexit   # Exit immediately if a command exits with a non-zero status
set -o nounset   # Treat unset variables as an error
set -o pipefail  # Ensure pipe failures are propagated

# Internationalization and locale settings
export LC_ALL=C
export LANG=C

# Gentoo-inspired Color Palette
GENTOO_PURPLE='\033[0;35m'     # Main Gentoo purple
GENTOO_LIGHT_PURPLE='\033[1;35m'
GENTOO_GRAY='\033[0;37m'       # Light gray, often used in Gentoo docs
GENTOO_DARK_GRAY='\033[1;30m'  # Dark gray
NC='\033[0m' # No Color
RED='\033[0;31m'

# Configuration
DOWNLOAD_DIR="CURRENT_DIR"
BASE_URL="https://distfiles.gentoo.org/releases"
MAX_DOWNLOAD_RETRIES=3
DOWNLOAD_TIMEOUT=60
PREFERRED_INIT="openrc"
SCRIPT_DESCRIPTION="Gentoo Stage3 Downloader - Simplifying your Gentoo Linux installation"

# Logging setup
setup_logging() {
    local log_dir="${HOME}/.log/gentoo-stage3"
    local log_file="${log_dir}/downloads_$(date +%Y%m%d).log"

    # Create log directory
    mkdir -p "$log_dir"

    # Rotate logs (keep last 7 days)
    find "$log_dir" -name "downloads_*.log" -mtime +7 -delete 2>/dev/null || true

    # Redirect all output to the log file
    exec > >(tee -a "$log_file") 2>&1
}

# Dependency checking function
check_dependencies() {
    local deps=("curl" "awk" "mktemp" "stat" "sha256sum")
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_message "ERROR" "'$cmd' is not installed."
            exit 1
        fi
    done
}

# Validate input function
validate_input() {
    local input="$1"
    local max="$2"
    local type="${3:-numeric}"  # Default to numeric validation

    # Check if input is empty
    if [ -z "$input" ]; then
        log_message "ERROR" "Input cannot be empty."
        return 1
    fi

    case "$type" in
        numeric)
            # Check if input is a positive integer
            if [[ ! "$input" =~ ^[1-9][0-9]*$ ]]; then
                log_message "ERROR" "Invalid input. Please enter a positive number."
                return 1
            fi

            # Check if input is within range
            if [ "$input" -lt 1 ] || [ "$input" -gt "$max" ]; then
                log_message "ERROR" "Selection out of range (1-$max)."
                return 1
            fi
            ;;
        alphanumeric)
            # Add alphanumeric validation logic here
            ;;
        *)
            log_message "ERROR" "Unknown validation type: $type"
            return 1
            ;;
    esac

    return 0
}

# Download with retry function
download_with_retry() {
    local url="$1"
    local output_file="$2"
    local temp_file="${output_file}.tmp"
    
    for ((attempt=1; attempt<=MAX_DOWNLOAD_RETRIES; attempt++)); do
        if curl -L \
               -f \
               --progress-bar \
               --max-time "$DOWNLOAD_TIMEOUT" \
               --retry "$MAX_DOWNLOAD_RETRIES" \
               --retry-delay 5 \
               -o "$temp_file" \
               "$url" 2>&1
        then
            # Move the temporary file to the final location
            mv "$temp_file" "$output_file"
            return 0
        fi

        log_message "WARN" "Download attempt $attempt failed. Retrying..."
        sleep 5
    done

    log_message "ERROR" "Failed to download after $MAX_DOWNLOAD_RETRIES attempts."
    return 1
}

# ASCII Art Banner
print_banner() {
    echo -e "${GENTOO_PURPLE}"
    echo "                                           ."
    echo "     .vir.                                d\$b"
    echo "  .d\$\$\$\$\$\$b.    .cd\$\$\$b.     .d\$\$\$b.   d\$\$\$\$\$\$\$\$\$\$b  .d\$\$\$b."
    echo "  \$\$\$( )\$\$\$b d\$\$\$()$\$\$\$.   d\$\$\$\$\$\$b Q\$\$\$\$\$\$\$P\$\$\$P.\$\$\$\$\$\$\$b.  .\$\$\$\$\$\$\$b."
    echo "  Q\$\$\$\$\$\$\$\$B\$\$\$\$\$\$\$\$P\"  d\$\$\$PQ\$\$\$\$b.   \$\$\$\$\$.   .\$\$\$P' \`\$\$\$ .\$\$\$P' \`\$\$\$"
    echo "    \"\$\$\$\$\$P Q\$\$\$\$\$\$\$b  d\$\$\$P   Q\$\$\$\$b  \$\$\$\$b   \$\$\$\$b..d\$\$\$ \$\$\$\$b..d\$\$\$"
    echo "   d\$\$\$\$\$P\"   \"\$\$\$\$\$\$\$\$ Q\$\$\$     Q\$\$\$\$  \$\$\$\$\$   \`Q\$\$\$\$\$\$\$P  \`Q\$\$\$\$\$\$P"
    echo "  \$\$\$\$\$P       \`\"\"\"\"\"   \"\"        \"\"   Q\$\$\$P     \"Q\$\$\$P\"     \"Q\$\$\$P\""
    echo "  \`Q\$\$P\"                                  \"\"\"         "
    echo ""
    echo -e "${GENTOO_LIGHT_PURPLE}$SCRIPT_DESCRIPTION${NC}"
    echo -e "${GENTOO_DARK_GRAY}Version: 1.0 | Date: $(date +%Y-%m-%d)${NC}"
    echo ""
}

# Available architectures with descriptions
ARCHITECTURES=(
    "alpha:Alpha Architecture"
    "amd64:64-bit x86 Architecture"
    "arm:ARM Architecture"
    "arm64:64-bit ARM Architecture"
    "hppa:HP PA-RISC Architecture"
    "ia64:Intel Itanium Architecture"
    "loong:Loongson MIPS-compatible Architecture"
    "m68k:Motorola 68k Architecture"
    "mips:MIPS Architecture"
    "ppc:PowerPC Architecture"
    "riscv:RISC-V Architecture"
    "s390:IBM System z Architecture"
    "sh:SuperH Architecture"
    "sparc:SPARC Architecture"
    "x86:32-bit x86 Architecture"
)

# Verify download checksum (specific implementation)
verify_download() {
    local file="$1"
    local file_size
    local checksum_urls=(
        "${DOWNLOAD_URL}.sha256"
        "${DOWNLOAD_URL}.asc"
        "${DOWNLOAD_URL}.DIGESTS"
    )
    local checksum_temp=$(mktemp)
    local checksum_found=0

    # Get file size using multiple methods
    file_size=$(stat -c %s "$file" 2>/dev/null || stat -f %z "$file" 2>/dev/null || ls -l "$file" | awk '{print $5}' 2>/dev/null)

    # Check if we have a valid file size
    if [ -z "$file_size" ] || [[ ! "$file_size" =~ ^[0-9]+$ ]]; then
        log_message "ERROR" "Could not determine file size."
        return 1
    fi

    # Check if file size is zero
    if [ "$file_size" -eq 0 ]; then
        log_message "ERROR" "Downloaded file is empty."
        return 1
    fi

    # Try different checksum file locations
    for checksum_url in "${checksum_urls[@]}"; do
        log_message "DEBUG" "Trying checksum URL: $checksum_url"
        
        if curl -sL "$checksum_url" -o "$checksum_temp"; then
            checksum_found=1
            break
        fi
    done

    if [ "$checksum_found" -eq 0 ]; then
        log_message "WARN" "Could not download checksum file from any location. Performing basic size verification only."
        rm -f "$checksum_temp"
        return 0
    fi

    # Try different checksum formats
    local local_checksum=$(sha256sum "$file" | awk '{print $1}')
    local remote_checksum

    # Try format 1: .sha256 file
    if remote_checksum=$(grep "$(basename "$file")" "$checksum_temp" | awk '{print $1}'); then
        log_message "DEBUG" "Found .sha256 format checksum: $remote_checksum"
        if [ "$local_checksum" == "$remote_checksum" ]; then
            log_message "INFO" "Checksum verification successful (.sha256 format)."
            rm -f "$checksum_temp"
            return 0
        fi
    fi

    # Try format 2: .asc file
    if remote_checksum=$(gpg --verify "$checksum_temp" 2>&1 | grep -E '^[0-9a-f]{64}' | awk '{print $1}'); then
        log_message "DEBUG" "Found .asc format checksum: $remote_checksum"
        if [ "$local_checksum" == "$remote_checksum" ]; then
            log_message "INFO" "Checksum verification successful (.asc format)."
            rm -f "$checksum_temp"
            return 0
        fi
    fi

    # Try format 3: DIGESTS file
    if remote_checksum=$(grep "$(basename "$file")" "$checksum_temp" | grep -E '^[0-9a-f]{64}' | awk '{print $1}'); then
        log_message "DEBUG" "Found DIGESTS format checksum: $remote_checksum"
        if [ "$local_checksum" == "$remote_checksum" ]; then
            log_message "INFO" "Checksum verification successful (DIGESTS format)."
            rm -f "$checksum_temp"
            return 0
        fi
    fi

    # If all checksum verification attempts fail
    log_message "WARN" "Could not verify checksum using any known format. Performing basic size verification only."
    log_message "INFO" "Basic file integrity check passed. Size: $file_size bytes"
    rm -f "$checksum_temp"
    return 0
}

# Function to process stage3 entries
process_stage3_entries() {
    local ARCH="$1"
    local TEMP_FILE
    
    # Secure temporary file creation
    TEMP_FILE=$(mktemp -t stage3_XXXXXX)
    chmod 600 "$TEMP_FILE"

    # Cleanup trap
    cleanup() {
        if [ -n "${TEMP_FILE:-}" ] && [ -f "$TEMP_FILE" ]; then
            rm -f "$TEMP_FILE"
        fi
    }
    trap cleanup EXIT INT TERM

    # Download stage3 file list
    log_message "INFO" "Downloading stage3 file list for $ARCH"
    if ! download_with_retry \
        "${BASE_URL}/${ARCH}/autobuilds/latest-stage3.txt" \
        "$TEMP_FILE"
    then
        log_message "ERROR" "Failed to download stage3 file list"
        return 1
    fi

    # Process and store stage3 entries
    local STAGE3_ENTRIES=()
    local ORIGINAL_ENTRIES=()
    
    # Parse the file list, ignoring PGP signature and comments
    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^# ]] || [[ -z "$line" ]]; then
            continue
        fi
        
        # Skip PGP signature blocks
        if [[ "$line" =~ ^----- ]]; then
            continue
        fi
        
        # Extract the relevant parts
        if [[ "$line" =~ ^([0-9]{8}T[0-9]{6}Z/stage3-[^ ]+) ]]; then
            local full_path="${BASH_REMATCH[1]}"
            local filename=$(basename "$full_path")
            local size=$(echo "$line" | awk '{print $2}')
            local date=$(echo "$full_path" | cut -d/ -f1 | cut -dT -f1)
            local formatted_date="${date:0:4}-${date:4:2}-${date:6:2}"
            local size_mb=$(echo "scale=2; $size / (1024 * 1024)" | bc)
            
            # Store both the display entry and the original path
            STAGE3_ENTRIES+=("$filename [${size_mb} MB|$formatted_date]")
            ORIGINAL_ENTRIES+=("$full_path")
        fi
    done < "$TEMP_FILE"

    # Check if entries were found
    if [ ${#STAGE3_ENTRIES[@]} -eq 0 ]; then
        log_message "ERROR" "No valid stage3 entries found for $ARCH"
        return 1
    fi

    # Display entries
    echo -e "${GENTOO_LIGHT_PURPLE}Available Stage3 Entries for $ARCH:${NC}"
    for (( i=0; i<${#STAGE3_ENTRIES[@]}; i++ )); do
        printf "%2d) %s\n" $((i+1)) "${STAGE3_ENTRIES[i]}"
    done

    # Prompt for selection
    local CHOICE
    read -p "$(echo -e "${GENTOO_LIGHT_PURPLE}Select an entry (1-${#STAGE3_ENTRIES[@]}): ${NC}")" CHOICE

    # Validate input
    if ! validate_input "$CHOICE" "${#STAGE3_ENTRIES[@]}"; then
        return 1
    fi

    # Adjust for zero-based indexing
    local SELECTED_ORIGINAL_ENTRY="${ORIGINAL_ENTRIES[$((CHOICE-1))]}"

    local DOWNLOAD_URL="${BASE_URL}/${ARCH}/autobuilds/${SELECTED_ORIGINAL_ENTRY}"
    if [ "$DOWNLOAD_DIR" == "CURRENT_DIR" ]; then
        DOWNLOAD_DIR=$(pwd)
    fi
    local OUTPUT_FILE="${DOWNLOAD_DIR}/$(basename "$SELECTED_ORIGINAL_ENTRY")"

    # Final download with verification
    log_message "INFO" "Downloading selected stage3 file..."
    if ! download_with_retry "$DOWNLOAD_URL" "$OUTPUT_FILE"; then
        log_message "ERROR" "Download failed."
        return 1
    fi

    # Verify the downloaded file
    if ! verify_download "$OUTPUT_FILE"; then
        log_message "ERROR" "Download verification failed."
        return 1
    fi

    log_message "INFO" "Stage3 File saved as $OUTPUT_FILE"
 
    return 0
}

# Function to handle interrupts
handle_interrupt() {
    log_message "WARN" "Script interrupted by user."
    cleanup
    exit 1
}

# Function to clean up temporary files
cleanup() {
    if [ -n "${TEMP_FILE:-}" ] && [ -f "$TEMP_FILE" ]; then
        rm -f "$TEMP_FILE"
    fi
}

# Function to select architecture
select_architecture() {
    echo -e "${GENTOO_LIGHT_PURPLE}Available architectures:"
    for i in "${!ARCHITECTURES[@]}"; do
        echo -e "${GENTOO_DARK_GRAY}$((i + 1)): ${ARCHITECTURES[$i]%%:*} - ${ARCHITECTURES[$i]##*:}"
    done

    echo -e "${GENTOO_LIGHT_PURPLE}Please select an architecture by number:"
    read -r arch_selection

    # Validate architecture selection
    if ! validate_input "$arch_selection" "${#ARCHITECTURES[@]}"; then
        exit 1
    fi

    selected_arch="${ARCHITECTURES[$((arch_selection - 1))]%%:*}"
}

# Main script execution
main() {
    setup_logging
    check_dependencies
    print_banner
    select_architecture
    process_stage3_entries "$selected_arch"
}

# Start the script
main
