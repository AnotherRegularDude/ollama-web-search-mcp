# frozen_string_literal: true

# Root node value object for formatting schemas.
#
# This value object represents the root of a formatting schema structure,
# containing metadata about the content and child nodes that will be
# processed by the formatter pipeline.
#
# @see Cases::Formatter::Base for base formatter implementation
# @see Value::Node for child node structure
# @see Cases::Node::RenderMarkdown for rendering to Markdown
class Value::RootNode < AbstractStruct
  # @!attribute [r] metadata
  #   @return [Hash] metadata about the content (query, source, URL, etc.)

  # @!attribute [r] children
  #   @return [Array<Value::Node>] array of child nodes to render

  attribute :metadata, Types::Hash
  attribute :children, Types::Array.of(Types.Instance(Value::Node))

  # @example Creating a root node for search results
  #   Value::RootNode.new(
  #     metadata: { query: "ruby programming", total_results: 5 },
  #     children: [
  #       Value::Node.new(type: :header, data: { text: "Search Results" }),
  #       Value::Node.new(type: :result, data: { title: "Ruby", url: "https://ruby-lang.org" })
  #     ]
  #   )
  #
  # @example Creating a root node for fetched content
  #   Value::RootNode.new(
  #     metadata: { url: "https://example.com", source: :fetch },
  #     children: [
  #       Value::Node.new(type: :metadata, data: { source: :fetch, url: "https://example.com" }),
  #       Value::Node.new(type: :content, data: { text: "Content text..." })
  #     ]
  #   )
end
