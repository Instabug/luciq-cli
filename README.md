# Luciq CLI

Command-line interface for uploading symbol files to Luciq.

## Installation

### Using RubyGems

```bash
gem install luciq-cli
```

### Using Homebrew (macOS/Linux)

```bash
brew tap instabug/tap
brew install luciq-cli
```

### From Source

```bash
git clone https://github.com/Instabug/luciq-cli.git
cd luciq-cli
bundle install
bundle exec rake install
```

## Quick Start

### 1. Authenticate

Generate a CLI token from your [Luciq Dashboard](https://dashboard.luciq.ai/company/cli), then:

> **Self-hosted clusters:** Replace `dashboard.luciq.ai` with your cluster URL.

```bash
luciq login
```

Or pass the token directly:

```bash
luciq login --auth-token YOUR_CLI_TOKEN
```

### 2. Upload Symbol Files

Upload Android mapping files (`.zip` containing a single mapping text file):

```bash
luciq upload android-mapping mapping.zip \
  --app-token YOUR_APP_TOKEN \
  --version-name 1.0.0 \
  --version-code 1
```

| Option | Description |
|--------|-------------|
| `--app-token` | Luciq application token (required) |
| `--version-name` | App version name, e.g., `1.0.0` (required) |
| `--version-code` | App version code, e.g., `1` (required) |

## Commands

| Command | Description |
|---------|-------------|
| `luciq login` | Authenticate with Luciq |
| `luciq logout` | Remove saved authentication |
| `luciq whoami` | Show current authenticated user |
| `luciq info` | Show CLI configuration |
| `luciq upload android-mapping FILE` | Upload Android mapping file |
| `luciq version` | Show CLI version |

## Configuration

Configuration is read from environment variables and `~/.luciqrc` file.

### Environment Variables

| Variable | Description |
|----------|-------------|
| `LUCIQ_AUTH_TOKEN` | Authentication token |
| `LUCIQ_URL` | API base URL (default: https://api.luciq.ai) |

### Config File

```
# ~/.luciqrc
token=your-cli-token
url=https://api.luciq.ai
```

### Self-Hosted / Single Tenant

If you're using a self-hosted or single tenant cluster, you need to configure the API URL:

**Option 1: Environment variable**

```bash
export LUCIQ_URL=https://api.your-cluster.luciq.ai
```

**Option 2: Config file**

Add the `url` to your `~/.luciqrc`:

```
token=your-cli-token
url=https://api.your-cluster.luciq.ai
```

## Development

```bash
git clone https://github.com/Instabug/luciq-cli.git
cd luciq-cli
bundle install

# Run tests
bundle exec rspec

# Test locally
bundle exec bin/luciq --help
```
