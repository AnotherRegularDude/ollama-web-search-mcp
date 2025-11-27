# frozen_string_literal: true

describe MCPExt::Tool::WebSearch do
  def run!
    described_class.call(query: query, max_results: max_results)
  end

  def stub_web_search
    stub_request(:post, "https://ollama.com/api/web_search").to_return do |request|
      requests << request
      {
        status: response_status,
        body: serialized_body,
        headers: { "Content-Type" => "application/json" },
      }
    end
  end

  before { stub_const("Application::ENV", stub_env) }
  before { stub_web_search }
  after { Application.instance_variable_set(:@fetch_api_key, nil) }

  let(:requests) { [] }
  let(:stub_env) { Hash["OLLAMA_API_KEY" => api_key] }
  let(:api_key) { "interface key" }

  let(:query) { "latest news" }
  let(:max_results) { 4 }

  let(:response_status) { 200 }
  let(:response_body) do
    {
      results: [
        {
          title: "Headline one",
          url: "https://example.com/news",
          content: "Story content",
        },
        {
          title: "Headline two",
          url: "https://example.com/news2",
          content: "Story two content",
        },
      ],
    }
  end
  let(:serialized_body) do
    response_body.is_a?(String) ? response_body : response_body.to_json
  end

  let(:expected_output) do
    <<~TEXT
      Search results for: #{query}

      1. Headline one
        URL: https://example.com/news
        Content: Story content
      2. Headline two
        URL: https://example.com/news2
        Content: Story two content
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
    let(:response_body) { Hash[results: []] }

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
      expect(response.content.first).to eq(type: "text", text: "Argument[0] is invalid: included_in?(1...10, 0)")
      expect(requests.size).to eq(0)
    end
  end

  context "when max_results is too big" do
    let(:max_results) { 11 }

    it "returns a validation error message" do
      response = run!

      expect(response).to be_a(MCP::Tool::Response)
      expect(response.content.first).to eq(type: "text", text: "Argument[11] is invalid: included_in?(1...10, 11)")
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
