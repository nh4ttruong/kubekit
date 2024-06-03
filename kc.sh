#!/bin/bash

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

print_usage() {
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
    contexts_command_output=$(kubectl config get-contexts)
    all_contexts=$(echo "$contexts_command_output" | awk '{print $2}' | sed 1d)
    current_context=$(kubectl config current-context)

    # only print available contexts when there are not empty
    if [ -z "$all_contexts" ]; then
        echo "${RED}ERROR: ${RESET}No contexts available." >&2
        exit 1
    fi

    while IFS= read -r context; do
        if [ "$context" == "$current_context" ]; then
            echo "${GREEN}$context${RESET}"
        else
            echo "$context"
        fi
    done <<< "$all_contexts"
}

switch_context() {
    if kubectl config use-context "$1" &> /dev/null; then
        echo "Switched to context: $1"
    else
        echo "${RED}ERROR: ${RESET}Failed to switch context to ${RED}$1${RESET}" >&2
    fi
}

main() {
    check_kubectl

    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        print_usage
    elif [ "$1" == "-l" ] || [ "$1" == "--list" ]; then
        list_contexts
    elif [ -z "$1" ]; then
        list_contexts
    else
        switch_context "$1"
    fi
}

main "$@"