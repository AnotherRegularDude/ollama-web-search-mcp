# frozen_string_literal: true

describe Cases::WebFetch do
  include_context "ollama request context"

  def run
    described_class.call(url_to_fetch)
  end

  def run!
    run.value!
  end

  let(:web_action) { "web_fetch" }
  let(:response_body) { data[:fetch_response] }

  let(:url_to_fetch) { "https://example.com" }

  it "returns typed result and forwards params to gateway" do
    result = run!

    expect(result).to be_a(Entities::WebFetchResult)
    expect(result.title).to eq("Example Page")
    expect(result.content).to eq("This is the content of the page.")
    expect(result.links).to eq(["https://example.com", "https://example.com/about"])

    expect(requests.size).to eq(1)
    expect(requests.first.body).to eq({ url: "https://example.com" }.to_json)
  end

  context "when gateway responds with error" do
    before do
      stub_request(:post, "https://ollama.com/api/web_fetch").to_return do |request|
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
