# frozen_string_literal: true

class MCPExt::ServerFactory
  MutableAttributes = Struct.new(:tools, :transport, keyword_init: true)
  DEFAULT_NAME = "ollama-web-search"

  def self.with_defaults
    new(DEFAULT_NAME).with_tools([MCPExt::Tool::WebSearch])
  end

  def initialize(name)
    @name = name
    @attributes = MutableAttributes.new(tools: [], transport: nil)
  end

  MutableAttributes.members.each do |member_name|
    define_method(:"with_#{member_name}") do |value|
      @attributes[member_name] = value
      self
    end
  end

  def build
    server = MCP::Server.new(
      name: @name,
      tools: @attributes.tools,
    )

    MCPExt::TransportHandler.call!(@attributes.transport.with_server(server))
  end
end
