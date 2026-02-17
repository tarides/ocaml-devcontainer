# VS Code Setup

Native [VS Code](https://code.visualstudio.com/) integration with the [Dev Containers extension](https://code.visualstudio.com/docs/devcontainers/containers).

> **Note:** This guide targets VS Code. It has not been tested with [Cursor](https://www.cursor.com/) or [Google Antigravity](https://idx.google.com/).

## Prerequisites

- [VS Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Docker](https://docs.docker.com/get-started/get-docker/) installed and running

## Quick start

1. Clone the repository:
   ```bash
   git clone https://github.com/tarides/ocaml-devcontainer.git
   ```

2. Open in VS Code:
   ```bash
   code ocaml-devcontainer
   ```

3. When prompted, click "Reopen in Container"
   - Or: Press `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

4. Wait for the container to start (~2-3 minutes first time)

## OCaml Platform extension

The [OCaml Platform extension](https://marketplace.visualstudio.com/items?itemName=ocamllabs.ocaml-platform) is automatically installed and provides:

- Syntax highlighting
- Code completion
- Type information on hover
- Go to definition
- Find references
- Code formatting ([ocamlformat](https://github.com/ocaml-ppx/ocamlformat))
- Error diagnostics

## Switching OCaml versions

Click the [opam](https://opam.ocaml.org/) switch name in the bottom status bar and select the desired switch from the picker. The extension reloads automatically.

Alternatively, use the terminal:

1. Run:
   ```bash
   opam switch 5.4.0+tsan
   eval $(opam env)
   ```
2. Reload the window (`Ctrl+Shift+P` → "Developer: Reload Window") so the extension picks up the new switch

See the [README](../README.md#ocaml-switches) for the list of available switches.

## Debugging

[GDB](https://sourceware.org/gdb/) and [LLDB](https://lldb.llvm.org/) are available for native debugging. VS Code's [debugger](https://code.visualstudio.com/docs/debugger/overview) can be configured to use them.

## Data persistence

The workspace folder is [mounted from your host](https://code.visualstudio.com/docs/devcontainers/containers#_quick-start-open-an-existing-folder-in-a-container), so your files are always safe on disk. State inside the container (installed packages, shell history) persists as long as you stop and restart the container. Rebuilding the container (`Ctrl+Shift+P` → "Dev Containers: Rebuild Container") resets that state.

## Troubleshooting

### Extension not working

1. Check that the container started successfully
2. Reload the window
3. Check the OCaml extension output panel

### Slow IntelliSense

This can happen with large projects. Try:
```bash
dune build  # Build first to generate .merlin files
```

### Container won't start

1. Check Docker is running
2. Try rebuilding: `Ctrl+Shift+P` → "Dev Containers: Rebuild Container"
3. Check Docker logs for errors

## Tips

- Use `Ctrl+Shift+P` → "OCaml: Restart Language Server" if LSP gets confused
- The OCaml extension respects `.ocamlformat` files
- Use the "Problems" panel to see all errors and warnings

---

See the [README](../README.md) for installed tools, common commands, and switch details.
