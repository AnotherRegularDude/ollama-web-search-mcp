# frozen_string_literal: true

describe MCPExt::Tool::WebFetch do
  include_context "ollama request context"

  def run!(**data)
    described_class.call(**data)
  end

  let(:web_action) { "web_fetch" }
  let(:response_body) { data[:fetch_response] }

  let(:url) { "https://example.com" }

  let(:expected_output) do
    <<~TEXT.chomp
      # Example Page
      ## Content
      This is the content of the page.
      ## Links
      URL: https://example.com
      On Page:
      - https://example.com
      - https://example.com/about
    TEXT
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
    let(:response_body) { Hash[title: "Example Page", content: "This is the content of the page.", links: []].to_json }

    let(:expected_output_without_links) do
      <<~TEXT.chomp
        # Example Page
        ## Content
        This is the content of the page.
        ## Links
        URL: https://example.com
      TEXT
    end

    it "returns formatted output without links" do
      response = run!(url:)
      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: expected_output_without_links)
    end
  end

  context "when returned links differ from requested url" do
    let(:response_body) { Hash[title: "Example Page", content: "Content", links: ["https://other.com/page"]].to_json }

    let(:expected_output) do
      <<~TEXT.chomp
        # Example Page
        ## Content
        Content
        ## Links
        URL: https://example.com
        On Page:
        - https://other.com/page
      TEXT
    end

    it "still shows the requested url and lists extracted links" do
      response = run!(url:)

      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: expected_output)
    end
  end

  context "when a web page has no content" do
    let(:response_body) { Hash[title: "Example Page", content: "", links: []].to_json }

    let(:expected_output) do
      <<~TEXT.chomp
        # Example Page
        ## Links
        URL: https://example.com
      TEXT
    end

    it "returns formatted output without content" do
      response = run!(url:)

      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: expected_output)
    end
  end
end
