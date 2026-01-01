# frozen_string_literal: true

# Represents a transport configuration for the MCP server.
# This entity holds information about the type of transport (stdio or HTTP)
# and associated configuration data.
#
# @see MCPExt::TransportHandler for transport implementation
# @see Application for default configuration values
class Entities::Transport < AbstractStruct
  # Schema definition for transport configuration data
  #
  # Defines the structure and validation rules for transport configuration.
  #
  # @!attribute [r] mcp_version
  #   @return [String] the MCP protocol version (default: Application.default_mcp_protocol_version)
  # @!attribute [r] port
  #   @return [Integer] the HTTP server port (default: Application.default_http_server_port)
  #
  # @example Transport data structure
  #   {
  #     mcp_version: "2025-06-18",
  #     port: 8080
  #   }
  DATA_SCHEMA = Types::Hash.schema(
    mcp_version: Types::String.default(Application.default_mcp_protocol_version),
    port: Types::Integer.default(Application.default_http_server_port),
  ).with_key_transform(&:to_sym)

  # @!attribute [r] type
  #   @return [Symbol] the transport type (:stdio or :http)

  # @!attribute [r] data
  #   @return [Hash] the transport configuration data

  attribute :type, Types::Symbol.enum(:stdio, :http)
  attribute :data, DATA_SCHEMA

  def mcp_version
    data[:mcp_version]
  end
end
