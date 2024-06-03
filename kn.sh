#!/bin/bash

GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

print_usage() {
    echo "Usage: kn [namespace]"
    echo "       kn -l"
    echo "       kn -h"
    echo
    echo "Options:"
    echo "  namespace      Switch to the specified namespace"
    echo "  -l, --list     List all available namespaces"
    echo "  -h, --help     Show this help message"
}

check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo "${RED}ERROR: ${RESET}kubectl is not installed." >&2
        exit 1
    fi
}

list_namespaces() {
    all_namespaces=$(kubectl get ns | sed 1d | awk '{print $1}')
    current_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')

    if [ -z "$current_namespace" ]; then
        echo "${BLUE}INFO: ${RESET}Current namespace is not set. Set using 'kn <namespace>'."
        echo "$all_namespaces"
    else
        current_namespace_line_number=$(echo "$all_namespaces" | grep -n -w "$current_namespace" | cut -d':' -f1)
        if [ -n "$current_namespace_line_number" ]; then
            echo "${BLUE}[+] Current namespace: ${RESET}${GREEN}${current_namespace}${RESET}"
        else
            echo "$all_namespaces"
            echo "${RED}ERROR: ${RESET}Current namespace '$current_namespace' is not in the list of namespaces."
        fi
    fi
}

switch_namespace() {
    if kubectl get ns "$1" &> /dev/null; then
        kubectl config set-context --current --namespace="$1" > /dev/null 2>&1 && echo "${BLUE}INFO: ${RESET}Current namespace switched to \"${GREEN}$1${RESET}\""
    else
        echo "${RED}ERROR: ${RESET}No namespace exists with the name ${RED}\"$1\"${RESET}"
    fi
}

main() {
    check_kubectl

    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        print_usage
    elif [ "$1" == "-l" ] || [ "$1" == "--list" ]; then
        list_namespaces
    elif [ -z "$1" ]; then
        list_namespaces
    else
        switch_namespace "$1"
    fi
}

main "$@"
