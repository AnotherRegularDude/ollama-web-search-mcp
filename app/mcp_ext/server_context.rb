# frozen_string_literal: true

class MCPExt::ServerContext < AbstractStruct
  attribute :server, Types.Instance(MCP::Server)
  attribute :transport, Types.Instance(Entities::Transport)

  def type = transport.type
end
