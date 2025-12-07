# frozen_string_literal: true

describe MCPExt::Tool::WebFetch do
  def run!(**data)
    described_class.call(**data)
  end

  def stub_web_fetch
    stub_request(:post, "https://ollama.com/api/web_fetch").to_return do |request|
      requests << request
      {
        status: response_status,
        body: serialized_body,
        headers: { "Content-Type" => "application/json" },
      }
    end
  end

  before { stub_const("Application::ENV", stub_env) }
  before { stub_web_fetch }
  after { Application.instance_variable_set(:@fetch_api_key, nil) }

  let(:requests) { [] }
  let(:stub_env) { Hash["OLLAMA_API_KEY" => api_key] }
  let(:api_key) { "interface key" }

  let(:url) { "https://example.com" }

  let(:response_status) { 200 }
  let(:response_body) do
    {
      title: "Example Page",
      content: "This is the content of the page.",
      links: ["https://example.com", "https://example.com/about"],
    }
  end
  let(:serialized_body) do
    response_body.is_a?(String) ? response_body : response_body.to_json
  end

  let(:expected_output) do
    text = <<~TEXT
      Web page content from: Example Page
      URL: https://example.com

      This is the content of the page.

      Links:
      - https://example.com
      - https://example.com/about
    TEXT
    text.chomp # Remove the trailing newline added by the heredoc
  end
  it "returns formatted MCP response with rendered results" do
    response = run!(url:)
    expect(response).to be_a(MCP::Tool::Response)
    expect(response.content.first).to eq(type: "text", text: expected_output)

    expect(requests.size).to eq(1)
    expect(requests.first.body).to eq({ url: url }.to_json)
  end

  context "when gateway fails" do
    let(:response_status) { 500 }
    let(:response_body) { "failure" }

    it "returns error message through MCP response" do
      response = run!(url:)

      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: "Error: HTTP 500 - failure")
      expect(requests.size).to eq(1)
    end
  end

  context "when connection times out" do
    before { stub_request(:post, "https://ollama.com/api/web_fetch").to_timeout }

    it "returns timeout error" do
      response = run!(url:)
      expect(response.content.first).to eq(type: "text", text: "HTTP Timeout: execution expired")
    end
  end

  context "when some unhandled error occurs" do
    before do
      allow(Cases::WebFetch).to receive(:call).and_raise(ArgumentError, "Some unhandled error")
    end

    it "responses with error's message" do
      response = run!(url:)
      expect(response.content.first).to eq(type: "text", text: "Some unhandled error")
    end
  end

  context "when links are empty" do
    let(:response_body) do
      {
        title: "Example Page",
        content: "This is the content of the page.",
        links: [],
      }
    end

    let(:expected_output_without_links) do
      <<~TEXT.chomp
        Web page content from: Example Page
        URL: https://example.com

        This is the content of the page.
      TEXT
    end

    it "returns formatted output without links" do
      response = run!(url:)
      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: expected_output_without_links)
    end
  end

  context "when returned links differ from requested url" do
    let(:response_body) do
      {
        title: "Example Page",
        content: "Content",
        links: ["https://other.com/page"],
      }
    end

    let(:expected_output) do
      <<~TEXT.chomp
        Web page content from: Example Page
        URL: https://example.com

        Content

        Links:
        - https://other.com/page
      TEXT
    end

    it "still shows the requested url and lists extracted links" do
      response = run!(url:)

      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: expected_output)
    end
  end
end
