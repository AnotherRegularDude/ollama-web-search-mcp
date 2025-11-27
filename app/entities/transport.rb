# frozen_string_literal: true

class Entities::Transport < AbstractStruct
  DATA_SCHEMAS = [
    Types::Hash.schema(port: Types::Integer.default(Application.default_http_server_port)),
  ].freeze

  attribute :type, Types::Symbol.enum(:stdio, :http)
  attribute :data, DATA_SCHEMAS.inject(&:|)

  attribute? :server, Types.Instance(MCP::Server)

  def with_server(server)
    self.class.new(type:, data:, server:)
  end
end
