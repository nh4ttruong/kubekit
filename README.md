# KubeKit - Fast Kubernetes Tools Installation & Operation

Managing Kubernetes clusters, contexts, and namespaces can be time-consuming. But fear not! I’ve got you covered with KubeKit smart tools: `kubectl` (with `k` alias), `helm`, `kustomize`, `kc`, and `kn`. These tools will streamline your workflow and make your life easier.

## Motivation

I built KubeKit because preparing a Kubernetes-ready local environment was more complex than it should be. Installing required tools, setting up completions, and wiring shortcuts for daily operations took too many repetitive steps. KubeKit wraps that setup into one installer so you can start operating clusters faster.

## Usage

Once installed, you can use KubeKit to enhance your Kubernetes workflow:

- Use `k` as short version of `kubectl`
- Use `helm` for chart/package operations
- Use `kustomize` for manifest customization
- Use `kc` to manage Kubernetes contexts:
  - `kc`: List available contexts
  - `kc <context-name>`: Switch to the specified context
- Use `kn` to manage Kubernetes namespaces:
  - `kn`: List available namespaces
  - `kn <namespace-name>`: Switch to the specified namespace

For more information on KubeKit usage, refer to run `kc -h` and `kn -h` for help.

## Installation

To install KubeKit, follow these steps:

1. Install everything (core CLI tools + aliases `k`, `kc`, `kn`) with auto-completion:
```bash
curl -sL https://github.com/nh4ttruong/kubekit/raw/main/install.sh | sudo bash
```
2. macOS (zsh):
```zsh
curl -sL https://github.com/nh4ttruong/kubekit/raw/main/install.sh | sudo zsh
```
3. Install only core CLI tools (skip aliases `k`, `kc`, `kn`):
```bash
curl -sL https://github.com/nh4ttruong/kubekit/raw/main/install.sh | sudo bash -s -- --no-aliases
```
4. Skip specific tools when needed:
```bash
curl -sL https://github.com/nh4ttruong/kubekit/raw/main/install.sh | sudo bash -s -- --no-kubectl
curl -sL https://github.com/nh4ttruong/kubekit/raw/main/install.sh | sudo bash -s -- --no-helm --no-kustomize
```
5. Manual install from repository:
```bash
git clone https://github.com/nh4ttruong/kubekit.git
cd kubekit
bash ./install.sh
```

The installer automatically installs missing `kubectl`, `helm`, and `kustomize` binaries on Linux/macOS and configures shell completion for them.  
By default, aliases `k`, `kc`, and `kn` are installed with their completion setup.  
Use `--no-aliases` to skip alias setup entirely.

## Features

- `k` or `kubectl`: The official `kubectl` tool made by [Official Kubernetes](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/), you also could use `k` as its short version. They come with intelligent auto-completion! Just hit <TAB> to see the magic happen.
- `helm`: Kubernetes package manager with shell auto-completion.
- `kustomize`: Native Kubernetes configuration customization tool with shell auto-completion.
- `kc`: Easily switch between cluster contexts with a shorter alias `kc`. Type `kc` instead of the full command to get all contexts with current highlighting context. 
- `kn`: Need to get all namespaces or switch between cluster namespaces? No problem! `kn` is your fast lane.

## References
- [Kubernetes: Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kustomize Documentation](https://kubectl.docs.kubernetes.io/installation/kustomize/)
- [kubectx and kubens](https://github.com/ahmetb/kubectx)

## Contributing

Contributions are welcome! If you have any suggestions, feature requests, or bug reports, please [open an issue](https://github.com/nh4ttruong/kubekit/issues) or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).

---
[@nh4ttruong](https://github.com/nh4ttruong)
