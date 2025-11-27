# frozen_string_literal: true

class MCPExt::Tool::Base < MCP::Tool
  class << self
    def call(**data)
      proceed_execution!(data)
    end

    private

    def render(text)
      MCP::Tool::Response.new([type: "text", text: text])
    end
  end
end
