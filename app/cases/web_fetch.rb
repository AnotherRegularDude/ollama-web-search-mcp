# frozen_string_literal: true

# Service object for fetching web content using the Ollama web fetch API.
#
# This service processes web fetch requests and returns structured results.
# It handles the communication with the Ollama gateway and maps the raw API
# responses to typed entities.
#
class Cases::WebFetch < ServiceObject
  # @!attribute [r] url
  #   @return [String] the URL to fetch

  param :url, Types::String

  # Executes the web fetch and returns the results
  #
  # @return [Resol::Service::Value] a service result containing a {Entities::WebFetchResult} object
  # @raise [ArgumentError] if the parameters are invalid
  #
  # @example Basic usage
  #   result = Cases::WebFetch.call("https://example.com")
  #   if result.success?
  #     fetch_result = result.value
  #     puts fetch_result.title
  #     puts fetch_result.content
  #     puts fetch_result.links
  #   end
  def call
    self.result = fetch!
    map_result!

    success!(result)
  end

  private

  # @!attribute [rw] result
  #   @return [Hash] raw fetch result from the API

  attr_accessor :result

  # Performs the actual fetch using the Ollama gateway
  #
  # @return [Hash] raw fetch result from the API
  # @raise [Adapters::OllamaGateway::HTTPError] if the HTTP request fails
  def fetch!
    Adapters::OllamaGateway.process_web_fetch!(url: url)
  rescue Adapters::OllamaGateway::HTTPError => e
    fail!(:request_failed, { message: e.message })
  end

  # Maps raw API result to typed entity
  #
  # @return [void]
  def map_result!
    self.result = Entities::WebFetchResult.new(
      title: result["title"],
      content: result["content"],
      links: result["links"],
    )
  end
end
