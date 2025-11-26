# frozen_string_literal: true

describe Adapters::OllamaGateway do
  def run!
    described_class.process_web_search!(query: query, max_results: max_results)
  end

  def stub_web_search
    stub_request(:post, "https://ollama.com/api/web_search").to_return do |request|
      requests << request
      {
        status: response_status,
        body: response_body.is_a?(String) ? response_body : response_body.to_json,
        headers: { "Content-Type" => "application/json" },
      }
    end
  end

  before { stub_const("Application::ENV", stub_env) }
  before { stub_web_search }
  after { Application.instance_variable_set(:@fetch_api_key, nil) }

  let(:requests) { [] }
  let(:stub_env) { Hash["OLLAMA_API_KEY" => api_key] }
  let(:api_key) { "test key" }

  let(:query) { "web search query" }
  let(:max_results) { 3 }

  let(:response_status) { 200 }
  let(:response_body) do
    {
      results: [
        {
          title: "Result title",
          url: "https://example.com",
          content: "Result content",
        },
      ],
    }
  end

  it "sends HTTP request with payload and headers" do
    results = run!

    expect(requests.size).to eq(1)
    expect(results.size).to eq(1)
    expect(results.first).to eq(
      { "title" => "Result title", "url" => "https://example.com", "content" => "Result content" },
    )

    request = requests.first
    expect(request.body).to eq({ query: query, max_results: max_results }.to_json)
    expect(request.headers["Authorization"]).to eq("Bearer #{api_key}")
    expect(request.headers["Content-Type"]).to eq("application/json")
  end

  context "when response status is not 200" do
    let(:response_status) { 500 }
    let(:response_body) { "Internal Server Error" }

    it "raises HTTPError" do
      expect { run! }.to raise_error(Adapters::OllamaGateway::HTTPError, "Error: HTTP 500 - Internal Server Error")

      expect(requests.size).to eq(1)
    end
  end
end
