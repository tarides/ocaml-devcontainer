# Advanced Setup

For users who need custom configurations or alternative workflows.

## Emacs TRAMP

Edit files remotely using Emacs TRAMP with the Docker method.

### Setup

1. Start the container:
   ```bash
   devcontainer up --workspace-folder .
   ```

2. Find the container name:
   ```bash
   docker ps --format '{{.Names}}' | grep devcontainer
   ```

3. In Emacs, open files with:
   ```
   C-x C-f /docker:CONTAINER_NAME:/home/vscode/project/src/main.ml
   ```

### Eglot Configuration

Add to your Emacs config:
```elisp
(add-to-list 'eglot-server-programs
  '(tuareg-mode . ("docker" "exec" "-i" "CONTAINER_NAME" "ocamllsp")))
```

## Neovim Plugins

### nvim-dev-container

For VS Code-like "Reopen in Container" experience:

1. Install [nvim-dev-container](https://github.com/esensar/nvim-dev-container)
2. Configure in your init.lua:
   ```lua
   require('devcontainer').setup({})
   ```
3. Use `:DevcontainerStart` to open in container

### Manual LSP Setup

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

## MCP Integration

### ocaml-mcp (Local)

Pre-installed in the container. Provides project-local tooling for AI assistants.

Tools available:
- `dune/build` - Build the project
- `dune/test` - Run tests
- `merlin/type-at-position` - Get type information
- `merlin/complete` - Code completion

### odoc-llm (Remote)

For ecosystem-wide package search. Add to your MCP configuration:

```bash
claude mcp add -t sse ocaml-ecosystem http://dill.caelum.ci.dev:8000/sse
```

Available tools:
- `search_packages` - Semantic search across opam packages
- `search_modules` - Find modules within packages
- `search_types` - Type-based search

## Local Image Building

For customization or offline use:

```bash
# Build base image (~35-50 minutes)
docker build -t ocaml-5.4-base base/

# Build dev image (~15-20 minutes)
docker build -t ocaml-5.4-dev dev/

# Use local build
devcontainer up --workspace-folder . --config .devcontainer-from-scratch/devcontainer.json
```

## Tutorial Author Workflow

Create a tutorial-specific image:

```dockerfile
FROM ghcr.io/<GITHUB_ORG>/ocaml-5.4-dev:latest

# Add tutorial-specific packages
RUN opam install -y lwt eio

# Add exercise files
COPY exercises/ /home/vscode/exercises/
```

Build and test quickly:
```bash
docker build -t my-tutorial .
docker run -it --rm my-tutorial
```

## Performance Tuning

### Dune Cache

Mount a persistent dune cache:
```json
{
  "mounts": [
    "source=dune-cache,target=/home/vscode/.cache/dune,type=volume"
  ]
}
```

### Build Parallelism

Set in `dune-workspace`:
```lisp
(lang dune 3.17)
(context default)
```

Or via environment:
```bash
export DUNE_BUILD_DIR=/tmp/dune
export DUNE_CACHE=enabled
```

## Debugging

### GDB

```bash
dune build
gdb _build/default/src/main.exe
```

### Valgrind

```bash
valgrind --leak-check=full ./_build/default/src/main.exe
```

### rr (Record & Replay)

Note: Requires hardware perf counters (not available in most VMs).
```bash
rr record ./_build/default/src/main.exe
rr replay
```
