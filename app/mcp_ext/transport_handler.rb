# frozen_string_literal: true

# Base class for handling different transport types for the MCP server.
#
# This service object routes transport configuration to the appropriate
# handler based on the transport type (stdio or HTTP).
#
class MCPExt::TransportHandler < ServiceObject
  # Builds the appropriate transport handler based on transport type
  #
  # @param context [MCPExt::ServerContext] the server context containing transport configuration
  builds { |context| const_get(context.type.capitalize) }

  # @!attribute [r] context
  #   @return [MCPExt::ServerContext] the server context containing transport and server

  param :context, Types.Instance(MCPExt::ServerContext)

  private

  def transport
    context.transport
  end

  def server
    context.server
  end
end
