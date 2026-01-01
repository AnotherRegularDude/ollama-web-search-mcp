# frozen_string_literal: true

describe MCPExt::Tool::WebFetch do
  include_context "ollama request context"

  def run!
    described_class.call(url:, **additional_options)
  end

  let(:web_action) { "web_fetch" }
  let(:url) { "https://example.com" }
  let(:response_body) { data[:fetch_response] }

  let(:additional_options) { Hash[truncate:, max_chars:].compact }
  let(:truncate) { nil }
  let(:max_chars) { nil }

  let(:expected_output) do
    <<~TEXT.chomp
      **Source:** fetch
      **URL:** https://example.com
      **Content:**
      ---
      This is the main content of the fetched web page.
      ---
      **Links:**
      - [https://example.com](https://example.com)
      - [https://example.com/about](https://example.com/about)
    TEXT
  end

  it "returns formatted MCP response with rendered results" do
    response = run!

    expect(response).to be_a(MCP::Tool::Response)
    expect(response.content.first).to eq(type: "text", text: expected_output)
    expect(requests.size).to eq(1)
    expect(requests.first.body).to be_json_as(url:)
  end

  context "when a web page has no content" do
    let(:response_body) do
      {
        title: "Example Web Page",
        url:,
        content: "",
        links: [],
      }.to_json
    end

    let(:expected_output) do
      <<~TEXT.chomp
        **Source:** fetch
        **URL:** https://example.com
        No content found for URL: https://example.com
      TEXT
    end

    it "returns formatted output without content block" do
      response = run!
      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: expected_output)
    end
  end

  context "when returned links differ from requested url" do
    let(:response_body) do
      {
        title: "Example Web Page",
        url:,
        content: "Content",
        links: ["https://other.com/page"],
      }.to_json
    end

    let(:expected_output) do
      <<~TEXT.chomp
        **Source:** fetch
        **URL:** https://example.com
        **Content:**
        ---
        Content
        ---
        **Links:**
        - [https://other.com/page](https://other.com/page)
      TEXT
    end

    it "still shows the requested url and lists extracted links" do
      response = run!
      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: expected_output)
    end
  end

  context "when links are empty" do
    let(:response_body) do
      {
        title: "Example Web Page",
        url:,
        content: "This is the main content of the fetched web page.",
        links: [],
      }.to_json
    end

    let(:expected_output) do
      <<~TEXT.chomp
        **Source:** fetch
        **URL:** https://example.com
        **Content:**
        ---
        This is the main content of the fetched web page.
        ---
      TEXT
    end

    it "returns formatted output without links section" do
      response = run!
      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: expected_output)
    end
  end

  context "when gateway fails" do
    let(:response_status) { 500 }
    let(:response_body) { "failure" }

    it "returns error message through MCP response" do
      response = run!
      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text",
                                           text: ":request_failed => {message: \"Error: HTTP 500 - failure\"}",)
      expect(requests.size).to eq(1)
    end
  end

  context "when connection times out" do
    before { stub_request(:post, "https://ollama.com/api/web_fetch").to_timeout }

    it "returns timeout error" do
      response = run!
      expect(response.content.first).to eq(type: "text",
                                           text: ":request_failed => {message: \"HTTP Timeout: execution expired\"}",)
    end
  end

  context "when url parameter is missing" do
    let(:url) { nil }

    it "returns a validation error message" do
      response = run!
      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: "Argument[nil] is invalid: type?(String, nil)")
      expect(requests.size).to eq(0)
    end
  end

  context "when truncate and max_chars parameters are provided" do
    context "with truncate: true" do
      let(:truncate) { true }

      it "passes truncate parameter to formatter" do
        response = run!
        expect(response).to be_a(MCP::Tool::Response)
        expect(response.content.first).to eq(type: "text", text: expected_output)
        expect(requests.size).to eq(1)
      end
    end

    context "with truncate: false" do
      let(:truncate) { false }

      it "passes truncate parameter to formatter" do
        response = run!
        expect(response).to be_a(MCP::Tool::Response)
        expect(response.content.first).to eq(type: "text", text: expected_output)
        expect(requests.size).to eq(1)
      end
    end

    context "with max_chars parameter" do
      let(:long_content) { "A" * 150_000 }
      let(:response_body) do
        {
          title: "Example Web Page",
          url:,
          content: long_content,
          links: [],
        }.to_json
      end

      context "with max_chars: 100" do
        let(:max_chars) { 100 }

        it "passes max_chars parameter to formatter and truncates content" do
          response = run!
          expect(response).to be_a(MCP::Tool::Response)
          expect(requests.size).to eq(1)
          content_text = response.content.first[:text]
          expect(content_text.size).to eq(100)
        end
      end

      context "with max_chars: 5000" do
        let(:max_chars) { 5000 }

        it "passes max_chars parameter to formatter and truncates content" do
          response = run!
          expect(response).to be_a(MCP::Tool::Response)
          expect(requests.size).to eq(1)
          content_text = response.content.first[:text]
          expect(content_text.size).to eq(5_000)
        end
      end

      context "with both truncate: true and max_chars: 1000" do
        let(:truncate) { true }
        let(:max_chars) { 1000 }

        it "passes both parameters to formatter and truncates content" do
          response = run!
          expect(response).to be_a(MCP::Tool::Response)
          expect(requests.size).to eq(1)
          content_text = response.content.first[:text]
          expect(content_text.size).to eq(1_000)
        end
      end
    end
  end
end
