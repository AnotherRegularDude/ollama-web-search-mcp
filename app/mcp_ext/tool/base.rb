# frozen_string_literal: true

# Base class for MCP tools in this application.
#
# This class extends the MCP::Tool class and provides common functionality
# for all tools in the application, including a standard execution interface
# and response rendering.
#
class MCPExt::Tool::Base < MCP::Tool
  class << self
    # Executes the tool with the provided data
    #
    # @param data [Hash] the tool parameters
    # @return [MCP::Tool::Response] the tool response
    def call(**data)
      proceed_execution!(data)
    end

    private

    # Renders text content as an MCP tool response
    #
    # @param text [String] the response text
    # @return [MCP::Tool::Response] the formatted response
    # @api private
    def render(text)
      MCP::Tool::Response.new([type: "text", text: text])
    end
  end
end
