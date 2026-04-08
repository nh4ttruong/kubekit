#!/bin/bash

GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
RESET=$(tput sgr0)
K_ALIAS_MODE_WITH_SHORT="with-short-alias"
K_ALIAS_MODE_WITHOUT_SHORT="no-short-alias"

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi

info() {
    echo "${BLUE}INFO: ${RESET}$1"
}

error() {
    echo "${RED}ERROR: ${RESET}$1" >&2
}

append_if_missing() {
    local line="$1"
    local file="$2"

    touch "$file"
    if ! grep -Fqx "$line" "$file"; then
        echo "$line" >> "$file"
    fi
}

detect_os() {
    case "$(uname -s)" in
        Linux*)
            echo "linux"
            ;;
        Darwin*)
            echo "darwin"
            ;;
        *)
            error "Unsupported OS: $(uname -s)"
            exit 1
            ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            error "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac
}

install_bash_completion() {
    if command -v apt-get &> /dev/null; then
        if ! dpkg -l | grep -q bash-completion; then
            $SUDO apt-get update
            $SUDO apt-get install -y bash-completion
        fi
    elif command -v yum &> /dev/null; then
        if ! rpm -q bash-completion &> /dev/null; then
            $SUDO yum install -y bash-completion
        fi
    elif command -v dnf &> /dev/null; then
        if ! rpm -q bash-completion &> /dev/null; then
            $SUDO dnf install -y bash-completion
        fi
    elif command -v brew &> /dev/null; then
        if ! brew list bash-completion &> /dev/null; then
            brew install bash-completion
        fi
    else
        error "Unsupported package manager. Please install bash-completion manually."
        exit 1
    fi
}

check_tool_installed() {
    if command -v "$1" &>/dev/null; then
        info "$1 is already installed."
        return 0
    fi

    return 1
}

install_binary() {
    local binary_path="$1"
    local binary_name="$2"

    $SUDO install -m 0755 "$binary_path" "/usr/local/bin/$binary_name"
}

extract_json_tag_name() {
    local url="$1"
    local raw

    raw=$(curl -fsSL "$url")
    if command -v jq >/dev/null 2>&1; then
        echo "$raw" | jq -r '.tag_name // empty'
    else
        echo "$raw" | grep -m1 '"tag_name":' | sed -E 's/.*"tag_name":[[:space:]]*"([^"]+)".*/\1/'
    fi
}

validate_version() {
    local version="$1"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$ ]]; then
        return 1
    fi
    return 0
}

install_kubectl() {
    if check_tool_installed kubectl; then
        return
    fi

    local os arch
    os=$(detect_os)
    arch=$(detect_arch)

    local stable_version
    stable_version=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
    if [ -z "$stable_version" ]; then
        error "Failed to determine latest kubectl version."
        exit 1
    fi

    info "Installing kubectl ${stable_version}..."
    curl -fsSLO "https://dl.k8s.io/release/${stable_version}/bin/${os}/${arch}/kubectl"
    chmod +x kubectl
    install_binary "./kubectl" "kubectl"
    rm -f kubectl
}

install_helm() {
    if check_tool_installed helm; then
        return
    fi

    local os arch version tmp_dir
    os=$(detect_os)
    arch=$(detect_arch)

    version=$(extract_json_tag_name "https://api.github.com/repos/helm/helm/releases/latest")
    version=${version#v}
    if [ -z "$version" ] || ! validate_version "$version"; then
        error "Failed to determine latest Helm version."
        exit 1
    fi

    info "Installing helm v${version}..."
    tmp_dir=$(mktemp -d)
    curl -fsSL "https://get.helm.sh/helm-v${version}-${os}-${arch}.tar.gz" -o "${tmp_dir}/helm.tar.gz"
    tar -xzf "${tmp_dir}/helm.tar.gz" -C "$tmp_dir"
    install_binary "${tmp_dir}/${os}-${arch}/helm" "helm"
    rm -rf "$tmp_dir"
}

install_kustomize() {
    if check_tool_installed kustomize; then
        return
    fi

    local os arch version tmp_dir
    os=$(detect_os)
    arch=$(detect_arch)

    version=$(extract_json_tag_name "https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest")
    version=${version#kustomize/}
    if [ -z "$version" ] || ! validate_version "$version"; then
        error "Failed to determine latest Kustomize version."
        exit 1
    fi

    info "Installing kustomize ${version}..."
    tmp_dir=$(mktemp -d)
    curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${version}/kustomize_${version}_${os}_${arch}.tar.gz" -o "${tmp_dir}/kustomize.tar.gz"
    tar -xzf "${tmp_dir}/kustomize.tar.gz" -C "$tmp_dir"
    install_binary "${tmp_dir}/kustomize" "kustomize"
    rm -rf "$tmp_dir"
}

configure_tool_completion() {
    local shell_rc="$1"
    local shell_type="$2"
    local tool="$3"

    if ! command -v "$tool" >/dev/null 2>&1; then
        return
    fi

    if [ "$shell_type" = "zsh" ]; then
        append_if_missing "source <($tool completion zsh)" "$shell_rc"
    elif [ "$shell_type" = "bash" ]; then
        append_if_missing "source <($tool completion bash)" "$shell_rc"
    fi
}

configure_kubectl_short_alias_completion() {
    local shell_rc="$1"
    local shell_type="$2"

    if [ "$shell_type" = "zsh" ]; then
        append_if_missing "alias k=kubectl" "$shell_rc"
        append_if_missing "compdef __start_kubectl k" "$shell_rc"
    elif [ "$shell_type" = "bash" ]; then
        append_if_missing "alias k=kubectl" "$shell_rc"
        append_if_missing "complete -o default -F __start_kubectl k" "$shell_rc"
    fi
}

enable_cli_autocompletion() {
    local shell_rc shell_type k_alias_mode="${1:-$K_ALIAS_MODE_WITH_SHORT}"

    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_type="zsh"
        shell_rc="$HOME/.zshrc"
        append_if_missing "autoload -Uz compinit" "$shell_rc"
        append_if_missing "compinit" "$shell_rc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_type="bash"
        shell_rc="$HOME/.bashrc"
        install_bash_completion
    else
        error "Unsupported shell. Please configure autocompletion manually."
        return
    fi

    info "Configuring kubectl, helm and kustomize autocompletion for ${shell_type}..."
    configure_tool_completion "$shell_rc" "$shell_type" kubectl
    configure_tool_completion "$shell_rc" "$shell_type" helm
    configure_tool_completion "$shell_rc" "$shell_type" kustomize
    if [ "$k_alias_mode" = "$K_ALIAS_MODE_WITH_SHORT" ]; then
        configure_kubectl_short_alias_completion "$shell_rc" "$shell_type"
    fi

    info "Reload your shell config to use completion: source ${shell_rc}"
}

install_kc_kn() {
    local script_dir
    script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

    if [ -f "${script_dir}/kc.sh" ] && [ -f "${script_dir}/kn.sh" ]; then
        $SUDO rm -f /usr/local/bin/kn /usr/local/bin/kc
        chmod +x "${script_dir}/kc.sh" "${script_dir}/kn.sh"
        $SUDO cp -f "${script_dir}/kc.sh" /usr/local/bin/kc
        $SUDO cp -f "${script_dir}/kn.sh" /usr/local/bin/kn

        info "kc and kn aliases are installed."
    else
        info "Downloading kc.sh and kn.sh from repository..."
        curl -fsSL "https://github.com/nh4ttruong/kubekit/raw/main/kc.sh" -o kc.sh
        curl -fsSL "https://github.com/nh4ttruong/kubekit/raw/main/kn.sh" -o kn.sh
        chmod +x kc.sh kn.sh
        $SUDO mv kc.sh /usr/local/bin/kc
        $SUDO mv kn.sh /usr/local/bin/kn
    fi
}

enable_kc_kn_autocompletion() {
    local shell_rc script_dir
    script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

    if [[ "$SHELL" == *"bash"* ]]; then
        info "Configuring kc & kn autocompletion for bash..."
        if [ -f "${script_dir}/completion/_bash_kn" ] && [ -f "${script_dir}/completion/_bash_kc" ]; then
            $SUDO cp -f "${script_dir}/completion/_bash_kn" /etc/bash_completion.d/_kn
            $SUDO cp -f "${script_dir}/completion/_bash_kc" /etc/bash_completion.d/_kc
        else
            $SUDO curl -fsSL https://github.com/nh4ttruong/kubekit/raw/main/completion/_bash_kn -o /etc/bash_completion.d/_kn
            $SUDO curl -fsSL https://github.com/nh4ttruong/kubekit/raw/main/completion/_bash_kc -o /etc/bash_completion.d/_kc
        fi

        shell_rc="$HOME/.bashrc"
        append_if_missing "source /etc/bash_completion" "$shell_rc"
        info "Reload your shell config to use completion: source ${shell_rc}"
    elif [[ "$SHELL" == *"zsh"* ]]; then
        info "Configuring kc & kn autocompletion for zsh..."
        $SUDO mkdir -p /usr/local/share/zsh/site-functions

        if [ -f "${script_dir}/completion/_zsh_kn" ] && [ -f "${script_dir}/completion/_zsh_kc" ]; then
            $SUDO cp -f "${script_dir}/completion/_zsh_kn" /usr/local/share/zsh/site-functions/_kn
            $SUDO cp -f "${script_dir}/completion/_zsh_kc" /usr/local/share/zsh/site-functions/_kc
        else
            $SUDO curl -fsSL https://github.com/nh4ttruong/kubekit/raw/main/completion/_zsh_kn -o /usr/local/share/zsh/site-functions/_kn
            $SUDO curl -fsSL https://github.com/nh4ttruong/kubekit/raw/main/completion/_zsh_kc -o /usr/local/share/zsh/site-functions/_kc
        fi

        shell_rc="$HOME/.zshrc"
        append_if_missing 'fpath=($fpath /usr/local/share/zsh/site-functions)' "$shell_rc"
        info "Reload your shell config to use completion: source ${shell_rc}"
    else
        error "Unsupported shell. Please configure autocompletion manually."
    fi
}

usage() {
    cat <<'USAGE'
Usage: ./install.sh [options]

Options:
  -a, --alias      Install aliases (default behavior; kept for compatibility)
      --no-aliases Skip alias setup for kc/kn and kubectl short alias k
  -h, --help       Show this help message
USAGE
}

main() {
    local install_aliases=true

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--alias)
                install_aliases=true
                shift
                ;;
            --no-aliases)
                install_aliases=false
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    install_kubectl
    install_helm
    install_kustomize
    if [ "$install_aliases" = true ]; then
        enable_cli_autocompletion
    else
        enable_cli_autocompletion "$K_ALIAS_MODE_WITHOUT_SHORT"
    fi

    if [ "$install_aliases" = true ]; then
        install_kc_kn
        enable_kc_kn_autocompletion
    fi
}

main "$@"
