# Changelog

## v2.9.7

- Ruby 1.9.2 support

## v2.9.6

- Fix for numericality's greater_than and less_than

## v2.9.5

- Better Javascript Regular Expression conversion

## v2.9.4

- Fixes for Rails 3.0.0 Final

## v2.9.3

- Fixed bug with confirmation validations... probably the result of the refactor from v2.6.3

## v2.9.0

- The Uniqueness middleware is automatically setup as a middleware via a Rails Engine
- Cleaned up ActiveRecord::Base method pollution
- Removed DNCLabs namespace
- validates_numericality_of: even / odd support, added numericality jquery-validation function, 
- Now using Bundler's gemspec command to keep dependencies in the gemspec

For versions previous to 2.9.0 please refer to the README for the specific version
