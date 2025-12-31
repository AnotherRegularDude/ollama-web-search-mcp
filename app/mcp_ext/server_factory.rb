# frozen_string_literal: true

# Factory class for creating MCP servers with predefined configurations.
#
# This class provides a fluent interface for building MCP servers with
# specific tools and transport configurations. It uses ServerContext to
# manage shared dependencies and configuration.
#
class MCPExt::ServerFactory
  # Mutable attributes structure for server configuration
  MutableAttributes = Struct.new(:tools, :transport, keyword_init: true)

  # Default name for the MCP server
  DEFAULT_NAME = "ollama-web-search"

  # Creates a new factory instance with default configuration
  #
  # @return [MCPExt::ServerFactory] a new factory instance
  #
  # @example Create a factory with default settings
  #   factory = MCPExt::ServerFactory.with_defaults
  #   # => factory with WebSearch and WebFetch tools and empty transport
  def self.with_defaults
    new(DEFAULT_NAME).with_tools([MCPExt::Tool::WebSearch, MCPExt::Tool::WebFetch])
  end

  # Initializes a new server factory
  #
  # @param name [String] the server name
  #
  # @example Create a new factory
  #   factory = MCPExt::ServerFactory.new("my-server")
  def initialize(name)
    @name = name
    @attributes = MutableAttributes.new(tools: [], transport: nil)
  end

  # Defines methods for setting mutable attributes
  #
  # @!method with_tools(value)
  #   Sets the tools for the server
  #   @param [Array] value the tools to set
  #   @return [MCPExt::ServerFactory] self for chaining
  #
  # @!method with_transport(value)
  #   Sets the transport for the server
  #   @param [Entities::Transport] value the transport to set
  #   @return [MCPExt::ServerFactory] self for chaining
  MutableAttributes.members.each do |member_name|
    define_method(:"with_#{member_name}") do |value|
      @attributes[member_name] = value
      self
    end
  end

  # Builds and configures the MCP server
  #
  # @return [Proc] a proc to start the server
  # @raise [StandardError] if transport handler fails
  #
  # @example Build a server configuration
  #   factory = MCPExt::ServerFactory.with_defaults
  #   transport = Entities::Transport.new(type: :stdio, data: {})
  #   start_server = factory.with_transport(transport).build
  #   start_server.call # to start the server
  def build
    configuration = MCP::Configuration.new(
      protocol_version: validate_mcp_protocol_version!(@attributes.transport.data[:mcp_version]),
    )

    server = MCP::Server.new(
      name: @name,
      tools: @attributes.tools,
      configuration:,
    )

    # Create server context with server and transport
    context = MCPExt::ServerContext.new(
      server:,
      transport: @attributes.transport,
    )

    # Build transport with server context
    MCPExt::TransportHandler.call!(context)
  end

  private

  # Validates that the MCP protocol version is supported
  #
  # @param version [String] the protocol version to validate
  # @return [void]
  # @raise [StandardError] if the version is not supported
  #
  # @example Validate a protocol version
  #   Application.validate_mcp_protocol_version!("2025-06-18")
  #   # => nil (no error)
  def validate_mcp_protocol_version!(version)
    return version if MCP::Configuration::SUPPORTED_PROTOCOL_VERSIONS.include?(version)

    raise <<~MESSAGE.rstrip!.gsub!(/[[:space:]]+/, " ")
      Unsupported MCP protocol version: #{version}.
      Supported versions: #{MCP::Configuration::SUPPORTED_PROTOCOL_VERSIONS.join(", ")}.
    MESSAGE
  end
end
