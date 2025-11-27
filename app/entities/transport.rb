# frozen_string_literal: true

# Represents a transport configuration for the MCP server.
# This entity holds information about the type of transport (stdio or HTTP)
# and associated configuration data.
#
class Entities::Transport < AbstractStruct
  # Schema definitions for transport data
  # @return [Array<Dry::Types::Schema>]
  DATA_SCHEMAS = [
    Types::Hash.schema(port: Types::Integer.default(Application.default_http_server_port)),
  ].freeze

  # @!attribute [r] type
  #   @return [Symbol] the transport type (:stdio or :http)

  # @!attribute [r] data
  #   @return [Hash] the transport configuration data

  # @!attribute [r] server
  #   @return [MCP::Server] the MCP server instance (optional)

  attribute :type, Types::Symbol.enum(:stdio, :http)
  attribute :data, DATA_SCHEMAS.inject(&:|)

  attribute? :server, Types.Instance(MCP::Server)

  # Creates a new transport instance with the specified server
  #
  # @param server [MCP::Server] the MCP server instance
  # @return [Entities::Transport] a new transport instance with the server
  def with_server(server)
    self.class.new(type:, data:, server:)
  end
end
