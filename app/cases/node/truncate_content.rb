# frozen_string_literal: true

# Service object for truncating content text within node structures.
#
# This service processes {Value::RootNode} structures and truncates content
# text to fit within specified character limits. It intelligently distributes
# the available character budget across multiple content sections.
#
# @example Truncating content in a root node
#   root_node = Value::RootNode.new(
#     metadata: { query: "test" },
#     children: [
#       Value::Node.new(type: :content, data: { text: "Very long content text..." })
#     ]
#   )
#
#   result = Cases::Node::TruncateContent.call(root_node, remaining_length: 50)
#   if result.success?
#     # Content text is now truncated to fit within 50 characters
#     puts "Truncation completed"
#   end
#
# @example Handling multiple content sections
#   # With two content sections and 100 character budget:
#   # Each section gets 50 characters, redistributing any unused space
#   result = Cases::Node::TruncateContent.call(root_node, remaining_length: 100)
class Cases::Node::TruncateContent < ServiceObject
  # @!attribute [r] root_node
  #   @return [Value::RootNode] the root node containing content to truncate
  param :root_node, Types.Instance(Value::RootNode)

  # @!attribute [r] remaining_length
  #   @return [Integer] the remaining character budget for content (default: 0)
  option :remaining_length, Types::Integer, default: proc { 0 }

  # Truncates content text within the root node structure
  #
  # Processes all content nodes and truncates their text to fit within
  # the specified character budget. The budget is distributed evenly
  # across all content sections, with redistribution of unused space.
  #
  # @return [Resol::Service::Value] a service result indicating success
  # @raise [ArgumentError] if the parameters are invalid
  # @raise [self::Failure] if using `call!` and the service fails
  #
  # @example Basic usage
  #   result = Cases::Node::TruncateContent.call(root_node, remaining_length: 100)
  #   if result.success?
  #     puts "Content truncated successfully"
  #   end
  #
  # @example Handling zero or negative remaining length
  #   # Zero length: returns success immediately
  #   Cases::Node::TruncateContent.call(root_node, remaining_length: 0)
  #
  #   # Negative length: raises failure
  #   Cases::Node::TruncateContent.call(root_node, remaining_length: -10)
  def call
    return success! if remaining_length.zero?
    fail!(:small_token_limit, "Token limit smaller than empty layout size") if remaining_length.negative?

    self.content_texts = find_all_content_texts(root_node)

    truncate_texts!
    success!
  end

  private

  # @!attribute [rw] content_texts
  #   @return [Array<String>] array of all content text strings to truncate
  attr_accessor :content_texts

  # Finds all content text strings within the node structure
  #
  # Recursively searches through the node hierarchy to extract
  # all text content from content-type nodes.
  #
  # @param node [Value::Node] the node to search within
  # @return [Array<String>] array of content text strings
  #
  # @example Finding content texts
  #   find_all_content_texts(root_node) # => ["text1", "text2", "text3"]
  def find_all_content_texts(node)
    node.children.flat_map do |child_node|
      find_all_content_texts(child_node) + [child_node.type == :content ? child_node.data.fetch(:text) : nil].compact
    end
  end

  # Truncates all content texts to fit within the character budget
  #
  # Distributes the available character budget evenly across all
  # content sections and applies truncation as needed.
  #
  # @return [void]
  #
  # @example Truncation process
  #   # With 3 content texts and 300 character budget:
  #   # Each text gets 100 characters initially
  #   truncate_texts!
  def truncate_texts!
    return if content_texts.empty?

    current_max_size = remaining_length / content_texts.size

    content_texts.each_with_index do |text, i|
      current_max_size = process_text_at_index(text, i, current_max_size)
    end
  end

  # Processes truncation for a specific text at a given index
  #
  # @param text [String] the text to process
  # @param index [Integer] the index of the text in the content_texts array
  # @param current_max_size [Integer] the current maximum size for this text
  # @return [Integer] the updated maximum size after processing
  #
  # @example Processing text truncation
  #   # If text is shorter than max_size, redistribute extra space
  #   # If text is longer, truncate it
  #   process_text_at_index(text, 0, 100)
  def process_text_at_index(text, index, current_max_size)
    extra_size = current_max_size - text.size
    if extra_size.positive?
      current_max_size + redistribute_budget(index, extra_size, current_max_size)
    else
      text[current_max_size..-1] = ""
      current_max_size
    end
  end

  # Redistributes unused character budget to remaining content sections
  #
  # @param current_index [Integer] the current index being processed
  # @param extra_size [Integer] the extra character space available
  # @param _current_max_size [Integer] the current maximum size (unused)
  # @return [Integer] the amount of extra space to add to remaining sections
  #
  # @example Budget redistribution
  #   # With 3 items and extra_size=60 at index 0:
  #   # Distribute 60/2 = 30 to each remaining item
  #   redistribute_budget(0, 60, 100) # => 30
  def redistribute_budget(current_index, extra_size, _current_max_size)
    remaining_items = content_texts.size - current_index - 1
    return 0 if remaining_items.zero?

    extra_size / remaining_items
  end
end
