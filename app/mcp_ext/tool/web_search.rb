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
      render(format_results(results, query: query, max_results: data[:max_results]))
    end

    # Formats the search results for presentation to the AI assistant
    #
    # @param results [Array<Entities::RemoteContent>] the search results
    # @param options [Hash] formatting options
    # @option options [String] :query the original search query
    # @option options [Integer] :max_results maximum number of results to include
    # @return [String] formatted results string
    # @api private
    def format_results(results, options = {})
      formatter = Formatters::SearchResultsFormatter.new
      formatter.format(results, options)
    end
  end
end
