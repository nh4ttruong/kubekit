#!/bin/bash

GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

install_bash_completion() {
    if command -v apt-get &> /dev/null; then
        if ! dpkg -l | grep -q bash-completion; then
            sudo apt-get update
            sudo apt-get install -y bash-completion
        fi
    elif command -v yum &> /dev/null; then
        if ! rpm -q bash-completion &> /dev/null; then
            sudo yum install -y bash-completion
        fi
    elif command -v brew &> /dev/null; then
        if ! brew list bash-completion &> /dev/null; then
            brew install bash-completion
        fi
    else
        echo "${RED}ERROR: ${RESET}Unsupported package manager. Please install bash-completion manually."
        exit 1
    fi
}

check_kubectl_installed() {
    if ! command -v kubectl &>/dev/null; then
        echo "${BLUE}INFO: ${RESET}kubectl is not installed."
        return 0
    else
        echo "${BLUE}INFO: ${RESET}kubectl is already installed. Run 'kubectl version --output=yaml' for more information."
        return 1
    fi
}

install_kubectl_linux() {
    echo "${BLUE}INFO: ${RESET}Installing kubectl..."
    ARCH=$(uname -m)
    if [ "$ARCH" == "x86_64" ]; then
        ARCH="amd64"
    elif [ "$ARCH" == "aarch64" ]; then
        ARCH="arm64"
    else
        echo "${RED}ERROR: ${RESET}Unsupported architecture: $ARCH"
        exit 1
    fi

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$ARCH/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

    echo "${BLUE}INFO: ${RESET}Please ensure you have bash-completion installed in your Linux environment."

    enable_autocompletion
}

install_kubectl_macos() {
    echo "${BLUE}INFO: ${RESET}Installing kubectl..."
    ARCH=$(uname -m)
    if [ "$ARCH" == "x86_64" ]; then
        ARCH="amd64"
    elif [ "$ARCH" == "arm64" ]; then
        ARCH="arm64"
    else
        echo "${RED}ERROR: ${RESET}Unsupported architecture: $ARCH"
        exit 1
    fi

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/$ARCH/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

    echo "${BLUE}INFO: ${RESET}Please ensure you have bash-completion installed in your macOS environment."

    enable_autocompletion
}

install_kubectl_windows() {
    echo "${BLUE}INFO: ${RESET}Installing kubectl..."
    ARCH=$(uname -m)
    if [ "$ARCH" == "x86_64" ]; then
        ARCH="amd64"
    elif [ "$ARCH" == "aarch64" ]; then
        ARCH="arm64"
    else
        echo "${RED}ERROR: ${RESET}Unsupported architecture: $ARCH"
        exit 1
    fi

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/windows/$ARCH/kubectl.exe"
    chmod +x kubectl.exe
    sudo mv kubectl.exe /usr/local/bin/

    echo "${BLUE}INFO: ${RESET}Please ensure you have bash-completion installed in your WSL environment."

    enable_autocompletion
}

install_kc_kn() {
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

    if [ -f "${SCRIPT_DIR}/kc.sh" ] && [ -f "${SCRIPT_DIR}/kn.sh" ]; then
        sudo rm -f /usr/local/bin/kn /usr/local/bin/kc
        chmod +x "${SCRIPT_DIR}/kc.sh" "${SCRIPT_DIR}/kn.sh"
        sudo cp -f "${SCRIPT_DIR}/kc.sh" /usr/local/bin/kc
        sudo cp -f "${SCRIPT_DIR}/kn.sh" /usr/local/bin/kn

        echo "${BLUE}INFO: ${RESET}kc and kn aliases are installed."
    else
        echo "${BLUE}INFO: ${RESET}Downloading 'kc.sh' and 'kn.sh' from repository..."
        curl -sL "https://github.com/nh4ttruong/kubekit/raw/main/kc.sh" -o kc.sh
        curl -sL "https://github.com/nh4ttruong/kubekit/raw/main/kn.sh" -o kn.sh
        chmod +x kc.sh kn.sh
        sudo mv kc.sh /usr/local/bin/kc
        sudo mv kn.sh /usr/local/bin/kn
    fi
}

enable_autocompletion() {
    echo 'source <(kubectl completion bash)' >>~/.bashrc
    source <(kubectl completion bash)
    echo 'alias k=kubectl' >>~/.bashrc
    echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
}

main() {
    INSTALL_KUBECTL=true
    INSTALL_KC_KN=false

    if ! check_kubectl_installed; then
        INSTALL_KUBECTL=false
    fi

    # Parse command-line options
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -a|--alias)
            INSTALL_KC_KN=true
            shift
            ;;
            *)
            echo "Unknown option: $key"
            exit 1
            ;;
        esac
    done

    if [ "$INSTALL_KUBECTL" = true ]; then
        case "$(uname -s)" in
            Linux*)
                install_kubectl_linux
                install_bash_completion
                ;;
            Darwin*)
                install_kubectl_macos
                install_bash_completion
                ;;
            MINGW*|CYGWIN*|MSYS*) 
                echo "${BLUE}INFO: ${RESET}Please ensure you have bash-completion installed in your WSL environment."
                install_kubectl_windows 
                ;;
            *)          
                echo "${RED}ERROR: ${RESET}Unsupported OS. Please install kubectl manually." 
                ;;
        esac
    fi

    if [ "$INSTALL_KC_KN" = true ]; then
        install_kc_kn
    fi
}

main "$@"
