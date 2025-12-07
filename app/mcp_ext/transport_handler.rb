# frozen_string_literal: true

# Base class for handling different transport types for the MCP server.
#
# This service object routes transport configuration to the appropriate
# handler based on the transport type (stdio or HTTP).
#
class MCPExt::TransportHandler < ServiceObject
  # Builds the appropriate transport handler based on transport type
  #
  # @param transport [Entities::Transport] the transport configuration
  builds { |transport| const_get(transport.type.capitalize) }

  # @!attribute [r] transport
  #   @return [Entities::Transport] the transport configuration

  param :transport, Types.Instance(Entities::Transport)

  # @example Handle a STDIO transport
  #   transport = Entities::Transport.new(type: :stdio, data: {})
  #   result = MCPExt::TransportHandler.call(transport)
  #
  # @example Handle an HTTP transport
  #   transport = Entities::Transport.new(type: :http, data: { port: 8080 })
  #   result = MCPExt::TransportHandler.call(transport)
end
