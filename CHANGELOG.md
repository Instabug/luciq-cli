# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-07-05

### Added

- `luciq crashes` - Query crashes: `list`, `show`, `patterns`, `diagnostics`, `hangs`, `occurrence-tokens`, `occurrence`
- `luciq bugs` - Query and update bugs: `list`, `show`, `update` (status, priority, tags, duplicate marking)
- `luciq apm` - Query APM data: `groups`, `group`, `occurrence`, and funnels (`funnel-events`, `funnel-create`, `funnel-update`, `funnel-delete`)
- `luciq reviews list` - Query app reviews
- `luciq surveys` - Query surveys: `list`, `show`
- `luciq apps list` - List accessible applications
- `luciq insights` - Show aggregated app-health insights
- `luciq issues list` - List issues across sources ranked by impact
- `luciq opportunities` - Query opportunities: `list`, `show`
- `luciq alerts` - Manage alert rules: `list`, `show`, `init`, `create`, `update`, `delete`
- `luciq incidents` - Manage triggered alerts: `list`, `show`, `resolve`, `reopen`
- Typed filter flags with a raw `--filters` JSON escape hatch on query commands

## [0.1.0] - 2025-12-16

### Added

- Initial release
- `luciq login` - Authenticate with CLI token
- `luciq logout` - Remove saved authentication
- `luciq whoami` - Show current authenticated user
- `luciq info` - Show CLI configuration
- `luciq upload android-mapping` - Upload Android mapping files
- `luciq version` - Show CLI version
- Support for environment variables (`LUCIQ_AUTH_TOKEN`, `LUCIQ_URL`)
- Support for config file (`~/.luciqrc`)
