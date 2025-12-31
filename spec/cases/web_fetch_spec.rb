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

    expect(result).to be_a(Entities::RemoteContent)
    expect(result.title).to eq("Example Web Page")
    expect(result.url).to eq("https://example.com")
    expect(result.content).to eq("This is the main content of the fetched web page.")
    expect(result.related_content.map(&:link)).to eq(["https://example.com", "https://example.com/about"])

    expect(requests.size).to eq(1)
    expect(requests.first.body).to be_json_as(url: "https://example.com")
  end

  context "when gateway responds with error" do
    let(:response_status) { 500 }
    let(:response_body) { "Failure" }

    it "propagates HTTPError" do
      result = run

      expect(requests.size).to eq(1)

      expect(result.failure?).to eq(true)
      expect(result.error.code).to eq(:request_failed)
      expect(result.error.data[:message]).to eq("Error: HTTP 500 - Failure")
    end
  end
end
