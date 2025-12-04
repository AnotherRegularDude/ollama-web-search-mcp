# frozen_string_literal: true

# Adapter for communicating with the Ollama web search API.
#
# This module provides methods to interact with the Ollama web search endpoint,
# handling HTTP requests, authentication, and response processing.
#
# @!method self.process_web_search!(query:, max_results:)
#   @see Adapters::OllamaGateway#process_web_search!
#
# @!method self.process_web_fetch!(url:)
#   @see Adapters::OllamaGateway#process_web_fetch!
#
module Adapters::OllamaGateway
  extend self

  # The base URL for the Ollama API endpoints
  # @return [String] the base URL used for all API requests
  BASE_URL = "https://ollama.com/api"

  # The URL for the Ollama web search API endpoint
  # @return [URI]
  SEARCH_URL = URI(File.join(BASE_URL, "web_search")).freeze

  # The URL for the Ollama web fetch API endpoint
  # @return [URI]
  FETCH_URL = URI(File.join(BASE_URL, "web_fetch")).freeze

  # Custom error class for HTTP-related errors
  class HTTPError < StandardError; end

  # Processes a web search request through the Ollama API
  #
  # @param query [String] the search query string
  # @param max_results [Integer] maximum number of results to return (1-10)
  # @return [Array<Hash>] an array of raw search results
  # @raise [HTTPError] if the HTTP request fails, times out, or response code is not 200
  #
  # @example Search for ruby programming with 5 results
  #   results = Adapters::OllamaGateway.process_web_search!(
  #     query: "ruby programming",
  #     max_results: 5
  #   )
  #   # => [{"title"=>"Ruby Programming", "url"=>"https://example.com", "content"=>"..."}, ...]
  #
  # @example Search for news with default results
  #   results = Adapters::OllamaGateway.process_web_search!(
  #     query: "latest news",
  #     max_results: Application.max_results_by_default
  #   )
  def process_web_search!(query:, max_results:)
    response = request!(SEARCH_URL.path, build_search_payload(query, max_results))
    response.fetch("results", [])
  end

  # Processes a web fetch request through the Ollama API
  #
  # @param url [String] the URL to fetch
  # @return [Hash] a raw fetch result containing title, content, and links
  # @raise [HTTPError] if the HTTP request fails, times out, or response code is not 200
  #
  # @example Fetch content from a URL
  #   result = Adapters::OllamaGateway.process_web_fetch!(
  #     url: "https://example.com"
  #   )
  #   # => {"title"=>"Example Domain", "content"=>"...", "links"=>["https://example.com/more"]}
  def process_web_fetch!(url:)
    request!(FETCH_URL.path, build_fetch_payload(url))
  end

  private

  # Builds the payload for the web search API request
  #
  # @param query [String] the search query string
  # @param max_results [Integer] maximum number of results to return (1-10)
  # @return [Hash] the web search request payload
  # @api private
  def build_search_payload(query, max_results)
    {
      query: query,
      max_results: max_results,
    }
  end

  # Builds the payload for the fetch API request
  #
  # @param url [String] the URL to fetch
  # @return [Hash] the request payload
  # @api private
  def build_fetch_payload(url)
    {
      url: url,
    }
  end

  # Makes a POST request to the API and processes the response
  #
  # @param path [String] the API endpoint path
  # @param payload [Hash] the request payload in JSON format
  # @return [Hash] parsed JSON response body
  # @raise [HTTPError] if the HTTP request fails, times out, or response code is not 200
  # @api private
  #
  # @example Make a request to the search endpoint
  #   response = request!("/api/web_search", '{"query":"ruby","max_results":5}')
  #   # => {"results"=>[{"title"=>"Ruby", "url"=>"...", "content"=>"..."}]}
  def request!(path, payload)
    response = http_client.post(path, payload.to_json, headers)
    raise HTTPError, "Error: HTTP #{response.code} - #{response.body}" unless response.code == "200"

    JSON.parse(response.body)
  rescue Timeout::Error => e
    raise HTTPError, "HTTP Timeout: #{e.message}"
  end

  # Builds the HTTP headers for the API request
  #
  # @return [Hash] the HTTP headers including content type and authorization
  # @api private
  def headers
    @headers ||= {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{Application.fetch_api_key}",
    }
  end

  # Returns the HTTP client instance
  #
  # @return [Net::HTTP] the HTTP client configured for SSL
  # @api private
  def http_client
    @http_client ||= Net::HTTP.start(SEARCH_URL.hostname, SEARCH_URL.port, { use_ssl: true })
  end
end
