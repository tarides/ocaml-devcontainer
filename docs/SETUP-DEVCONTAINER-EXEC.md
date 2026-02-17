# DevContainer CLI Workflow

Use your preferred editor ([Vim](https://www.vim.org/), [Emacs](https://www.gnu.org/software/emacs/), [Neovim](https://neovim.io/), [Claude Code](https://docs.anthropic.com/en/docs/claude-code), ...) with all OCaml tools running inside the container.

## Prerequisites

- [Docker](https://docs.docker.com/get-started/get-docker/) installed and running
- [Node.js](https://nodejs.org/) (for the DevContainer CLI)
- [DevContainer CLI](https://github.com/devcontainers/cli):
  ```bash
  npm install -g @devcontainers/cli
  ```

> **Permission error?** If `npm install -g` fails with EACCES, either
> [configure npm's default directory](https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally)
> or install with your system package manager (e.g. `sudo apt install nodejs npm`).

## Quick start

```bash
git clone https://github.com/tarides/ocaml-devcontainer.git
cd ocaml-devcontainer
devcontainer up --workspace-folder .

# Run commands inside the container
devcontainer exec --workspace-folder . dune build
```

## Using your editor

Run your editor inside the container where all OCaml tools are available:

```bash
devcontainer exec --workspace-folder . vim src/main.ml
devcontainer exec --workspace-folder . emacs src/main.ml
devcontainer exec --workspace-folder . nvim src/main.ml
devcontainer exec --workspace-folder . claude
```

### Shell alias

Add to your shell config for convenience:

```bash
alias dc='devcontainer exec --workspace-folder .'

# Then:
dc dune build
dc vim src/main.ml
```

## Switching OCaml versions

Wrap the switch command in a single shell invocation:

```bash
devcontainer exec --workspace-folder . bash -c 'opam switch 5.4.0+tsan && eval $(opam env) && dune build'
```

See the [README](../README.md#ocaml-switches) for the list of available switches.

## Stopping the container

```bash
docker stop $(docker ps -q --filter "label=devcontainer.local_folder=$(pwd)")
```

The workspace folder is mounted from your host, so your files are always safe on disk. State inside the container (installed packages, shell history) persists across `docker stop`/`devcontainer up` cycles as long as the container is not removed. Running `docker rm` or `devcontainer up --remove-existing-container` destroys that state.

## Advanced editor integration

### Emacs TRAMP

Edit files remotely using [Emacs TRAMP](https://www.gnu.org/software/tramp/) with the Docker method.

1. Start the container:
   ```bash
   devcontainer up --workspace-folder .
   ```

2. Find the container name:
   ```bash
   docker ps --filter "label=devcontainer.local_folder=$(pwd)" --format '{{.Names}}'
   ```

3. In Emacs, open files with:
   ```
   C-x C-f /docker:CONTAINER_NAME:/home/vscode/project/src/main.ml
   ```

4. Configure [eglot](https://www.gnu.org/software/emacs/manual/html_mono/eglot.html) for LSP support — add to your Emacs config:
   ```elisp
   (add-to-list 'eglot-server-programs
     '(tuareg-mode . ("docker" "exec" "-i" "CONTAINER_NAME" "ocamllsp")))
   ```

### [Neovim](https://neovim.io/) plugins

#### nvim-dev-container

For a VS Code-like "Reopen in Container" experience:

1. Install [nvim-dev-container](https://github.com/esensar/nvim-dev-container)
2. Configure in your init.lua:
   ```lua
   require('devcontainer').setup({})
   ```
3. Use `:DevcontainerStart` to open in container

#### Manual [LSP](https://neovim.io/doc/user/lsp.html) setup

```lua
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'ocaml',
  callback = function()
    vim.lsp.start({
      name = 'ocamllsp',
      cmd = { 'docker', 'exec', '-i', 'CONTAINER_NAME', 'ocamllsp' },
      root_dir = vim.fs.dirname(vim.fs.find({'dune-project'}, {upward = true})[1]),
    })
  end,
})
```

## Why this workflow?

1. **Works with any editor** — no special plugins required
2. **Consistent environment** — same tools, same versions, every time
3. **No host pollution** — OCaml tools stay in the container
4. **Easy to teach** — one pattern for all editors

---

See the [README](../README.md) for installed tools, common commands, and switch details.
