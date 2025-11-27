# frozen_string_literal: true

require "bundler/setup"

Bundler.require(:default)

require "puma/configuration"

root_path = Pathname(File.join(__dir__, ".."))

loader = Zeitwerk::Loader.new
loader.push_dir(root_path.join("app"))
loader.push_dir(root_path.join("lib"))

loader.inflector.inflect(
  "mcp_ext" => "MCPExt",
)

loader.setup

module Application
  module_function

  def fetch_api_key
    @fetch_api_key ||= ENV.fetch("OLLAMA_API_KEY")
  end

  def max_results_by_default = 5

  def default_http_server_port = 8080
end
