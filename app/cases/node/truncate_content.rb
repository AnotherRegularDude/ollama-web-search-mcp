# frozen_string_literal: true

class Cases::Node::TruncateContent < ServiceObject
  param :root_node, Types.Instance(Value::RootNode)
  option :remaining_length, Types::Integer, default: proc { 0 }

  def call
    return success! if remaining_length.zero?
    fail!(:small_token_limit, "Token limit smaller than empty layout size") if remaining_length.negative?

    self.content_texts = find_all_content_texts(root_node)

    truncate_texts!
    success!
  end

  private

  attr_accessor :content_texts

  def find_all_content_texts(node)
    node.children.flat_map do |child_node|
      find_all_content_texts(child_node) + [child_node.type == :content ? child_node.data.fetch(:text) : nil].compact
    end
  end

  def truncate_texts!
    return if content_texts.empty?

    current_max_size = remaining_length / content_texts.size

    content_texts.each_with_index do |text, i|
      current_max_size = process_text_at_index(text, i, current_max_size)
    end
  end

  def process_text_at_index(text, index, current_max_size)
    extra_size = current_max_size - text.size
    if extra_size.positive?
      current_max_size + redistribute_budget(index, extra_size, current_max_size)
    else
      text[current_max_size..-1] = ""
      current_max_size
    end
  end

  def redistribute_budget(current_index, extra_size, _current_max_size)
    remaining_items = content_texts.size - current_index - 1
    return 0 if remaining_items.zero?

    extra_size / remaining_items
  end
end
