# KubeKit - Fast Kubernetes CLI operations

Optimize and keep your time with Kubernetes CLI management tool on your environment. Install and manage `kubectl` effortlessly, enjoy intelligent auto-completion with **<TAB>**, and set up quick aliases for rapid context and namespace operations.

## Features

- **Easy Installation**: Install and manage `kubectl` as `k` command with your OS.
- **Auto-Completion**: Enjoy auto-completion features that suggest commands and options as you type with **<TAB>**, saving you valuable time and minimizing errors.
- **Aliases Operation**: Set up quick aliases for namespace `kn` and context `kc` handling, enabling smooth navigation within your Kubernetes environment.

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
