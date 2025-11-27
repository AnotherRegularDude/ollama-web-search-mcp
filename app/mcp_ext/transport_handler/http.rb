# frozen_string_literal: true

class MCPExt::TransportHandler::Http < MCPExt::TransportHandler
  # :nocov:
  def self.puma_launcher_from(config)
    Puma::Launcher.new(config, log_writer: Puma::LogWriter.stdio)
  end
  # :nocov:

  def call
    server_config = build_puma_config
    launcher = self.class.puma_launcher_from(server_config)

    success!(proc { launcher.run })
  end

  private

  def build_puma_config
    Puma::Configuration.new do |config|
      config.threads 1, 5
      config.app do |env|
        [200, { "Content-Type" => "application/json" }, [handle_request(env)]]
      end
      config.port(transport.data[:port])
    end
  end

  def handle_request(env)
    request = Rack::Request.new(env)
    transport.server.handle_json(request.body.read)
  end
end
