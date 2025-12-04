# frozen_string_literal: true

# Service object for performing web searches using the Ollama web search API.
#
# This service processes web search requests and returns structured results.
# It handles the communication with the Ollama gateway and maps the raw API
# responses to typed entities.
#
class Cases::SearchWeb < ServiceObject
  # @!attribute [r] query
  #   @return [String] the search query string

  # @!attribute [r] max_results
  #   @return [Integer] maximum number of results to return (optional)

  param :query, Types::String
  option :max_results, Types::Integer.constrained(included_in: 1..10), optional: true

  # Executes the web search and returns the results
  #
  # @return [Resol::Service::Value] a service result containing an array of {Entities::Result} objects
  # @raise [ArgumentError] if the parameters are invalid
  #
  # @example Basic usage
  #   result = Cases::SearchWeb.call("ruby programming")
  #   if result.success?
  #     results = result.value!
  #     results.each do |item|
  #       puts "#{item.title}: #{item.url}"
  #     end
  #   end
  #
  # @example With maximum results limit
  #   result = Cases::SearchWeb.call("ruby programming", max_results: 3)
  def call
    self.results = search!
    map_results!

    success!(results)
  end

  private

  # @!attribute [rw] results
  #   @return [Array<Hash>] raw search results from the API

  attr_accessor :results

  # Performs the actual search using the Ollama gateway
  #
  # @return [Array<Hash>] raw search results from the API
  # @raise [Adapters::OllamaGateway::HTTPError] if the HTTP request fails
  def search!
    Adapters::OllamaGateway.process_web_search!(
      query: query,
      max_results: max_results || Application.max_results_by_default,
    )
  rescue Adapters::OllamaGateway::HTTPError => e
    fail!(:request_failed, { message: e.message })
  end

  # Maps raw API results to typed entities
  #
  # @return [void]
  def map_results!
    results.map! do |result|
      Entities::Result.new(
        title: result["title"],
        url: result["url"],
        content: result["content"],
      )
    end
  end
end
