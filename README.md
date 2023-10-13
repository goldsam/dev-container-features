# Some Additional Development Container Features

This repo provides some additional development container features that you may find useful.

Missing a CLI or language in your otherwise perfect container image? Add the relevant Feature to the features property of a devcontainer.json. A tool supporting the dev container specification is required to build a development container.

## Repo and Feature Structure

Similar to the [`devcontainers/features`](https://github.com/devcontainers/features) repo, this repository has a `src` folder.  Each Feature has its own sub-folder, containing at least a `devcontainer-feature.json` and an entrypoint script `install.sh`. 

### Options

All available options for each Feature are declared in its associated `devcontainer-feature.json`. For additional details, see the [devcontainer Feature json properties reference](https://containers.dev/implementors/features/#devcontainer-feature-json-properties).

