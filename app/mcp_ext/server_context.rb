# frozen_string_literal: true

class ServerContext < AbstractStruct
  attribute :server, Types.Instance(MCP::Server)
  attribute :transport, Types.Instance(MCPExt::TransportHandler)

  def type = transport.type
end
