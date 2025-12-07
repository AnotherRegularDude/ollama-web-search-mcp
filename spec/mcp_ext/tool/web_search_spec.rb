# frozen_string_literal: true

describe MCPExt::Tool::WebSearch do
  include_context "ollama request context"

  def run!
    described_class.call(query: query, max_results: max_results)
  end

  let(:web_action) { "web_search" }
  let(:response_body) { data[:search_response] }

  let(:query) { "latest news" }
  let(:max_results) { 4 }

  let(:expected_output) do
    <<~TEXT.chomp
      Search results for: #{query}

      1. Title one
        URL: https://example.com/1
        Content: Content one
      2. Title two
        URL: https://example.com/2
        Content: Content two
    TEXT
  end

  it "returns formatted MCP response with rendered results" do
    response = run!
    expect(response).to be_a(MCP::Tool::Response)
    expect(response.content.first).to eq(type: "text", text: expected_output)

    expect(requests.size).to eq(1)
    expect(requests.first.body).to eq({ query: query, max_results: max_results }.to_json)
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
end
