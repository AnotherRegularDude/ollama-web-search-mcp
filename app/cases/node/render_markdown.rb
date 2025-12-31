# frozen_string_literal: true

# Service object for rendering node structures to Markdown format.
#
# This service processes {Value::RootNode} structures and converts them
# into human-readable Markdown output. It supports various node types
# including headers, results, metadata, links, and content sections.
#
# @example Rendering a simple root node
#   root_node = Value::RootNode.new(
#     metadata: { query: "test" },
#     children: [
#       Value::Node.new(type: :header, data: { text: "Hello World" })
#     ]
#   )
#
#   result = Cases::Node::RenderMarkdown.call(root_node)
#   if result.success?
#     puts result.value! # Outputs "Hello World"
#   end
#
# @example Rendering with additional options
#   result = Cases::Node::RenderMarkdown.call(
#     root_node,
#     additional_options: { theme: :compact }
#   )
class Cases::Node::RenderMarkdown < ServiceObject
  # @!attribute [r] root_node
  #   @return [Value::RootNode] the root node structure to render
  param :root_node, Types.Instance(Value::RootNode)

  # @!attribute [r] additional_options
  #   @return [Hash] additional rendering options
  option :additional_options, Types::Hash, default: Types::EMPTY_HASH_DEFAULT

  # Renders the root node structure to Markdown format
  #
  # Processes all child nodes of the root node and combines
  # their rendered output into a single Markdown string.
  #
  # @return [Resol::Service::Value] a service result containing the rendered Markdown
  # @raise [ArgumentError] if the parameters are invalid
  # @raise [self::Failure] if using `call!` and the service fails
  #
  # @example Basic usage
  #   result = Cases::Node::RenderMarkdown.call(root_node)
  #   if result.success?
  #     markdown = result.value!
  #     puts markdown
  #   end
  def call
    rendered = render_root_node(root_node)
    success!(rendered)
  end

  private

  # Renders the root node by processing all child nodes
  #
  # @param root_node [Value::RootNode] the root node to render
  # @return [String] the combined Markdown output from all child nodes
  #
  # @example Rendering a root node
  #   render_root_node(root_node) # => combined Markdown string
  def render_root_node(root_node)
    StringIO.open do |str|
      root_node.children.each do |child|
        result = render_node(child)
        str.puts(result)
      end
      str.string.rstrip!
    end
  end

  # Renders an individual node based on its type
  #
  # @param node [Value::Node] the node to render
  # @return [String] the rendered Markdown for the node
  # @raise [self::Failure] if the node type is unknown
  #
  # @example Rendering different node types
  #   render_node(header_node) # => header text
  #   render_node(result_node) # => formatted result block
  def render_node(node)
    method_name = "render_#{node.type}_node"
    fail!(:unknown_node_type, "Unknown node type: #{node.type}") unless self.class.private_method_defined?(method_name)

    send(method_name, node)
  end

  # Renders a header node to Markdown
  #
  # @param node [Value::Node] the header node to render
  # @return [String] the header text
  #
  # @example Header rendering
  #   render_header_node(node) # => "Header Text"
  def render_header_node(node)
    node.data[:text]
  end

  # Renders a result node to Markdown
  #
  # Creates a formatted result block with title, URL, source information,
  # and any child content.
  #
  # @param node [Value::Node] the result node to render
  # @return [String] the formatted result block in Markdown
  #
  # @example Result rendering
  #   render_result_node(node) # => formatted result with title link and metadata
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

  # Renders a metadata node to Markdown
  #
  # Creates a metadata block with source and URL information.
  #
  # @param node [Value::Node] the metadata node to render
  # @return [String] the formatted metadata block in Markdown
  #
  # @example Metadata rendering
  #   render_metadata_node(node) # => "**Source:** search\n**URL:** https://example.com"
  def render_metadata_node(node)
    <<~MARKDOWN.rstrip!
      **Source:** #{node.data.fetch(:source)}
      **URL:** #{node.data.fetch(:url)}
    MARKDOWN
  end

  # Renders a links node to Markdown
  #
  # Creates a links section with bulleted list of URLs.
  # Handles empty link lists gracefully.
  #
  # @param node [Value::Node] the links node to render
  # @return [String] the formatted links section in Markdown
  #
  # @example Links rendering with content
  #   render_links_node(node) # => "**Links:**\n- [Link1](url1)\n- [Link2](url2)"
  #
  # @example Links rendering when empty
  #   render_links_node(node) # => "**Links:**\n- None"
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

  # Renders a content node to Markdown
  #
  # Creates a content section with the resolved content text.
  # Uses {Cases::Node::ResolveContent} to process content formatting.
  #
  # @param node [Value::Node] the content node to render
  # @return [String] the formatted content section in Markdown
  #
  # @example Content rendering
  #   render_content_node(node) # => "**Content:**\n---\nContent text...\n---"
  def render_content_node(node)
    <<~MARKDOWN.rstrip!
      **Content:**
      ---
      #{Cases::Node::ResolveContent.call!(node, **additional_options)}
      ---
    MARKDOWN
  end
end
