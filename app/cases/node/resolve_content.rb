# frozen_string_literal: true

class Cases::Node::ResolveContent < ServiceObject
  param :node, Types.Instance(Value::Node)
  option :ignore_value, Types::Bool, default: proc { false }

  def call
    value = ignore_value ? "" : node.data[:text]
    success!(value)
  end
end
