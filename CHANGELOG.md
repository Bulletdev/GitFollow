# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.3] - 2026-10-07

### Fixed
- Unfollower usernames appearing blank in GitHub Issues — `generate_issue_body` was using symbol keys
  (`user[:login]`) while data loaded from JSON storage uses string keys (`user['login']`); fixed to
  use `user['login'] || user[:login]` across all output methods in `Notifier`
- Snapshots not persisting between daily workflow runs — GitHub Actions cache key was static and
  immutable; changed to `gitfollow-data-{owner}-{run_id}` with `restore-keys` fallback so each run
  saves a fresh cache entry and inherits the previous snapshot
- Duplicate `gitfollow check --notify` call removed from daily workflow
- RuboCop crash on CI — `rubocop >= 1.77` changed `inject_defaults!` to raise `ArgumentError` when
  passed a directory path, breaking `rubocop-rspec_rails 2.29.1`; pinned rubocop to `< 1.77`

### Added
- GitHub Issues now include a **Last 7 Days Activity** table showing all follower changes from the
  past week, in addition to the current diff

### Changed
- Emojis removed from all Ruby source files and README
- README rewritten with corrected workflow example, accurate command output samples, and an Issue
  Format section describing the new 7-day activity table

## [0.1.0] - 2025-10-07

### Added
- Initial release of GitFollow
- Track GitHub followers and unfollows
- Detect new followers automatically
- Detect unfollows automatically
- Store follower history with timestamps
- Generate detailed reports (text and markdown)
- Display follower statistics
- List mutual followers
- List non-followers (users you follow who don't follow back)
- Export data to JSON format
- Export data to CSV format
- Create GitHub Issues automatically on changes
- Colorized terminal output
- Formatted table output with TTY::Table
- Progress spinners for API calls
- JSON output mode for all commands
- CLI commands:
  - `gitfollow init` - Initialize and create first snapshot
  - `gitfollow check` - Check for follower changes
  - `gitfollow report` - Generate detailed report
  - `gitfollow stats` - Display statistics
  - `gitfollow mutual` - List mutual followers
  - `gitfollow non-followers` - List non-followers
  - `gitfollow export` - Export data
  - `gitfollow clear` - Clear all stored data
  - `gitfollow version` - Display version
- GitHub Actions workflows:
  - CI workflow with tests and linting
  - Daily follower check workflow
  - Automated release workflow
- Comprehensive test suite with RSpec
- RuboCop configuration for code quality
- Support for Ruby 3.0, 3.1, 3.2, and 3.3
- MIT License
- Complete documentation

### Security
- GitHub token authentication
- Rate limit aware API calls
- No credentials stored in data files

[Unreleased]: https://github.com/bulletdev/gitfollow/compare/v0.1.3...HEAD
[0.1.3]: https://github.com/bulletdev/gitfollow/compare/v0.1.0...v0.1.3
[0.1.0]: https://github.com/bulletdev/gitfollow/releases/tag/v0.1.0
