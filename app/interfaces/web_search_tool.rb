# frozen_string_literal: true

class Interfaces::WebSearchTool < Interfaces::MCPTool
  description "A tool that provides access to searching the internet using Ollama's web search API."
  input_schema(
    properties: {
      query: { type: "string", description: "The search query string" },
      max_results: {
        type: "integer",
        description: "Maximum results to return (default 5, max 10)",
        minimum: 1,
        maximum: 10,
      },
    },
    required: ["query"],
  )

  class << self
    def call(query:, max_results: Application.max_results_by_default)
      results = Cases::SearchWeb.call!(query, max_results: max_results)
      response_from_text(format_results(results, query))
    rescue Adapters::OllamaGateway::HTTPError => e
      response_from_text(e.message)
    end

    private

    def format_results(results, query)
      return "No results found for query: #{query}" if results.empty?

      build_results_output(results, query)
    end

    def build_results_output(results, query)
      formatted_results = "Search results for: #{query}\n\n"

      results.each_with_index do |result, index|
        formatted_results << "#{index + 1}. #{result.title}\n"
        formatted_results << "   URL: #{result.url}\n"
        formatted_results << "   Content: #{result.content}\n\n"
      end

      formatted_results
    end
  end
end
