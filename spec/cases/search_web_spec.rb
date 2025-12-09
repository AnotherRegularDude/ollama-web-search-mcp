# frozen_string_literal: true

describe Cases::SearchWeb do
  include_context "ollama request context"

  def run
    described_class.call(query, **{ max_results: max_results }.compact)
  end

  def run!
    run.value!
  end

  let(:web_action) { "web_search" }
  let(:response_body) { data[:search_response] }

  let(:query) { "mars mission" }
  let(:max_results) { 2 }

  it "returns typed results and forwards params to gateway" do
    results = run!

    expect(results.size).to eq(2)
    first = results.first
    expect(first).to be_a(Entities::RemoteContent)
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
      result = run

      expect(requests.size).to eq(1)

      expect(result.failure?).to eq(true)
      expect(result.error.code).to eq(:request_failed)
      expect(result.error.data[:message]).to eq("Error: HTTP 500 - Failure")
    end
  end
end
