# frozen_string_literal: true

# MCP tool implementation for web search functionality.
#
# This class implements the MCP tool interface for performing web searches
# using the Ollama web search API. It handles parameter validation, executes
# the search through the service layer, and formats the results for AI assistants.
#
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

    # Processes the tool execution request
    #
    # @param data [Hash] the tool parameters
    # @option data [String] :query The search query string
    # @option data [Integer] :max_results Maximum results to return (optional)
    # @return [MCP::Tool::Response] formatted response for the AI assistant
    # @api private
    #
    # @example Process a web search request
    #   data = { query: "ruby programming", max_results: 3 }
    #   response = proceed_execution!(data)
    #   # => MCP::Tool::Response with formatted search results
    def proceed_execution!(data)
      query = data.delete(:query)
      results = Cases::SearchWeb.call(query, **data).value_or { |error| return render(error.data[:message]) }
      render(format_results(results, query))
    end

    # Formats the search results for presentation to the AI assistant
    #
    # @param results [Array<Entities::RemoteContent>] the search results
    # @param query [String] the original search query
    # @return [String] formatted results string
    # @api private
    #
    # @example Format search results
    #   results = [
    #     Entities::RemoteContent.new(
    #       title: "Ruby", url: "https://ruby-lang.org", content: "programming language", source_type: :search,
    #     ),
    #     Entities::RemoteContent.new(title: "Rails", url: "https://rubyonrails.org", content: "Rails is a web framework", source_type: :search)
    #   ]
    #   output = format_results(results, "ruby programming")
    #   # => "Search results for: ruby programming\n\n1. Ruby\n  URL: https://ruby-lang.org\n  Content: Ruby is a..."
    #       # => "programming language\n\n2. Rails\n  URL: https://rubyonrails.org\n  Content: Rails is a web..."
    #       # => "framework\n\n"
    def format_results(results, query)
      return "No results found for query: #{query}" if results.empty?

      build_results_output(results, query)
    end

    # Builds the complete output string for all results
    #
    # @param results [Array<Entities::RemoteContent>] the search results
    # @param query [String] the original search query
    # @return [String] formatted output string
    # @api private
    def build_results_output(results, query)
      output = "Search results for: #{query}\n\n"

      results.each_with_index do |result, index|
        output << format_result(index + 1, result)
      end

      output.chomp
    end

    # Formats a single search result
    #
    # @param number [Integer] the result number (1-based)
    # @param result [Entities::RemoteContent] the search result to format
    # @return [String] formatted result string
    # @api private
    def format_result(number, result)
      <<~RESULT
        #{number}. #{result.title}
          URL: #{result.url}
          Content: #{result.content}
      RESULT
    end
  end
end
