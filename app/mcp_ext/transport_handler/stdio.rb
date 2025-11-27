# frozen_string_literal: true

class MCPExt::TransportHandler::Stdio < MCPExt::TransportHandler
  def self.build_stdio_transport(server)
    MCP::Server::Transports::StdioTransport.new(server)
  end

  def call
    mcp_transport = self.class.build_stdio_transport(transport.server)
    success!(proc { mcp_transport.open })
  end
end
