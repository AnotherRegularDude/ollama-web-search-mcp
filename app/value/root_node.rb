# frozen_string_literal: true

class Value::RootNode < AbstractStruct
  attribute :metadata, Types::Hash
  attribute :children, Types::Array.of(Types.Instance(Value::Node))
end
