# frozen_string_literal: true

describe MCPExt::Tool::WebSearch do
  include_context "ollama request context"

  def run!
    described_class.call(query:, max_results:)
  end

  let(:web_action) { "web_search" }
  let(:response_body) { data[:search_response] }

  let(:query) { "latest news" }
  let(:max_results) { 4 }

  let(:expected_output) do
    <<~TEXT.chomp
      Search Results — "#{query}"
      ### [Example Search Result 1](https://example.com/result1)
      **URL:** https://example.com/result1
      **Source:** search
      **Content:**
      ---
      This is the content of the first search result.
      ---
      ### [Example Search Result 2](https://example.com/result2)
      **URL:** https://example.com/result2
      **Source:** search
      **Content:**
      ---
      This is the content of the second search result.
      ---
    TEXT
  end

  it "returns formatted MCP response with rendered results" do
    response = run!
    expect(response).to be_a(MCP::Tool::Response)
    expect(response.content.first).to eq(type: "text", text: expected_output)

    expect(requests.size).to eq(1)
    expect(requests.first.body).to be_json_as(query:, max_results:)
  end

  context "when nothing found" do
    let(:response_body) { '{ "results": [] }' }

    it "responses with no results message" do
      response = run!
      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: "No results found for query: latest news")
    end
  end

  context "when gateway fails" do
    let(:response_status) { 500 }
    let(:response_body) { "failure" }

    it "returns error message through MCP response" do
      response = run!

      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: "Error: HTTP 500 - failure")
      expect(requests.size).to eq(1)
    end
  end

  context "when max_results is too small" do
    let(:max_results) { 0 }
    it "returns a validation error message" do
      response = run!

      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: "Argument[0] is invalid: included_in?(1..10, 0)")
      expect(requests.size).to eq(0)
    end
  end

  context "when max_results is too big" do
    let(:max_results) { 11 }
    it "returns a validation error message" do
      response = run!

      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: "Argument[11] is invalid: included_in?(1..10, 11)")
      expect(requests.size).to eq(0)
    end
  end

  context "when connection times out" do
    before { stub_request(:post, "https://ollama.com/api/web_search").to_timeout }

    it "returns timeout error" do
      response = run!
      expect(response.content.first).to eq(type: "text", text: "HTTP Timeout: execution expired")
    end
  end

  context "when truncate and max_chars parameters are provided" do
    context "with truncate: true" do
      def run!
        described_class.call(query:, max_results:, truncate: true)
      end

      it "accepts truncate parameter without error" do
        response = run!
        expect(response).to be_a(MCP::Tool::Response)
        expect(requests.size).to eq(1)
      end
    end

    context "with truncate: false" do
      def run!
        described_class.call(query:, max_results:, truncate: false)
      end

      it "accepts truncate parameter without error" do
        response = run!
        expect(response).to be_a(MCP::Tool::Response)
        expect(requests.size).to eq(1)
      end
    end

    context "with max_chars parameter" do
      let(:long_content) { "A" * 150_000 }
      let(:response_body) do
        {
          results: [
            {
              title: "Example Search Result 1",
              url: "https://example.com/result1",
              content: long_content,
              related_content: [],
            },
            {
              title: "Example Search Result 2",
              url: "https://example.com/result2",
              content: long_content,
              related_content: [],
            },
          ],
        }.to_json
      end

      context "with max_chars: 5000" do
        def run!
          described_class.call(query:, max_results:, max_chars: 5000)
        end

        it "accepts max_chars parameter without error" do
          response = run!
          expect(response).to be_a(MCP::Tool::Response)
          expect(requests.size).to eq(1)
        end

        it "truncates content to max_chars limit" do
          response = run!
          content = response.content.first[:text]
          expect(content).to be_a(String)
          # Content should be truncated to around 5000 characters
          expect(content.length).to be <= 5200 # Allowing some buffer for formatting
        end
      end

      context "with both truncate: true and max_chars: 1000" do
        def run!
          described_class.call(query:, max_results:, truncate: true, max_chars: 1000)
        end

        it "accepts both parameters without error" do
          response = run!
          expect(response).to be_a(MCP::Tool::Response)
          expect(requests.size).to eq(1)
        end

        it "truncates content when both parameters are provided" do
          response = run!
          content = response.content.first[:text]
          expect(content).to be_a(String)
          # Content should be truncated to around 1000 characters
          expect(content.length).to be <= 1200 # Allowing some buffer for formatting
        end
      end

      context "with truncate: false and long content" do
        def run!
          described_class.call(query:, max_results:, truncate: false)
        end

        it "preserves full content length when truncate is false" do
          response = run!
          content = response.content.first[:text]
          expect(response).to be_a(MCP::Tool::Response)
          expect(content).to be_a(String)
          # Content should preserve full length when truncate is false
          expect(content).to include(long_content[0..100])
          expect(content).to include(long_content[-100..])
        end
      end

      context "when truncate is not specified" do
        def run!
          described_class.call(query:, max_results:)
        end

        it "uses default truncate: true when not specified" do
          response = run!
          content = response.content.first[:text]
          expect(response).to be_a(MCP::Tool::Response)
          expect(content).to be_a(String)
          # Should use default truncation behavior
          expect(content.length).to be <= 120_200 # Default max chars + formatting buffer
        end
      end
    end
  end
end
