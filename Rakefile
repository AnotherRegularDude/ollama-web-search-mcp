# frozen_string_literal: true

require "bundler/setup"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Start the STDIO MCP server"
task :start do
  exec "bin/mcp_server"
end

desc "Start the HTTP MCP server"
task :start_http, [:port] do |_t, args|
  port = args[:port]
  exec "bin/http_server #{port}"
end

desc "Run RuboCop"
task :rubocop do
  exec "rubocop"
end

desc "Install dependencies"
task :install do
  exec "bundle install"
end
