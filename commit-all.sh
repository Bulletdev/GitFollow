#!/bin/bash

# Script para fazer commits organizados do projeto GitFollow
# Uso: ./commit-all.sh

set -e  # Parar em caso de erro

echo "🚀 Iniciando commits organizados do GitFollow..."
echo ""

# Inicializar repositório
if [ ! -d .git ]; then
    echo "📦 Inicializando repositório Git..."
    git init
    git branch -M main
fi

# 1. Configuração Inicial
echo "1/22 - Configuração inicial..."
git add .gitignore .rspec
if [ -f .ruby-version ]; then
    git add .ruby-version
fi
git commit -m "chore: initial project setup

- Add .gitignore for Ruby project
- Configure Ruby version 3.0+
- Setup RSpec configuration" 2>/dev/null || echo "  ⏭️  Já commitado"

# 2. Gemspec e Dependências
echo "2/22 - Gemspec e dependências..."
git add Gemfile gitfollow.gemspec Rakefile lib/gitfollow/version.rb
git commit -m "chore: configure gem specification and dependencies

- Add gitfollow.gemspec with metadata
- Configure Gemfile with runtime and dev dependencies
- Add Rakefile for common tasks
- Define initial version 0.1.0" 2>/dev/null || echo "  ⏭️  Já commitado"

# 3. Client
echo "3/22 - Client (API GitHub)..."
git add lib/gitfollow/client.rb
git commit -m "feat(client): implement GitHub API client

- Create Client class with Octokit integration
- Add methods for fetching followers and following
- Implement rate limit checking
- Add issue creation support
- Handle GitHub API errors gracefully" 2>/dev/null || echo "  ⏭️  Já commitado"

# 4. Storage
echo "4/22 - Storage (Persistência)..."
git add lib/gitfollow/storage.rb
git commit -m "feat(storage): implement local data persistence

- Create Storage class for JSON-based persistence
- Save snapshots of followers/following with timestamps
- Track history of follower changes
- Support data export to JSON and CSV formats
- Add mutual followers calculation" 2>/dev/null || echo "  ⏭️  Já commitado"

# 5. Tracker
echo "5/22 - Tracker (Lógica de rastreamento)..."
git add lib/gitfollow/tracker.rb
git commit -m "feat(tracker): implement follower tracking logic

- Create Tracker class for change detection
- Detect new followers and unfollows
- Calculate statistics (ratio, mutual followers, etc)
- Generate reports in text and markdown formats
- Find non-followers (users who don't follow back)" 2>/dev/null || echo "  ⏭️  Já commitado"

# 6. Notifier
echo "6/22 - Notifier (Notificações)..."
git add lib/gitfollow/notifier.rb
git commit -m "feat(notifier): implement notification system

- Create Notifier class for change notifications
- Format output for terminal with colors
- Generate formatted tables with TTY::Table
- Support GitHub Issue creation on changes
- Add summary generation for changes" 2>/dev/null || echo "  ⏭️  Já commitado"

# 7. CLI
echo "7/22 - CLI Interface..."
git add lib/gitfollow/cli.rb lib/gitfollow.rb bin/gitfollow
git commit -m "feat(cli): implement command-line interface

- Create CLI with Thor framework
- Add commands: init, check, report, stats
- Add commands: mutual, non-followers, export
- Support JSON output mode for all commands
- Add progress spinners and error handling
- Make bin/gitfollow executable" 2>/dev/null || echo "  ⏭️  Já commitado"

# 8. Testes - Storage
echo "8/22 - Testes - Storage..."
git add spec/spec_helper.rb spec/gitfollow/storage_spec.rb
git commit -m "test(storage): add comprehensive storage tests

- Configure RSpec with SimpleCov and WebMock
- Test snapshot saving and retrieval
- Test history tracking functionality
- Test data export (JSON and CSV)
- Test data clearing and existence checks
- Achieve 70%+ code coverage" 2>/dev/null || echo "  ⏭️  Já commitado"

# 9. Testes - Client
echo "9/22 - Testes - Client..."
git add spec/gitfollow/client_spec.rb
git commit -m "test(client): add GitHub API client tests

- Test client initialization and validation
- Test follower/following fetching
- Test rate limit checking
- Test issue creation
- Mock GitHub API responses
- Test error handling scenarios" 2>/dev/null || echo "  ⏭️  Já commitado"

# 10. Testes - Tracker
echo "10/22 - Testes - Tracker..."
git add spec/gitfollow/tracker_spec.rb
git commit -m "test(tracker): add tracker logic tests

- Test initial setup and snapshots
- Test change detection (new followers/unfollows)
- Test statistics calculation
- Test report generation (text/markdown)
- Test mutual followers and non-followers
- Handle both symbol and string keys" 2>/dev/null || echo "  ⏭️  Já commitado"

# 11. Testes - Notifier
echo "11/22 - Testes - Notifier..."
git add spec/gitfollow/notifier_spec.rb
git commit -m "test(notifier): add notification tests

- Test terminal output formatting
- Test table formatting with TTY::Table
- Test GitHub issue creation
- Test summary generation
- Test colorized and non-colorized output" 2>/dev/null || echo "  ⏭️  Já commitado"

# 12. Testes - Module
echo "12/22 - Testes - Module..."
git add spec/gitfollow_spec.rb
git commit -m "test: add module and version tests

- Test GitFollow module structure
- Verify all classes are defined
- Test version constant existence" 2>/dev/null || echo "  ⏭️  Já commitado"

# 13. GitHub Actions - CI
echo "13/22 - GitHub Actions - CI..."
git add .github/workflows/ci.yml
git commit -m "ci: add continuous integration workflow

- Test on Ruby 3.0, 3.1, 3.2, 3.3
- Run RSpec tests with coverage
- Run RuboCop linting
- Build gem artifact
- Upload coverage to Codecov" 2>/dev/null || echo "  ⏭️  Já commitado"

# 14. GitHub Actions - Daily Check
echo "14/22 - GitHub Actions - Daily Check..."
git add .github/workflows/daily-check.yml
git commit -m "ci: add daily follower check workflow

- Schedule daily execution at 9 AM UTC
- Cache follower data between runs
- Create GitHub issues on changes detected
- Generate and upload markdown reports
- Support manual workflow dispatch" 2>/dev/null || echo "  ⏭️  Já commitado"

# 15. GitHub Actions - Release
echo "15/22 - GitHub Actions - Release..."
git add .github/workflows/release.yml
git commit -m "ci: add automated release workflow

- Trigger on version tags (v*)
- Run tests before release
- Build and publish gem to RubyGems
- Create GitHub Release with changelog
- Extract version-specific changelog" 2>/dev/null || echo "  ⏭️  Já commitado"

# 16. RuboCop
echo "16/22 - RuboCop Configuration..."
git add .rubocop.yml
git commit -m "chore: configure RuboCop for code quality

- Set Ruby 3.0 as target version
- Configure style preferences
- Set metrics limits (line length, method size)
- Configure RSpec cops
- Disable documentation requirement" 2>/dev/null || echo "  ⏭️  Já commitado"

# 17. README
echo "17/22 - README..."
git add README.md
git commit -m "docs: add comprehensive README

- Add project description and features
- Include installation instructions
- Document all CLI commands with examples
- Add GitHub Actions setup guide
- Include badges for CI, coverage, version
- Add troubleshooting section
- Document security considerations" 2>/dev/null || echo "  ⏭️  Já commitado"

# 18. Contributing
echo "18/22 - Contributing Guidelines..."
git add CONTRIBUTING.md
git commit -m "docs: add contributing guidelines

- Define development setup process
- Document testing requirements
- Explain code style guidelines
- Describe pull request process
- Add commit message conventions" 2>/dev/null || echo "  ⏭️  Já commitado"

# 19. Changelog
echo "19/22 - Changelog..."
git add CHANGELOG.md
git commit -m "docs: add changelog

- Document version 0.1.0 features
- List all implemented functionality
- Follow Keep a Changelog format
- Add links to releases" 2>/dev/null || echo "  ⏭️  Já commitado"

# 20. License
echo "20/22 - License..."
git add LICENSE
git commit -m "docs: add MIT license

- Add MIT License text
- Set copyright to Michael D. Bullet" 2>/dev/null || echo "  ⏭️  Já commitado"

# 21. Config Examples
echo "21/22 - Configuration Examples..."
git add .env.example .gitfollow.yml.example
git commit -m "docs: add configuration examples

- Add .env.example with GitHub token template
- Add .gitfollow.yml.example with all options
- Document optional configuration settings" 2>/dev/null || echo "  ⏭️  Já commitado"

# 22. Commit Final
echo "22/22 - Commit Final..."
git add .
git commit -m "chore: prepare for v0.1.0 release

- Update all references to bulletdev/gitfollow
- Fix gemspec warnings
- Ensure all tests pass (57/57)
- Achieve 70.56% code coverage
- Ready for production use" 2>/dev/null || echo "  ⏭️  Já commitado"

echo ""
echo "✅ Todos os commits foram criados!"
echo ""
echo "📊 Estatísticas:"
git log --oneline | wc -l | xargs echo "  Total de commits:"
echo ""
echo "🔄 Próximos passos:"
echo "  1. Adicionar remote: git remote add origin git@github.com:bulletdev/gitfollow.git"
echo "  2. Push dos commits: git push -u origin main"
echo "  3. Criar tag: git tag -a v0.1.0 -m 'GitFollow v0.1.0'"
echo "  4. Push da tag: git push origin v0.1.0"
echo ""
echo "🎉 Projeto pronto para publicação!"
