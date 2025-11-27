# frozen_string_literal: true

class MCPExt::Tool::WebSearch < MCPExt::Tool::Base
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
    private

    def proceed_execution!(data)
      query = data.delete(:query)
      results = Cases::SearchWeb.call(query, **data).value_or { |error| return render(error.data[:message]) }
      render(format_results(results, query))
    rescue ArgumentError => e
      render(e.message)
    end

    def format_results(results, query)
      return "No results found for query: #{query}" if results.empty?

      build_results_output(results, query)
    end

    def build_results_output(results, query)
      output = "Search results for: #{query}\n\n"

      results.each_with_index do |result, index|
        output << format_result(index + 1, result)
      end

      output
    end

    def format_result(number, result)
      <<~RESULT
        #{number}. #{result.title}
          URL: #{result.url}
          Content: #{result.content}
      RESULT
    end
  end
end
