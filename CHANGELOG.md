# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project setup
- Basic CLI structure
- Command service implementation
- Example Flutter application
- Command logging feature with `--log` flag that saves to `.moinsen-command-log.json`
- Update command to keep CLI up to date via `pub_updater`

### Changed
- Enhanced server security options with `--secret` and `--secret-key` flags
- Improved server shutdown handling with SIGINT signal

### Fixed

### Security

## [0.1.0] - 2024-01-24

### Added
- gRPC command service with bidirectional streaming
- Interactive command support with prompt detection
- Command responses now include timestamps and current working directory
- Serve command with configurable port (default: 50051)
- Secure server access with `--secret` flag for auto-generated keys
- Custom secret key support with `--secret-key` option

### Removed
- Sample command (replaced with actual functionality)

## [0.0.1] - 2023-12-25

### Added
- Initial release of the Moinsen tool
- Basic command runner setup
- Test infrastructure


