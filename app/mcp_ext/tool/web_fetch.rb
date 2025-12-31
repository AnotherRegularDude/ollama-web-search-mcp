# frozen_string_literal: true

# MCP tool implementation for web content fetching functionality.
#
# This class implements the MCP tool interface for fetching web content
# using the Ollama web search API. It handles parameter validation, executes
# the fetch through the service layer, and formats the results for AI assistants.
#
class MCPExt::Tool::WebFetch < MCPExt::Tool::Base
  description "A tool that provides access to fetching web page content using Ollama's web fetch API."
  input_schema(
    properties: {
      url: { type: "string", description: "The URL to fetch content from" },
      truncate: {
        type: "boolean",
        description: "Whether to truncate the content",
        default: true,
      },
      max_chars: {
        type: "integer",
        description: "Maximum number of characters to return",
        default: 120_000,
        minimum: 0,
      },
    },
    required: ["url"],
  )

  class << self
    private

    # Processes the tool execution request
    #
    # @param data [Hash] the tool parameters
    # @option data [String] :url The URL to fetch content from
    # @option data [Boolean] :truncate Whether to truncate the content
    # @option data [Integer] :max_chars Maximum number of characters to return
    # @return [MCP::Tool::Response] formatted response for the AI assistant
    # @api private
    #
    # @example Process a web fetch request
    #   data = { url: "https://example.com" }
    #   response = proceed_execution!(data)
    #   # => MCP::Tool::Response with formatted web content
    def proceed_execution!(data)
      url = data.delete(:url)
      result = Cases::WebFetch.call(url).value_or { return render(it.message) }
      render(format_result(result, data))
    end

    # Formats the web fetch result for presentation to the AI assistant
    #
    # @param result [Entities::RemoteContent] the web fetch result
    # @param options [Hash] formatting options including truncate and max_chars
    # @return [String] formatted result string
    # @api private
    #
    # @example Format a web fetch result
    #   result = Entities::RemoteContent.new(
    #     title: "Example Domain",
    #     url: "https://example.com",
    #     content: "content...",
    #     related_content: [Value::ContentPointer.new(link: "https://example.com/more")],
    #     source_type: :fetch
    #   )
    #   format_result(result, {})
    #   # => "**Source:** fetch\n**URL:** https://example.com\n\n---\n\ncontent..."
    def format_result(result, options = {})
      Cases::Formatter::FetchResult.call!(result, options:)
    end
  end
end
