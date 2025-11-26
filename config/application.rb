# frozen_string_literal: true

require "bundler/setup"

Bundler.require(:default)

module Application
  module_function

  def fetch_api_key
    @fetch_api_key ||= ENV.fetch("OLLAMA_API_KEY")
  end

  def max_results_by_default = 5
end
