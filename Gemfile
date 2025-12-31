# frozen_string_literal: true

source "https://rubygems.org"
ruby File.read(File.join(__dir__, ".ruby-version")).rstrip

gem "mcp"
gem "puma"
gem "rack"
gem "zeitwerk"

gem "openssl", "~> 3.3.1"
gem "rake"

gem "dry-initializer"
gem "dry-struct"
gem "dry-types"
gem "resol", git: "https://github.com/umbrellio/resol", branch: "feature/add-dry-initializer"

group :development, :test do
  gem "pry"
  gem "rspec"
  gem "rspec-json_matcher", require: false
  gem "rubocop", require: false
  gem "simplecov", require: false
  gem "simplecov-lcov", require: false
  gem "webmock", require: false
end
