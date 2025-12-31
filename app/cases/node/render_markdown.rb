# frozen_string_literal: true

class Cases::Node::RenderMarkdown < ServiceObject
  param :root_node, Types.Instance(Value::RootNode)
  option :additional_options, Types::Hash, default: Types::EMPTY_HASH_DEFAULT

  def call
    rendered = render_root_node(root_node)
    success!(rendered)
  end

  private

  def render_root_node(root_node)
    StringIO.open do |str|
      root_node.children.each do |child|
        result = render_node(child)
        str.puts(result)
      end
      str.string.rstrip!
    end
  end

  def render_node(node)
    method_name = "render_#{node.type}_node"
    fail!(:unknown_node_type, "Unknown node type: #{node.type}") unless self.class.private_method_defined?(method_name)

    send(method_name, node)
  end

  def render_header_node(node)
    node.data[:text]
  end

  def render_result_node(node)
    StringIO.open do |str|
      str.puts("### [#{node.data[:title]}](#{node.data[:url]})")
      str.puts("**URL:** #{node.data[:url]}")
      str.puts("**Source:** #{node.data[:source]}")
      node.children.each do |child|
        result = render_node(child)
        str.puts(result)
      end

      str.string.rstrip!
    end
  end

  def render_metadata_node(node)
    <<~MARKDOWN.rstrip!
      **Source:** #{node.data.fetch(:source)}
      **URL:** #{node.data.fetch(:url)}
    MARKDOWN
  end

  def render_links_node(node)
    StringIO.open do |str|
      str.puts("**Links:**")
      if node.data[:links].nil? || node.data[:links].empty?
        str.puts("- None")
        next str.string.rstrip!
      end

      node.data[:links].each { |link| str.puts("- [#{link}](#{link})") }
      str.string.rstrip!
    end
  end

  def render_content_node(node)
    <<~MARKDOWN.rstrip!
      **Content:**
      ---
      #{Cases::Node::ResolveContent.call!(node, **additional_options)}
      ---
    MARKDOWN
  end
end
