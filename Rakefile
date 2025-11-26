# frozen_string_literal: true

require "bundler/setup"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Start the STDIO MCP server"
task :start do
  exec "ruby bin/mcp_server.rb"
end

desc "Start the HTTP MCP server"
task :start_http, [:port] do |_t, args|
  port = args[:port] || 8080
  exec "ruby bin/http_server.rb #{port}"
end

desc "Run RuboCop"
task :rubocop do
  exec "rubocop"
end

desc "Install dependencies"
task :install do
  exec "bundle install"
end
