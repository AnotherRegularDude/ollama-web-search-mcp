# frozen_string_literal: true

require "rack/mock"

describe MCPExt::TransportHandler do
  def run!
    described_class.call!(transport)
  end

  context "when transport type is stdio" do
    let(:server) { MCP::Server.new(name: "stdio-test", tools: []) }
    let(:transport) { Entities::Transport.new(type: :stdio, data: {}).with_server(server) }
    let(:stdio_transport) { instance_double(MCP::Server::Transports::StdioTransport, open: nil) }

    before do
      allow(MCPExt::TransportHandler::Stdio).to receive(:build_stdio_transport).with(server).and_return(stdio_transport)
    end

    it "delegates to stdio handler and returns callable that opens the stdio transport" do
      result = run!

      expect(result).to be_a(Proc)
      result.call

      expect(stdio_transport).to have_received(:open)
    end

    context "when testing build_stdio_transport method directly" do
      before { allow(MCPExt::TransportHandler::Stdio).to receive(:build_stdio_transport).and_call_original }

      it "creates a new StdioTransport instance with the given server" do
        transport_instance = MCPExt::TransportHandler::Stdio.build_stdio_transport(server)

        expect(transport_instance).to be_a(MCP::Server::Transports::StdioTransport)
      end
    end
  end

  context "when transport type is http" do
    before do
      allow(server).to receive(:handle_json).and_return(server_response)
      allow(MCPExt::TransportHandler::Http).to receive(:puma_launcher_from) do |config|
        launched_configs << config
        launcher
      end
    end

    let(:server_response) { "serialized response" }
    let(:server) { MCP::Server.new(name: "http-test", tools: []) }
    let(:transport) { Entities::Transport.new(type: :http, data: transport_data).with_server(server) }
    let(:transport_data) { { port: port } }
    let(:port) { 9292 }

    let(:launcher) { instance_double(Puma::Launcher, run: nil) }
    let(:launched_configs) { [] }
    let(:config) { launched_configs.first.clamp.user_options }

    it "builds HTTP config, forwards requests to the server, and returns a runnable launcher" do
      result = run!
      expect(result).to be_a(Proc)
      expect(launched_configs.size).to eq(1)
      expect(config).to include(min_threads: 1, max_threads: 5, binds: ["tcp://0.0.0.0:9292"])
      result.call
      expect(launcher).to have_received(:run)

      env = Rack::MockRequest.env_for("/mcp", method: "POST", input: "payload")
      rack_response = config[:app].call(env)

      expect(rack_response).to eq([200, { "Content-Type" => "application/json" }, ["serialized response"]])
      expect(server).to have_received(:handle_json).with("payload")
    end

    context "without an explicit port" do
      let(:transport_data) { {} }

      it "uses the default HTTP server port" do
        run!
        expect(config).to include(min_threads: 1, max_threads: 5, binds: ["tcp://0.0.0.0:8080"])
      end
    end
  end
end
