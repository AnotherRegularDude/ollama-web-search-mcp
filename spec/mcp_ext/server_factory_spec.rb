# frozen_string_literal: true

describe MCPExt::ServerFactory do
  before do
    stub_const("MCPExt::ServerFactory::SUPPORTED_MCP_PROTOCOL_VERSIONS", %w[2025-06-18 2025-03-26 2024-11-05"])
  end

  subject(:factory) { described_class.with_defaults }

  it "creates a factory with default tools" do
    expect(factory.instance_variable_get(:@attributes).tools).to eq([MCPExt::Tool::WebSearch, MCPExt::Tool::WebFetch])
  end

  describe "#build" do
    subject(:factory) { described_class.with_defaults.with_transport(transport) }
    let(:transport) { Entities::Transport.new(type: :stdio, data: {}) }

    it "uses the default protocol version" do
      expect { factory.build }.not_to raise_error
    end

    context "with configured MCP protocol version" do
      let(:transport) { Entities::Transport.new(type: :stdio, data: { mcp_version: "2025-03-26" }) }

      it "uses the configured protocol version" do
        expect { factory.build }.not_to raise_error
      end
    end

    context "with unsupported MCP protocol version" do
      let(:transport) { Entities::Transport.new(type: :stdio, data: { mcp_version: "2024-01-01" }) }

      it "raises an error when building server" do
        expect { factory.build }.to raise_error(
          StandardError,
          /Unsupported MCP protocol version.*2024-01-01.*2025-06-18, 2025-03-26, 2024-11-05/,
        )
      end
    end
  end
end
