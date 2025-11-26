# frozen_string_literal: true

describe Interfaces::WebSearchTool do
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

  def serialized_body
    response_body.is_a?(String) ? response_body : response_body.to_json
  end

  def expected_output
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
      "results" => [
        {
          "title" => "Headline one",
          "url" => "https://example.com/news",
          "content" => "Story content",
        },
        {
          "title" => "Headline two",
          "url" => "https://example.com/news2",
          "content" => "Story two content",
        },
      ],
    }
  end

  it "returns formatted MCP response with rendered results" do
    response = run!
    expect(response).to be_a(MCP::Tool::Response)

    expect(requests.size).to eq(1)
    expect(requests.first.body).to eq({ query: query, max_results: max_results }.to_json)
  end

  context "when gateway fails" do
    let(:response_status) { 500 }
    let(:response_body) { "failure" }

    it "returns error message through MCP response" do
      response = run!
      expect(response).to be_a(MCP::Tool::Response)
      expect(requests.size).to eq(1)
    end
  end
end
