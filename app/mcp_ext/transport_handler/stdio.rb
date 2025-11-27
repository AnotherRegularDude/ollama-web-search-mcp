# frozen_string_literal: true

# Handler for STDIO transport configuration.
#
# This class configures and starts an MCP server using STDIO transport,
# which is suitable for direct integration with AI assistants.
#
class MCPExt::TransportHandler::Stdio < MCPExt::TransportHandler
  # Builds a STDIO transport for the MCP server
  #
  # @param server [MCP::Server] the MCP server instance
  # @return [MCP::Server::Transports::StdioTransport] the STDIO transport
  # @api private
  def self.build_stdio_transport(server)
    MCP::Server::Transports::StdioTransport.new(server)
  end

  # Configures and starts the STDIO transport
  #
  # @return [Resol::Service::Value] a service result containing a proc to start the transport
  def call
    mcp_transport = self.class.build_stdio_transport(transport.server)
    success!(proc { mcp_transport.open })
  end
end
