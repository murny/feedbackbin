# FeedbackBin

DISCLAIMER: Very early software, everything is in flight and in progress. 

TODO: Add description/screenshots/etc in this section

## Technology Stack

* Ruby on Rails 8.X
* Ruby 3.3.x
* Hotwire
* Import maps
* Solid Cable
* Solid Cache
* Solid Queue
* SQLite3
* Tailwind CSS

## Installation
1. Clone the repository: `git clone https://github.com/murny/feedbackbin.git`
2. Navigate to the project directory: `cd feedbackbin`
3. Install dependencies: `bundle install`

## Configuration

TODO: Add section about credentials and other configuration setup?

## Running the application

1. Run `bin/setup` 

By default `bin/setup` will also run `bin/dev` which will start the Rails server. To opt out of this use `bin/setup --skip-server` instead.

## Linting & Formatting

#### Ruby

We use [Standard Ruby](https://github.com/standardrb/standard) for linting and formatting.
- Run `bin/rubocop` to check all ruby files
- Run `bin/rubocop -a` to auto-correct offenses
- [How do I run RuboCop in my editor?](https://docs.rubocop.org/rubocop/1.25/integration_with_other_tools.html#editor-integration)

#### ERB

We use [ERB Lint](https://github.com/Shopify/erb-lint) to lint our ERB files.
- Run `bundle exec erblint --lint-all` to check all ERB files
- Run `bundle exec erblint --lint-all -a` to auto-correct offenses. WARNING: This command isn't safe and can break your code.

#### I18n

We use [I18n Task](https://github.com/glebm/i18n-tasks) for linting and formatting our I18n files.
- Run `bundle exec i18n-tasks health` to check the health of your I18n files.
- Run `bundle exec i18n-tasks normalize` to normalize your I18n files.

## Testing

Run tests by using `bin/rails test`.

#### System tests

Run tests by using `bin/rails test:system`.

## Deployment
TODO: Need to add more info here, but essentially we use [Kamal](https://github.com/basecamp/kamal)

Will need to add docs here for setting up a VPS/Adding let's encrypt and configuration/commands required.

## Contributing
TODO: Need to add more info here

We welcome contributions! Please see our [contributing guidelines](CONTRIBUTING.md) for more information.


## Contact
TODO: Add more info here

Soon will have a discord server setup

## License

Inspired by [Plausible](https://plausible.io/blog/open-source-licenses), FeedbackBin is open-source under the GNU Affero General Public License Version 3 (AGPLv3) or any later version. You can [find it here](https://github.com/murny/feedbackbin/blob/main/LICENSE.md).
