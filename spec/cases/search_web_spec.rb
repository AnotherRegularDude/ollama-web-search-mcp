# frozen_string_literal: true

describe Cases::SearchWeb do
  def run!
    described_class.call!(query, **{ max_results: max_results }.compact)
  end

  def stub_web_search(body)
    stub_request(:post, "https://ollama.com/api/web_search").to_return do |request|
      requests << request
      {
        status: 200,
        body: body.to_json,
        headers: { "Content-Type" => "application/json" },
      }
    end
  end

  before { stub_const("Application::ENV", stub_env) }
  before { stub_web_search(response_body) }
  after { Application.instance_variable_set(:@fetch_api_key, nil) }

  let(:requests) { [] }
  let(:stub_env) { Hash["OLLAMA_API_KEY" => api_key] }
  let(:api_key) { "test" }

  let(:response_body) do
    {
      results: [
        {
          title: "Title one",
          url: "https://example.com/1",
          content: "Content one",
        },
      ],
    }
  end

  let(:query) { "mars mission" }
  let(:max_results) { 2 }

  it "returns typed results and forwards params to gateway" do
    results = run!

    expect(results.size).to eq(1)
    first = results.first
    expect(first).to be_a(Entities::Result)
    expect(first.title).to eq("Title one")
    expect(first.url).to eq("https://example.com/1")
    expect(first.content).to eq("Content one")

    expect(requests.size).to eq(1)
    expect(requests.first.body).to eq({ query: query, max_results: max_results }.to_json)
  end

  context "without max_results" do
    let(:query) { "default count" }
    let(:max_results) { nil }

    it "falls back to default max results" do
      run!

      expect(requests.size).to eq(1)
      expect(requests.first.body).to eq({ query: query, max_results: 5 }.to_json)
    end
  end

  context "when gateway responds with error" do
    before do
      stub_request(:post, "https://ollama.com/api/web_search").to_return do |request|
        requests << request
        { status: 500, body: "Failure" }
      end
    end

    it "propagates HTTPError" do
      expect { run! }.to raise_error(Adapters::OllamaGateway::HTTPError)

      expect(requests.size).to eq(1)
    end
  end
end
