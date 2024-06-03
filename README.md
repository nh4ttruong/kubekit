# KubeKit - Fast Kubernetes CLI operations

Managing Kubernetes clusters, contexts, and namespaces can be time-consuming. But fear not! I’ve got you covered with three KubeKit smart tools: `k`, `kc`, and `kn`. These tools will streamline your workflow and make your life easier.

## Features

- `k` or `kubectl`: The official `kubectl` tool made by [Official Kubernetes](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/), you also could use `k` as its short version. They come with intelligent auto-completion! Just hit <TAB> to see the magic happen.
- `kc`: Easily to switch between cluster contexts with a shorter alias `kc`. Type `kc` instead of the full command to get all contexts with current highlighting context. 
- `kn`: Need to get all namepsaces or switch between cluster namespaces? No problem! `kn` is your fast lane.

## Installation

To install KubeKit, follow these steps:

1. Install `kubectl` only:
```bash
curl -sL https://github.com/nh4ttruong/kubekit/raw/main/install.sh | sudo bash
```
2. Install `kubectl` with `kc` (context) and `kn` (namespace) aliases operations:
```bash
curl -sL https://github.com/nh4ttruong/kubekit/raw/main/install.sh | sudo bash -s -- -a
```
3. Manual install from repository:
```bash
git clone https://github.com/nh4ttruong/kubekit.git
cd kubekit
bash ./install.sh -a
```

The `-a` or `--alias` option is optional and allows you to install quick aliases for context `kc` and namespace `kn` operations.

## Usage

Once installed, you can use KubeKit to enhance your Kubernetes workflow:

- Use `k` as short version of `kubectl`:
- Use `kc` to manage Kubernetes contexts:
  - `kc`: List available contexts
  - `kc <context-name>`: Switch to the specified context
- Use `kn` to manage Kubernetes namespaces:
  - `kn`: List available namespaces
  - `kn <namespace-name>`: Switch to the specified namespace

For more information on KubeKit usage, refer to run `kc -h` and `kn -h` for help.

## Reference
- [Official Kubernetes documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [kubectx](https://github.com/ahmetb/kubectx)

## Contributing

Contributions are welcome! If you have any suggestions, feature requests, or bug reports, please [open an issue](https://github.com/nh4ttruong/kubekit/issues) or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).

---
[@nh4ttruong](https://github.com/nh4ttruong)
