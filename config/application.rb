# frozen_string_literal: true

# Main application configuration.
#
# This file sets up the environment, loads dependencies, configures the
# Zeitwerk loader, and defines application-level constants and methods.
#

require "bundler/setup"

Bundler.require(:default)

require "puma/configuration"
require "net/http"

root_path = Pathname(File.join(__dir__, ".."))

loader = Zeitwerk::Loader.new
loader.push_dir(root_path.join("app"))
loader.push_dir(root_path.join("lib"))

loader.inflector.inflect(
  "mcp_ext" => "MCPExt",
)

loader.setup

# Main application module providing configuration methods.
#
module Application
  module_function

  # Fetches the Ollama API key from environment variables
  #
  # @return [String] the Ollama API key
  # @raise [KeyError] if the OLLAMA_API_KEY environment variable is not set
  def fetch_api_key
    @fetch_api_key ||= ENV.fetch("OLLAMA_API_KEY")
  end

  # Returns the default maximum number of search results
  #
  # @return [Integer] the default maximum results (5)
  def max_results_by_default = 5

  # Returns the default HTTP server port
  #
  # @return [Integer] the default port (8080)
  def default_http_server_port = 8080
end
