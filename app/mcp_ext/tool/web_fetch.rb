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
    # @param result [Entities::WebFetchResult] the fetch result
    # @return [String] formatted result string
    # @api private
    #
    # @example Format a fetch result
    #   result = Entities::WebFetchResult.new(
    #     title: "Example Domain",
    #     content: "This domain is for use in illustrative examples...",
    #     links: ["https://example.com/more"]
    #   )
    #   output = format_result(result)
    #   # => "Web page content from: Example Domain\nURL: https://example.com/more\n\n"
    #       # => "This domain is for use in illustrative examples..."
    def format_result(result)
      build_result_output(result)
    end

    # Builds the complete output string for the result
    #
    # @param result [Entities::WebFetchResult] the fetch result
    # @return [String] formatted output string
    # @api private
    def build_result_output(result)
      output = "Web page content from: #{result.title}\n"
      output << "URL: #{result.links.first}\n\n" if result.links.any?
      output << result.content

      output
    end
  end
end
