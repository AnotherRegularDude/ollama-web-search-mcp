# frozen_string_literal: true

require "bundler/setup"

Bundler.require(:default)

root_path = Pathname(File.join(__dir__, ".."))

loader = Zeitwerk::Loader.new
loader.push_dir(root_path.join("app"))

loader.inflector.inflect("mcp_server" => "MCPServer", "mcp_tool" => "MCPTool")

loader.setup

module Application
  module_function

  def fetch_api_key
    @fetch_api_key ||= ENV.fetch("OLLAMA_API_KEY")
  end

  def max_results_by_default = 5
end
