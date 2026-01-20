# How to Contribute to FeedbackBin

We welcome contributions from the community! FeedbackBin uses GitHub
[Discussions](https://github.com/murny/feedbackbin/discussions) to track
feature requests and questions, and the [issue
tracker](https://github.com/murny/feedbackbin/issues) for actionable tasks and bugs.

> **Note:** We plan to eventually use FeedbackBin itself to collect feedback
> and feature requests. Nothing like dogfooding your own product!

Whenever a discussion leads to an actionable and well-understood task, we'll
move it to the issue tracker where it can be worked on.

This approach makes it easier for us to triage and prioritize work. It also
means that open issues represent agreed-upon tasks that are either being worked
on or are ready to be worked on.

## What This Means in Practice

### If you'd like to contribute to the code...

1. Check out the open issues to see what's available to work on.
2. Make sure someone else isn't already working on the same issue. If they are,
   it will be tagged "in progress" or clear from the comments. When in doubt,
   comment on the issue to ask.
3. If you need any help or guidance on the issue, please comment on the issue
   as you go, and we'll do our best to help.
4. When you have something ready for review or collaboration, open a PR.

### If you've found a bug...

1. If you don't have steps to reproduce the problem, or you're not certain it's
   a bug, open a discussion.
2. If you have steps to reproduce, open an issue.

### If you have an idea for a feature...

1. Open a discussion to share your idea and get feedback.

### If you have a question or need help with configuration...

1. Open a discussion.

## Development Setup

Please see our [Development guide](docs/development.md) for how to get
FeedbackBin set up for local development.

## Code Style

Before submitting code, please ensure:

- All tests pass (`bin/rails test`)
- Code passes linting (`bin/rubocop`)
- ERB templates pass linting (`bin/erb_lint --lint-all`)
- I18n files are healthy (`bin/i18n-tasks health`)

You can run the full CI pipeline locally with:

```sh
bin/ci
```

## Pull Request Guidelines

- Follow Ruby and Rails conventions
- Write tests for new features
- Update documentation for user-facing changes
- Use clear, descriptive commit messages
- Keep PRs focused and reasonably sized

## Areas We Need Help

- Documentation improvements
- Bug fixes and testing
- Internationalization (i18n)
- UI/UX enhancements
- Security audits
- Performance optimizations

## License

By contributing to FeedbackBin, you agree that your contributions will be
licensed under the [O'Saasy License](LICENSE.md).

Thank you for helping make FeedbackBin better!
