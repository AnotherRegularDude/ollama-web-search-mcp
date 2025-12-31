# frozen_string_literal: true

# Represents a transport configuration for the MCP server.
# This entity holds information about the type of transport (stdio or HTTP)
# and associated configuration data.
#
class Entities::Transport < AbstractStruct
  DATA_SCHEMA = Types::Hash.schema(
    mcp_version: Types::String.default(Application.default_mcp_protocol_version),
    port: Types::Integer.default(Application.default_http_server_port),
  ).with_key_transform(&:to_sym)

  # @!attribute [r] type
  #   @return [Symbol] the transport type (:stdio or :http)

  # @!attribute [r] data
  #   @return [Hash] the transport configuration data

  # @!attribute [r] server
  #   @return [MCP::Server] the MCP server instance (optional)

  attribute :type, Types::Symbol.enum(:stdio, :http)
  attribute :data, DATA_SCHEMA
end
