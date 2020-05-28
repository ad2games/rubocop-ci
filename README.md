# Rubocop for CI

Runs the following tools on your CI:

- rubocop
- brakeman
- scss-lint
- coffeelint
- slim-lint
- standard

## Usage

Run `bundle exec rake rubocop` before committing.
Do not use the plain `rubocop` binary, since that will not use the central
configuration file from this repo.

You can also use `bundle exec rake rubocop:auto_correct` to fix most of the issues automatically.
Please double check the results before committing!

If your project needs relaxed settings, you can generate a `.rubocop_todo.yml`
file using `bundle exec rake rubocop AUTOGEN=1`.

Alternatively, there is a `rubocop:diff` Rake task that runs Rubocop only on
the changes in your branch. This helps if you want to keep Rubocop up-to-date
but don't want to change your whole code-base every time there is an update and
also don't want to mask global settings in a `.rubocop_todo.yml`.

If you do not want to run `scss-lint` on your project (yet),
you can create a `.skip_scss_lint` file in your project root.

To create brakeman exceptions, run `bundle exec brakeman -I` and follow the instructions.

## Installation

Add this to the development/test group in your Gemfile:

```ruby
gem 'rubocop-ci', git: 'https://github.com/ad2games/rubocop-ci'
```

If your project is not a Rails app, add the following to your `Rakefile`:
```ruby
require 'rubocop-ci'
```

Run `bundle exec rake rubocop` before/after your tests on your CI.

## Changes

If you work at ad2games, please open a pull request if you want to change the rubocop config.
Merge it only if it has been approved by the team.

If you want to use this gem for your own company/project, feel free to fork!



