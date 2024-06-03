#!/bin/bash

GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

usage() {
    echo "Usage: kc [context-name]"
    echo "       kc -l"
    echo "       kc -h"
    echo
    echo "Options:"
    echo "  context-name   Switch to the specified context"
    echo "  -l, --list     List all available contexts"
    echo "  -h, --help     Show this help message"
}

check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo "${RED}ERROR: ${RESET}kubectl is not installed." >&2
        exit 1
    fi
}

list_contexts() {
    all_contexts=$(kubectl config get-contexts | sed 1d | awk '{print $2}')
    current_context=$(kubectl config current-context)

    if [ -z "$current_context" ]; then
        echo "${BLUE}INFO: ${RESET}Current context is not set. Set using 'kc <context>'."
        echo "$all_contexts"
    else
        current_context_line_number=$(echo "$all_contexts" | grep -n -w "$current_context" | cut -d':' -f1)
        if [ -n "$current_context_line_number" ]; then
            echo "[+] Current context: ${GREEN}${current_context}${RESET}"
        else
            echo "$all_contexts"
            echo "${RED}ERROR: ${RESET}Current context '$current_context' is not in the list of contexts."
        fi
    fi
}

switch_context() {
    if kubectl config use-context "$1" &> /dev/null; then
        echo "[+] Switched to context: ${GREEN}${1}${RESET}"
    else
        echo "${RED}ERROR: ${RESET}Failed to switch context to ${RED}$1${RESET}" >&2
    fi
}

main() {
    check_kubectl

    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        usage
    elif [ "$1" == "-l" ] || [ "$1" == "--list" ]; then
        list_contexts
    elif [ -z "$1" ]; then
        list_contexts
    else
        switch_context "$1"
    fi
}

main "$@"
