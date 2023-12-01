# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

# Build a persistent domain model by mapping database tables to Ruby classes
gem 'activerecord', '~> 7.1', '>= 7.1.1'

# A toolkit of support libraries and Ruby core extensions extracted from the Rails framework
gem 'activesupport', '~> 7.1', '>= 7.1.1'

# Rake is a Make-like program implemented in Ruby
gem 'rake', '~> 13.1'

# Ruby library to interface with the SQLite3 database engine
gem 'sqlite3', '~> 1.6'

# Ruby wrapper for Telegram's Bot API
gem 'telegram-bot-ruby', git: 'https://github.com/atipugin/telegram-bot-ruby.git', branch: 'master'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  # Provides a framework and DSL for defining and using factories
  # Pry is a runtime developer console
  gem 'pry', '~> 0.14.1'
  # Provides a pure Ruby implementation of the GNU readline C library
  gem 'rb-readline', '~> 0.5.5'
end

group :development do
  # A Ruby parser written in pure Ruby.
  gem 'parser', '~> 3.1', '>= 3.1.2.0'

  # Code style checking and code formatting tool
  gem 'rubocop', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rake', require: false

  # ruby-prof is a fast code profiler for Ruby
  gem 'ruby-prof', '~> 1.4', '>= 1.4.3'

  # YARD is a Ruby Documentation tool
  gem 'yard', require: false
end

group :test do
  # minitest provides a complete suite of testing facilities
  gem 'minitest', '~> 5.20'
end
