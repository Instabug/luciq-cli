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

Upload Android mapping files (`mapping.txt`):

```bash
luciq upload android-mapping mapping.txt \
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
| `luciq version` | Show CLI version |

### Upload commands

Run `luciq upload help SUBCOMMAND` for the full options of any command.

**iOS**

| Command | File | Description |
|---------|------|-------------|
| `luciq upload ios-dsym FILE` | `.zip` | iOS dSYM symbols |

**Android**

| Command | File | Description |
|---------|------|-------------|
| `luciq upload android-mapping FILE` | `mapping.txt` | Proguard/R8 mapping file |
| `luciq upload android-ndk FILE` | `.zip` | NDK `.so` shared object files (`--arch`) |

**React Native**

| Command | File | Description |
|---------|------|-------------|
| `luciq upload react-native-ios-dsym FILE` | `.zip` | iOS native dSYM symbols |
| `luciq upload react-native-ios-sourcemap FILE` | `.json`/`.txt` | iOS JavaScript source map |
| `luciq upload react-native-android-mapping FILE` | `mapping.txt` | Android native Proguard/R8 mapping |
| `luciq upload react-native-android-sourcemap FILE` | `.json`/`.txt` | Android JavaScript source map |
| `luciq upload react-native-ndk FILE` | `.zip` | NDK `.so` shared object files (`--arch`) |

**Flutter**

| Command | File | Description |
|---------|------|-------------|
| `luciq upload flutter-ios-dsym FILE` | `.zip` | iOS native dSYM symbols |
| `luciq upload flutter-ios-sourcemap FILE` | `.zip` | iOS Dart symbol files |
| `luciq upload flutter-android-mapping FILE` | `mapping.txt` | Android native Proguard/R8 mapping |
| `luciq upload flutter-android-sourcemap FILE` | `.zip` | Android Dart symbol files |
| `luciq upload flutter-ndk FILE` | `.zip` | NDK `.so` shared object files (`--arch`) |

Common options: `--app-token` is required for every command. dSYM commands
(`*-ios-dsym`) need only `--app-token`. Mapping, source-map, and Flutter Dart-symbol
commands also require `--version-name` / `--version-code` (React Native source-map
commands additionally accept `--codepush`). NDK commands require `--version-name` and
`--arch` (`armeabi-v7a`, `arm64-v8a`, `x86`, `x86_64`) — not `--version-code`.

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
