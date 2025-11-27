# frozen_string_literal: true

# Adapter for communicating with the Ollama web search API.
#
# This module provides methods to interact with the Ollama web search endpoint,
# handling HTTP requests, authentication, and response processing.
#
module Adapters::OllamaGateway
  extend self

  # The URL for the Ollama web search API endpoint
  # @return [URI]
  SEARCH_URL = URI("https://ollama.com/api/web_search").freeze

  # Custom error class for HTTP-related errors
  class HTTPError < StandardError; end

  # Processes a web search request through the Ollama API
  #
  # @param query [String] the search query string
  # @param max_results [Integer] maximum number of results to return
  # @return [Array<Hash>] an array of raw search results
  # @raise [HTTPError] if the HTTP request fails or times out
  #
  # @example
  #   results = Adapters::OllamaGateway.process_web_search!(
  #     query: "ruby programming",
  #     max_results: 5
  #   )
  def process_web_search!(query:, max_results:)
    response = http_client.post(SEARCH_URL.path, build_payload(query, max_results).to_json, build_headers)
    raise HTTPError, "Error: HTTP #{response.code} - #{response.body}" unless response.code == "200"

    body = JSON.parse(response.body)
    body.fetch("results", [])
  rescue Timeout::Error => e
    raise HTTPError, "HTTP Timeout: #{e.message}"
  end

  private

  # Builds the payload for the API request
  #
  # @param query [String] the search query string
  # @param max_results [Integer] maximum number of results to return
  # @return [Hash] the request payload
  # @api private
  def build_payload(query, max_results)
    {
      query: query,
      max_results: max_results,
    }
  end

  # Builds the HTTP headers for the API request
  #
  # @return [Hash] the HTTP headers
  # @api private
  def build_headers
    {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{Application.fetch_api_key}",
    }
  end

  # Returns the HTTP client instance
  #
  # @return [Net::HTTP] the HTTP client
  # @api private
  def http_client
    @http_client ||= Net::HTTP.start(SEARCH_URL.hostname, SEARCH_URL.port, { use_ssl: true })
  end
end
