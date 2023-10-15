
# AWS SAM CLI (aws-sam-cli)

Installs the AWS SAM CLI along with needed dependencies.

## Example Usage

```json
"features": {
    "ghcr.io/goldsam/dev-container-features/aws-sam-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter an AWS SAM CLI version. | string | latest |

## Customizations

### VS Code Extensions

- `ThreadHeap.serverless-ide-vscode`

Available versions of the AWS SAM CLI can be found here: https://github.com/aws/aws-sam-cli/releases.

OS Support
This Feature should work on recent versions of Debian/Ubuntu-based distributions with the apt package manager installed.

bash is required to execute the install.sh script.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/goldsam/dev-container-features/blob/main/src/aws-sam-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
