# frozen_string_literal: true

# Context container for MCP server instances and their transport configurations.
#
# This entity holds both the MCP server instance and its associated transport
# configuration, providing a unified interface for server management.
#
# @see MCPExt::ServerFactory for server creation
# @see Entities::Transport for transport configuration
class MCPExt::ServerContext < AbstractStruct
  # @!attribute [r] server
  #   @return [MCP::Server] the MCP server instance

  # @!attribute [r] transport
  #   @return [Entities::Transport] the transport configuration for the server

  attribute :server, Types.Instance(MCP::Server)
  attribute :transport, Types.Instance(Entities::Transport)

  # Returns the transport type of the server context
  #
  # @return [Symbol] the transport type (:stdio or :http)
  #
  # @example Getting transport type
  #   context.type # => :stdio or :http
  def type = transport.type
end
