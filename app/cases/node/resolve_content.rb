# frozen_string_literal: true

# Service object for resolving content text from node data.
#
# This service extracts and processes content text from {Value::Node} objects.
# It's primarily used in the formatting pipeline to handle content resolution
# with optional value ignoring for truncation calculations.
#
# @example Resolving content from a node
#   node = Value::Node.new(
#     type: :content,
#     data: { text: "This is the content text" }
#   )
#
#   result = Cases::Node::ResolveContent.call(node)
#   if result.success?
#     content = result.value!
#     puts content # Outputs "This is the content text"
#   end
#
# @example Ignoring content for truncation calculations
#   result = Cases::Node::ResolveContent.call(node, ignore_value: true)
#   if result.success?
#     content = result.value!
#     puts content # Outputs empty string
#   end
class Cases::Node::ResolveContent < ServiceObject
  # @!attribute [r] node
  #   @return [Value::Node] the node containing content data
  param :node, Types.Instance(Value::Node)

  # @!attribute [r] ignore_value
  #   @return [Boolean] whether to ignore the actual content value (default: false)
  option :ignore_value, Types::Bool, default: proc { false }

  # Resolves content text from the node
  #
  # Extracts the text content from the node's data, or returns an empty
  # string if {#ignore_value} is set to true.
  #
  # @return [Resol::Service::Value] a service result containing the resolved content
  # @raise [ArgumentError] if the parameters are invalid
  # @raise [self::Failure] if using `call!` and the service fails
  #
  # @example Basic usage
  #   result = Cases::Node::ResolveContent.call(content_node)
  #   if result.success?
  #     text = result.value!
  #     puts text
  #   end
  #
  # @example Using call! for automatic unwrapping
  #   text = Cases::Node::ResolveContent.call!(content_node)
  #   puts text
  def call
    value = ignore_value ? "" : node.data[:text]
    success!(value)
  end
end
