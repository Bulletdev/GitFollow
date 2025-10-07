# GitFollow

[![Gem Version](https://img.shields.io/gem/v/gitfollow?logo=ruby&color=CC342D)](https://rubygems.org/gems/gitfollow)
[![Daily Follower Check](https://github.com/Bulletdev/GitFollow/actions/workflows/daily-check.yml/badge.svg)](https://github.com/Bulletdev/GitFollow/actions/workflows/daily-check.yml)
[![CI](https://github.com/bulletdev/gitfollow/workflows/CI/badge.svg)](https://github.com/bulletdev/gitfollow/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![codecov](https://codecov.io/gh/bulletdev/gitfollow/branch/main/graph/badge.svg)](https://codecov.io/gh/bulletdev/gitfollow)

**GitFollow** is a powerful CLI tool to track your GitHub followers and unfollows with ease. Get notified when someone follows or unfollows you, generate detailed reports, and automate your follower monitoring with GitHub Actions.

## Features

**Core Features**
- 🔍 Track new followers in real-time
-  Detect unfollows automatically
-  Generate detailed statistics and reports
-  Maintain complete history with timestamps
-  Create GitHub Issues automatically on changes
-  Local JSON-based storage

**Beautiful Output**
- Colorized terminal output
- Formatted tables (TTY::Table)
- Progress spinners
- Markdown and plain text reports

**Developer-Friendly**
- JSON export support
- CSV export for data analysis
- Configurable data directory
- Rate limit aware
- Comprehensive error handling

## Installation

### Via RubyGems (Recommended)

```bash
gem install gitfollow
```

### From Source

```bash
git clone https://github.com/bulletdev/gitfollow.git
cd gitfollow
bundle install
gem build gitfollow.gemspec
gem install ./gitfollow-0.1.0.gem
```

## Configuration

### GitHub Token

GitFollow requires a GitHub Personal Access Token with appropriate permissions.

1. **Generate a token**: Go to [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)
2. **Required scopes**: `read:user` (to read your follower data)
3. **Set the token**:

```bash
export OCTOCAT_TOKEN="your_github_token_here"
```

Or create a `.env` file:

```bash
OCTOCAT_TOKEN=your_github_token_here
```

## Usage

### Initialize GitFollow

First, initialize GitFollow to create your first snapshot:

```bash
gitfollow init
```

**Output:**
```
✔ Fetching initial data... Done!

Initialization complete!
Username: @yourname
Followers: 542
Following: 123
Mutual: 89

Run 'gitfollow check' to detect changes.
```

### Check for Changes

Check for new followers or unfollows:

```bash
gitfollow check
```

**Output:**
```
✔ Checking for changes... Done!

Changes detected for @yourname

✅ New Followers (2):
  • @newuser1
  • @newuser2

❌ Unfollowed (1):
  • @olduser

Net change: +1
Previous: 542 → Current: 543
```

### Display Statistics

View your current follower statistics:

```bash
gitfollow stats
```

**Output:**
```
Follower Statistics for @yourname
==================================================
┌──────────────────────┬─────┐
│Followers             │543  │
│Following             │123  │
│Mutual                │89   │
│Ratio                 │4.41 │
│Total New Followers   │15   │
│Total Unfollows       │3    │
└──────────────────────┴─────┘

Last Updated: 2025-10-07 09:00:00 UTC
```

### Generate Reports

Generate a detailed report:

```bash
# Plain text report
gitfollow report

# Markdown report
gitfollow report --format=markdown

# Save to file
gitfollow report --format=markdown --output=report.md
```

### Find Mutual Followers

List users who follow you and whom you follow back:

```bash
gitfollow mutual
```

### Find Non-Followers

List users you follow who don't follow you back:

```bash
gitfollow non-followers
```

### Export Data

Export your data for analysis:

```bash
# Export to JSON
gitfollow export json data.json

# Export to CSV
gitfollow export csv data.csv
```

## Advanced Usage

### JSON Output

All commands support JSON output:

```bash
gitfollow check --json
gitfollow stats --json
gitfollow mutual --json
```

### Table Format

Display changes in a formatted table:

```bash
gitfollow check --table
```

### Quiet Mode

Suppress output if no changes detected:

```bash
gitfollow check --quiet
```

### Custom Data Directory

Store data in a custom location:

```bash
gitfollow check --data-dir=/path/to/data
```

### Create GitHub Issues on Changes

Automatically create an issue when changes are detected:

```bash
gitfollow check --notify="bulletdev/gitfollow"
```

## Automated Monitoring with GitHub Actions

Set up automated daily checks using GitHub Actions:

### 1. Create Workflow File

Create `.github/workflows/daily-check.yml`:

```yaml
name: Daily Follower Check

on:
  schedule:
    - cron: '0 9 * * *'  # Run daily at 9 AM UTC
  workflow_dispatch:

jobs:
  check-followers:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'

      - name: Install GitFollow
        run: gem install gitfollow

      - name: Cache data
        uses: actions/cache@v4
        with:
          path: ~/.gitfollow
          key: gitfollow-data

      - name: Check followers
        env:
          OCTOCAT_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gitfollow init || true
          gitfollow check --notify="${{ github.repository }}"
```

### 2. Enable Workflow

1. Push the workflow file to your repository
2. Go to **Actions** tab in your repository
3. Enable the workflow
4. It will run automatically every day!

## CLI Commands Reference

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

## Configuration File

You can create a `.gitfollow.yml` config file (optional):

```yaml
# Custom data directory
data_dir: ~/.gitfollow

# Default notification repository
notify_repo: bulletdev/gitfollow

# Output preferences
output:
  colorize: true
  format: table
```

## Data Storage

GitFollow stores data in `~/.gitfollow/` by default:

```
~/.gitfollow/
├── snapshots.json  # Follower snapshots
└── history.json    # Change history
```

## Development

### Setup

```bash
git clone https://github.com/bulletdev/gitfollow.git
cd gitfollow
bundle install
```

### Run Tests

```bash
bundle exec rspec
```

### Lint Code

```bash
bundle exec rubocop
```

### Build Gem

```bash
gem build gitfollow.gemspec
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:
- All tests pass (`bundle exec rspec`)
- Code follows style guide (`bundle exec rubocop`)
- Add tests for new features
- Update documentation as needed

## Publishing to RubyGems

### Manual Publication

```bash
# Build the gem
gem build gitfollow.gemspec

# Push to RubyGems
gem push gitfollow-0.1.0.gem
```

### Automated Release

1. Update version in `lib/gitfollow/version.rb`
2. Update `CHANGELOG.md`
3. Commit changes
4. Create and push a tag:

```bash
git tag v0.1.0
git push origin v0.1.0
```

The GitHub Actions workflow will automatically build and publish to RubyGems.

## Troubleshooting

### Authentication Failed

**Error:** `Authentication failed while fetching followers`

**Solution:** Ensure your GitHub token is valid and has the required `read:user` scope.

### Rate Limit Exceeded

**Error:** `Rate limit exceeded`

**Solution:** GitHub API has rate limits. Wait for the limit to reset or reduce check frequency.

### No Changes Detected on First Run

This is expected! Run `gitfollow init` first to create your initial snapshot.

## Security

- Never commit your GitHub token to version control
- Use GitHub Secrets for CI/CD workflows
- The `.env` file should be in `.gitignore`
- Tokens are never logged or stored in data files

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Octokit](https://github.com/octokit/octokit.rb) for GitHub API
- Uses [Thor](https://github.com/rails/thor) for CLI framework
- Formatted output with [TTY::Table](https://github.com/piotrmurach/tty-table)

## Support

- 🐛 [Report a bug](https://github.com/bulletdev/gitfollow/issues)
- 💡 [Request a feature](https://github.com/bulletdev/gitfollow/issues)
- 📖 [Documentation](https://github.com/bulletdev/gitfollow/blob/main/README.md)

---

**Made with  💎♦️ by [Michael D. Bullet](https://github.com/bulletdev)**

⭐ Star this repo if you find it useful!
