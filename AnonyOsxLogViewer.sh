#!/bin/bash
# Enhanced Log Parser for Anonymizer Universal
# Original by megalithe on 07/27/2017
# Enhanced version with improved error handling and cross-platform support

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Color codes for output formatting
readonly ESC_SEQ="\x1b["
readonly NC="\033[0m"        # No Color
readonly RED="${ESC_SEQ}31;01m"
readonly GREEN="${ESC_SEQ}32;01m"
readonly YELLOW="${ESC_SEQ}33;01m"
readonly BLUE="${ESC_SEQ}34;01m"

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly SEARCH_TERMS="anonymizer|Anonymizer"
readonly CONTEXT_LINES=2

# Function to display colored output
print_color() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Function to display script usage
show_usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

This script finds and parses the most recently modified .log file for Anonymizer Universal entries.

OPTIONS:
    -d, --directory DIR    Specify directory to search (default: ~/Downloads)
    -f, --file FILE        Specify exact log file to parse
    -s, --search PATTERN   Custom search pattern (default: anonymizer|Anonymizer)
    -c, --context N        Lines of context around matches (default: 2)
    -h, --help             Show this help message

EXAMPLES:
    $SCRIPT_NAME                           # Use default Downloads directory
    $SCRIPT_NAME -d /var/log               # Search in /var/log directory
    $SCRIPT_NAME -f myapp.log              # Parse specific file
    $SCRIPT_NAME -s "error|warning" -c 3   # Custom search with 3 lines context

EOF
}

# Function to find the most recent log file
find_latest_log() {
    local search_dir="$1"
    
    if [[ ! -d "$search_dir" ]]; then
        print_color "$RED" "Error: Directory '$search_dir' does not exist or is not accessible."
        return 1
    fi
    
    # Find the most recent .log file, handling filenames with spaces
    local latest_log
    latest_log=$(find "$search_dir" -maxdepth 1 -name "*.log" -type f -print0 2>/dev/null | \
                 xargs -0 ls -t 2>/dev/null | head -n 1)
    
    if [[ -z "$latest_log" ]]; then
        print_color "$RED" "Error: No .log files found in '$search_dir'"
        return 1
    fi
    
    echo "$latest_log"
}

# Function to validate file exists and is readable
validate_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        print_color "$RED" "Error: File '$file' does not exist."
        return 1
    fi
    
    if [[ ! -r "$file" ]]; then
        print_color "$RED" "Error: File '$file' is not readable."
        return 1
    fi
    
    return 0
}

# Function to parse log file
parse_log() {
    local log_file="$1"
    local search_pattern="$2"
    local context="$3"
    
    print_color "$BLUE" "Parsing file: $log_file"
    print_color "$BLUE" "Search pattern: $search_pattern"
    print_color "$BLUE" "Context lines: $context"
    echo
    
    # Check if file contains any matches
    if ! grep -q -E "$search_pattern" "$log_file" 2>/dev/null; then
        print_color "$YELLOW" "No matches found for pattern '$search_pattern' in $log_file"
        return 0
    fi
    
    # Display matches with context
    print_color "$GREEN" "=== Matches found ==="
    echo
    
    # Use grep with context and add line numbers
    grep -n -E -C "$context" "$search_pattern" "$log_file" | \
    while IFS= read -r line; do
        if [[ "$line" =~ ^[0-9]+--.* ]]; then
            # Separator line
            print_color "$BLUE" "$line"
        elif [[ "$line" =~ .*($search_pattern).* ]]; then
            # Matching line - highlight it
            print_color "$GREEN" "$line"
        else
            # Context line
            echo "$line"
        fi
    done
}

# Function to get user confirmation
get_user_confirmation() {
    local prompt="$1"
    local response
    
    while true; do
        read -r -p "$prompt [y/N]: " response
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]|"") return 1 ;;
            *) print_color "$RED" "Please answer yes (y) or no (n)." ;;
        esac
    done
}

# Main function
main() {
    local search_dir="$HOME/Downloads"
    local log_file=""
    local search_pattern="$SEARCH_TERMS"
    local context="$CONTEXT_LINES"
    local auto_confirm=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--directory)
                search_dir="$2"
                shift 2
                ;;
            -f|--file)
                log_file="$2"
                shift 2
                ;;
            -s|--search)
                search_pattern="$2"
                shift 2
                ;;
            -c|--context)
                if [[ "$2" =~ ^[0-9]+$ ]]; then
                    context="$2"
                else
                    print_color "$RED" "Error: Context must be a number"
                    exit 1
                fi
                shift 2
                ;;
            -y|--yes)
                auto_confirm=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_color "$RED" "Error: Unknown option '$1'"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Expand tilde in search directory
    search_dir="${search_dir/#\~/$HOME}"
    
    echo
    print_color "$BLUE" "=== Enhanced Log Parser for Anonymizer Universal ==="
    echo
    
    # Determine which file to process
    if [[ -n "$log_file" ]]; then
        # User specified a file
        if [[ "$log_file" != /* ]]; then
            # Relative path - check in search directory first, then current directory
            if [[ -f "$search_dir/$log_file" ]]; then
                log_file="$search_dir/$log_file"
            elif [[ -f "./$log_file" ]]; then
                log_file="./$log_file"
            fi
        fi
    else
        # Find the most recent log file
        print_color "$YELLOW" "Searching for the most recent .log file in: $search_dir"
        
        if ! log_file=$(find_latest_log "$search_dir"); then
            exit 1
        fi
        
        print_color "$GREEN" "Most recent log file: $(basename "$log_file")"
        echo
        
        # Get user confirmation unless auto-confirm is enabled
        if [[ "$auto_confirm" == false ]]; then
            if ! get_user_confirmation "Do you want to parse this file?"; then
                print_color "$YELLOW" "Operation cancelled by user."
                echo
                print_color "$BLUE" "Tips:"
                echo "  • Ensure the correct .log file is in $search_dir"
                echo "  • Use -f option to specify a different file"
                echo "  • Use -d option to search in a different directory"
                echo "  • Use -h for more options"
                exit 0
            fi
        fi
    fi
    
    # Validate the file
    if ! validate_file "$log_file"; then
        exit 1
    fi
    
    echo
    
    # Parse the log file
    parse_log "$log_file" "$search_pattern" "$context"
    
    echo
    print_color "$GREEN" "=== Parsing complete ==="
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
