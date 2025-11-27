# frozen_string_literal: true

class MCPExt::TransportHandler < ServiceObject
  builds { |transport| const_get(transport.type.capitalize) }

  param :transport, Types.Instance(Entities::Transport)
end
