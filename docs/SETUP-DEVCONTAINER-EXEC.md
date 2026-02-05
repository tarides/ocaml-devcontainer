# DevContainer Exec Workflow

The primary workflow for using this development environment with any editor.

## Prerequisites

- Docker installed and running
- [DevContainer CLI](https://github.com/devcontainers/cli) installed:
  ```bash
  npm install -g @devcontainers/cli
  ```

## Quick Start

```bash
# Clone the repository
git clone https://github.com/tarides/ocaml-devcontainer.git
cd ocaml-devcontainer

# Start the container
devcontainer up --workspace-folder .

# Run commands inside the container
devcontainer exec --workspace-folder . dune build
devcontainer exec --workspace-folder . dune test
```

## Using Your Editor

The key insight: run your editor's commands inside the container, where all OCaml tools are available.

### Vim

```bash
devcontainer exec --workspace-folder . vim src/main.ml
```

### Emacs

```bash
devcontainer exec --workspace-folder . emacs src/main.ml
```

### Neovim

```bash
devcontainer exec --workspace-folder . nvim src/main.ml
```

### Claude Code

```bash
devcontainer exec --workspace-folder . claude
```

## Common Tasks

### Building

```bash
devcontainer exec --workspace-folder . dune build
```

### Running Tests

```bash
devcontainer exec --workspace-folder . dune test
```

### Interactive REPL

```bash
devcontainer exec --workspace-folder . utop
```

### Formatting Code

```bash
devcontainer exec --workspace-folder . dune fmt
```

### Switching OCaml Versions

```bash
# Inside any devcontainer exec command
devcontainer exec --workspace-folder . bash -c 'opam switch 5.4.0+tsan && eval $(opam env) && dune build'
```

## Shell Alias (Optional)

Add to your shell config for convenience:

```bash
alias dc='devcontainer exec --workspace-folder .'

# Then use:
dc dune build
dc vim src/main.ml
```

## Stopping the Container

```bash
# Stop the container
docker stop $(docker ps -q --filter "label=devcontainer.local_folder=$(pwd)")
```

## Why This Workflow?

1. **Works with any editor** - No special plugins required
2. **Consistent environment** - Same tools, same versions, every time
3. **No host pollution** - OCaml tools stay in the container
4. **Easy to teach** - One pattern for all editors
