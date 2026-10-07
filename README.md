# GitFollow

[![Gem Version](https://img.shields.io/gem/v/gitfollow?logo=ruby&color=CC342D)](https://rubygems.org/gems/gitfollow)
[![Daily Follower Check](https://github.com/Bulletdev/GitFollow/actions/workflows/daily-check.yml/badge.svg)](https://github.com/Bulletdev/GitFollow/actions/workflows/daily-check.yml)
[![CI](https://github.com/bulletdev/gitfollow/workflows/CI/badge.svg)](https://github.com/bulletdev/gitfollow/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**GitFollow** is a CLI tool to track your GitHub followers and unfollows. Get notified when someone follows or unfollows you, generate detailed reports, and automate monitoring with GitHub Actions.

## Features

- Track new followers and detect unfollows automatically
- Generate detailed statistics and reports (text and Markdown)
- Create GitHub Issues automatically on changes, with a 7-day activity summary
- Complete history with timestamps stored locally in JSON
- JSON and CSV export support
- Colorized terminal output with formatted tables

## Installation

```bash
gem install gitfollow
```

Or from source:

```bash
git clone https://github.com/bulletdev/gitfollow.git
cd gitfollow
bundle install
gem build gitfollow.gemspec
gem install ./gitfollow-*.gem
```

## Configuration

GitFollow requires a GitHub Personal Access Token with `read:user` scope.

1. Generate a token at [GitHub Settings -> Developer settings -> Personal access tokens](https://github.com/settings/tokens)
2. Set it as an environment variable:

```bash
export OCTOCAT_TOKEN="your_github_token_here"
```

Or create a `.env` file:

```
OCTOCAT_TOKEN=your_github_token_here
```

## Usage

### Initialize

Create your first snapshot:

```bash
gitfollow init
```

```
Fetching initial data... Done!

Initialization complete!
Username: @yourname
Followers: 542
Following: 123
Mutual: 89

Run 'gitfollow check' to detect changes.
```

### Check for Changes

```bash
gitfollow check
```

```
Checking for changes... Done!

Changes detected for @yourname

+ New Followers (2):
  * @newuser1
  * @newuser2

- Unfollowed (1):
  * @olduser

Net change: +1
Previous: 542 -> Current: 543
```

### Statistics

```bash
gitfollow stats
```

### Reports

```bash
gitfollow report
gitfollow report --format=markdown
gitfollow report --format=markdown --output=report.md
```

### Mutual Followers and Non-Followers

```bash
gitfollow mutual
gitfollow non-followers
```

### Export Data

```bash
gitfollow export json data.json
gitfollow export csv data.csv
```

## Advanced Options

```bash
gitfollow check --json          # JSON output
gitfollow check --table         # table format
gitfollow check --quiet         # suppress output if no changes
gitfollow check --data-dir=/path/to/data
gitfollow check --notify="owner/repo"   # create a GitHub Issue on changes
```

## Automated Monitoring with GitHub Actions

### Setup

1. Add your token as a repository secret named `OCTOCAT_TOKEN`
2. Create `.github/workflows/daily-check.yml`:

```yaml
name: Daily Follower Check

on:
  schedule:
    - cron: '0 9 * * *'
  workflow_dispatch:

jobs:
  check-followers:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.4.5'
          bundler-cache: true

      - name: Install GitFollow
        run: |
          gem build gitfollow.gemspec
          gem install ./gitfollow-*.gem

      - name: Cache follower data
        uses: actions/cache@v4
        with:
          path: ~/.gitfollow
          key: gitfollow-data-${{ github.repository_owner }}-${{ github.run_id }}
          restore-keys: |
            gitfollow-data-${{ github.repository_owner }}-

      - name: Initialize if first run
        env:
          OCTOCAT_TOKEN: ${{ secrets.OCTOCAT_TOKEN }}
        run: |
          if [ ! -f ~/.gitfollow/snapshots.json ]; then
            gitfollow init
          fi

      - name: Check for changes
        env:
          OCTOCAT_TOKEN: ${{ secrets.OCTOCAT_TOKEN }}
          REPO: ${{ github.repository }}
        run: gitfollow check --notify="$REPO" --quiet
```

### Issue Format

When changes are detected, GitFollow creates a GitHub Issue with:

- **Today's diff**: new followers and unfollows since the last run
- **Summary**: previous/current count and net change
- **Last 7 days activity**: full table of recent events

## CLI Reference

| Command | Description |
|---------|-------------|
| `gitfollow init` | Initialize and create first snapshot |
| `gitfollow check` | Check for follower changes |
| `gitfollow report` | Generate detailed report |
| `gitfollow stats` | Display statistics |
| `gitfollow mutual` | List mutual followers |
| `gitfollow non-followers` | List non-followers |
| `gitfollow export FORMAT FILE` | Export data (json/csv) |
| `gitfollow clear` | Clear all stored data |
| `gitfollow version` | Display version |

## Data Storage

Data is stored in `~/.gitfollow/` by default:

```
~/.gitfollow/
├── snapshots.json  # follower snapshots
└── history.json    # change history
```

Use `--data-dir` to change the location.

## Development

```bash
bundle install
bundle exec rspec       # run tests
bundle exec rubocop     # lint
gem build gitfollow.gemspec
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes with tests
4. Open a Pull Request

## Security

- Never commit your GitHub token to version control
- Use GitHub Secrets for CI/CD workflows
- Keep `.env` in `.gitignore`

## License

MIT — see [LICENSE](LICENSE).

---

Made with Ruby by [Michael D. Bullet](https://github.com/bulletdev)
