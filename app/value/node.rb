# frozen_string_literal: true

# Generic tree node structure for representing formatted content.
#
# This class represents a node in a tree structure used for formatting content.
# Each node has a type, associated data, and optional children nodes.
#
# ## Node Types and Data Formats
#
# ### Root Node Types
# - `:search` - Root node for search results
#   * Data: `query`, `total_results`, optionally `header`
#   * Children: `:header`, `:result` nodes
#
# - `:fetch` - Root node for fetched content
#   * Data: `url`, `source`
#   * Children: `:metadata`, `:content`, `:links` nodes
#
# ### Content Node Types
# - `:header` - Header text
#   * Data: `text` (String)
#
# - `:result` - Individual search result
#   * Data: `title` (String), `url` (String), `source` (Symbol)
#   * Children: `:content` node
#
# - `:metadata` - Metadata information
#   * Data: `source` (Symbol), `url` (String)
#
# - `:content` - Content text
#   * Data: `text` (String)
#
# - `:links` - List of related links
#   * Data: `links` (Array<String>)
#
# ### Example Usage
#
# ```ruby
# # Search result node structure
# root = Value::Node::Root.new(
#   type: :search,
#   data: { query: "ruby", total_results: 1 },
#   children: [
#     Value::Node.new(type: :header, data: { text: "Search Results for 'ruby'" }),
#     Value::Node.new(
#       type: :result,
#       data: { title: "Ruby Programming", url: "https://ruby-lang.org", source: :search },
#       children: [
#         Value::Node.new(type: :content, data: { text: "Ruby is a dynamic programming language..." })
#       ]
#     )
#   ]
# )
# ```
class Value::Node < AbstractStruct
  attribute :type, Types::Symbol
  attribute :data, Types::Hash
  attribute :children, Types::Array.of(Types.Instance(self)).default([].freeze)
end
