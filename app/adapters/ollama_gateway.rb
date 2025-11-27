# frozen_string_literal: true

module Adapters::OllamaGateway
  extend self

  SEARCH_URL = URI("https://ollama.com/api/web_search").freeze

  class HTTPError < StandardError; end

  def process_web_search!(query:, max_results:)
    response = http_client.post(SEARCH_URL.path, build_payload(query, max_results).to_json, build_headers)
    raise HTTPError, "Error: HTTP #{response.code} - #{response.body}" unless response.code == "200"

    body = JSON.parse(response.body)
    body.fetch("results", [])
  rescue Timeout::Error => e
    raise HTTPError, "HTTP Timeout: #{e.message}"
  end

  def build_payload(query, max_results)
    {
      query: query,
      max_results: max_results,
    }
  end

  def build_headers
    {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{Application.fetch_api_key}",
    }
  end

  private

  def http_client
    @http_client ||= Net::HTTP.start(SEARCH_URL.hostname, SEARCH_URL.port, { use_ssl: true })
  end
end
