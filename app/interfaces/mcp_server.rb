# frozen_string_literal: true

module Interfaces::MCPServer
  extend self

  SERVER_NAME = "ollama-web-search"

  def stdio
    transport = MCP::Server::Transports::StdioTransport.new(build_server)
    transport.open
  end

  def http(port:)
    http_transport_class = MCP::Server::Transports.const_get(:HttpTransport)
    transport = http_transport_class.new(build_server, port: port)
    transport.start
  end

  private

  def build_server
    MCP::Server.new(
      name: SERVER_NAME,
      tools: [Interfaces::WebSearchTool],
    )
  end
end
