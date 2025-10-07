# Contributing to GitFollow

Thank you for your interest in contributing to GitFollow! We welcome contributions from everyone.

## Getting Started

1. **Fork the repository**
   ```bash
   git clone https://github.com/bulletdev/gitfollow.git
   cd gitfollow
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/gitfollow/client_spec.rb

# Run with coverage
bundle exec rake coverage
```

### Code Style

We use RuboCop to maintain code quality:

```bash
# Check code style
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

### Testing Your Changes

```bash
# Install gem locally
bundle exec rake install_local

# Test the CLI
gitfollow --help
```

## Pull Request Process

1. **Ensure tests pass**: `bundle exec rspec`
2. **Ensure code style is correct**: `bundle exec rubocop`
3. **Update documentation** if needed
4. **Add tests** for new features
5. **Update CHANGELOG.md** with your changes
6. **Create a pull request** with a clear description

## Code Guidelines

- Follow Ruby style guide
- Write descriptive commit messages
- Keep methods small and focused
- Add YARD documentation for public methods
- Maintain test coverage above 80%

## Testing Guidelines

- Write unit tests for all new code
- Use descriptive test names
- Mock external API calls
- Test both success and failure cases

## Commit Messages

Use clear and descriptive commit messages:

```
Add feature to export followers to PDF
Fix rate limit error handling
Update documentation for CLI commands
```

## Need Help?

- 📖 Read the [README](README.md)
- 💬 Open an [issue](https://github.com/bulletdev/gitfollow/issues)
- 📧 Contact the maintainers

## Code of Conduct

Be respectful and inclusive. We're all here to learn and improve.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
