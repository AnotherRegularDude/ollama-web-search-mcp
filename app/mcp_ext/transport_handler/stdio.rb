# frozen_string_literal: true

# Handler for STDIO transport configuration.
#
# This class configures and starts an MCP server using STDIO transport,
# which is suitable for direct integration with AI assistants.
#
class MCPExt::TransportHandler::Stdio < MCPExt::TransportHandler
  # Builds a STDIO transport for the MCP server
  #
  # @param context [MCPExt::ServerContext] the server context
  # @return [MCP::Server::Transports::StdioTransport] the STDIO transport
  # @api private
  def self.build_stdio_transport(context)
    MCP::Server::Transports::StdioTransport.new(context.server)
  end

  # Configures and starts the STDIO transport
  #
  # @return [Resol::Service::Value] a service result containing a proc to start the transport
  def call
    mcp_transport = self.class.build_stdio_transport(context)
    success!(proc { mcp_transport.open })
  end
end
