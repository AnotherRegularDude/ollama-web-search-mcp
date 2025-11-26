# frozen_string_literal: true

class Interfaces::MCPTool < MCP::Tool
  class << self
    private

    def response_from_text(text)
      MCP::Tool::Response.new(
        [{
          type: "text",
          text: text,
        }],
      )
    end
  end
end
