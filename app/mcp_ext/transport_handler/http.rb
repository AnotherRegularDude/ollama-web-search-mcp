# frozen_string_literal: true

# Handler for HTTP transport configuration.
#
# This class configures and starts an MCP server using HTTP transport,
# which exposes the MCP functionality through a web API endpoint.
#
class MCPExt::TransportHandler::Http < MCPExt::TransportHandler
  # :nocov:
  # Creates a Puma launcher from the configuration
  #
  # @param config [Puma::Configuration] the Puma configuration
  # @return [Puma::Launcher] the Puma launcher
  # @api private
  def self.puma_launcher_from(config)
    Puma::Launcher.new(config, log_writer: Puma::LogWriter.stdio)
  end
  # :nocov:

  # Configures and starts the HTTP transport
  #
  # @return [Resol::Service::Value] a service result containing a proc to start the transport
  def call
    server_config = build_puma_config
    launcher = self.class.puma_launcher_from(server_config)

    success!(proc { launcher.run })
  end

  private

  # Builds the Puma configuration for the HTTP server
  #
  # @return [Puma::Configuration] the Puma configuration
  # @api private
  def build_puma_config
    port = transport.data[:port] || 8080

    Puma::Configuration.new do |config|
      config.threads 1, 5
      config.app do |env|
        [200, { "Content-Type" => "application/json" }, [handle_request(env)]]
      end
      config.port(port)
    end
  end

  # Handles incoming HTTP requests
  #
  # @param env [Hash] the Rack environment
  # @return [String] the response body
  # @api private
  def handle_request(env)
    request = Rack::Request.new(env)
    server.handle_json(request.body.read)
  end
end
