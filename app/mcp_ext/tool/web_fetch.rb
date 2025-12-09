# frozen_string_literal: true

# MCP tool implementation for web fetch functionality.
#
# This class implements the MCP tool interface for fetching web content
# using the Ollama web fetch API. It handles parameter validation, executes
# the fetch through the service layer, and formats the results for AI assistants.
#
class MCPExt::Tool::WebFetch < MCPExt::Tool::Base
  description "A tool that provides access to fetching web page content using Ollama's web fetch API."
  input_schema(
    properties: {
      url: { type: "string", description: "The URL of the web page to fetch" },
    },
    required: ["url"],
  )

  class << self
    private

    # Processes the tool execution request
    #
    # @param data [Hash] the tool parameters
    # @option data [String] :url The URL to fetch
    # @return [MCP::Tool::Response] formatted response for the AI assistant
    # @api private
    #
    # @example Process a web fetch request
    #   data = { url: "https://example.com" }
    #   response = proceed_execution!(data)
    #   # => MCP::Tool::Response with formatted web content
    def proceed_execution!(data)
      url = data.delete(:url)
      result = Cases::WebFetch.call(url).value_or { |error| return render(error.data[:message]) }
      render(format_result(result))
    end

    # Formats the fetch result for presentation to the AI assistant
    #
    # @param result [Entities::RemoteContent] the fetch result
    # @return [String] formatted result string
    # @api private
    #
    # @example Format a fetch result
    #   result = Entities::RemoteContent.new(
    #     title: "Example Domain",
    #     url: "https://example.com",
    #     content: "This domain is for use in illustrative examples...",
    #     related_content: [Value::ContentPointer.new(link: "https://example.com/more")],
    #     source_type: :fetch
    #   )
    #   output = format_result(result)
    #   # => "# Example Domain\n\n## Content\nThis domain is for use in illustrative examples...\n\n## Links\nURL: https://example.com\nOn Page:\n- https://example.com/more"
    def format_result(result)
      formatter = Formatters::WebContentFormatter.new
      formatter.format(result)
    end
  end
end
