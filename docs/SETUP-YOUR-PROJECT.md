# Adding the DevContainer to Your Project

You can add this OCaml devcontainer to your own repository so that contributors (and you) get a working environment via [GitHub Codespaces](https://github.com/features/codespaces), [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers), or the [DevContainer CLI](https://github.com/devcontainers/cli).

## Minimal setup

Create `.devcontainer/devcontainer.json` in your project root:

```jsonc
{
  "name": "OCaml Development",
  // Pre-built image from Docker Hub
  "image": "cuihtlauac/ocaml-devcontainer:latest",

  "customizations": {
    "vscode": {
      "extensions": ["ocamllabs.ocaml-platform"],
      "settings": {
        "ocaml.sandbox": {
          "kind": "opam",
          "switch": "ocaml"
        }
      }
    }
  },

  "postCreateCommand": "opam install . --deps-only -y"
}
```

Commit this file and push. The "Create codespace" button will appear on your repository's Code tab automatically.

## What each field does

| Field | Purpose |
|-------|---------|
| `image` | Pre-built image with OCaml 5.4, dune, ocaml-lsp-server, utop, and [more](../README.md#installed-tools) |
| `customizations.vscode` | Installs the OCaml extension and configures it for the `ocaml` switch |
| `postCreateCommand` | Installs your project's opam dependencies on first start. Runs once when the container is created |

## Optional additions

### Dune build cache

Persist the dune cache across container rebuilds so incremental builds stay fast:

```jsonc
{
  "mounts": [
    "source=dune-cache,target=/home/vscode/.cache/dune,type=volume"
  ],
  "remoteEnv": {
    "DUNE_CACHE_ROOT": "/home/vscode/.cache/dune"
  }
}
```

### Codespace machine size

Request minimum resources for Codespaces (useful for large projects):

```jsonc
{
  "hostRequirements": {
    "cpus": 4,
    "memory": "8gb",
    "storage": "32gb"
  }
}
```

### Claude Code

Add [Claude Code](https://docs.anthropic.com/en/docs/claude-code) as a DevContainer Feature:

```jsonc
{
  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1": {}
  }
}
```

### Post-start commands

Run commands every time the container starts (not just on creation):

```jsonc
{
  "postStartCommand": "dune build"
}
```

## Full example

A complete `.devcontainer/devcontainer.json` with all optional additions:

```jsonc
{
  "name": "OCaml Development",
  "image": "cuihtlauac/ocaml-devcontainer:latest",

  "features": {
    "ghcr.io/anthropics/devcontainer-features/claude-code:1": {}
  },

  "customizations": {
    "vscode": {
      "extensions": ["ocamllabs.ocaml-platform"],
      "settings": {
        "ocaml.sandbox": {
          "kind": "opam",
          "switch": "ocaml"
        }
      }
    }
  },

  "postCreateCommand": "opam install . --deps-only -y",

  "mounts": [
    "source=dune-cache,target=/home/vscode/.cache/dune,type=volume"
  ],

  "remoteEnv": {
    "DUNE_CACHE_ROOT": "/home/vscode/.cache/dune"
  },

  "hostRequirements": {
    "cpus": 4,
    "memory": "8gb",
    "storage": "32gb"
  }
}
```

## For projects with heavy dependencies

If your project has many opam dependencies, `postCreateCommand` will run on every new container creation, which can be slow. In that case, build a project-specific image instead:

```dockerfile
FROM cuihtlauac/ocaml-devcontainer:latest
COPY *.opam /tmp/project/
RUN cd /tmp/project && opam install . --deps-only -y && rm -rf /tmp/project
```

Then reference it in your `devcontainer.json`:

```jsonc
{
  "build": {
    "dockerfile": "Dockerfile"
  }
}
```

This bakes your dependencies into the image so container startup is fast.

## Using the devcontainer

Once `.devcontainer/devcontainer.json` is committed:

- **GitHub Codespaces:** Click "Code" > "Codespaces" > "Create codespace" on your repo page
- **VS Code:** Open the repo folder and click "Reopen in Container" when prompted
- **CLI:** `devcontainer up --workspace-folder . && devcontainer exec --workspace-folder . bash`

See the [Codespaces guide](SETUP-CODESPACES.md), [VS Code guide](SETUP-VSCODE.md), or [CLI guide](SETUP-DEVCONTAINER-EXEC.md) for details on each workflow.
