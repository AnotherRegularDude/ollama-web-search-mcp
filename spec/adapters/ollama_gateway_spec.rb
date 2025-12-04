# frozen_string_literal: true

describe Adapters::OllamaGateway do
  include_context "ollama request context"

  def run!
    described_class.process_web_search!(query: query, max_results: max_results)
  end

  def run_fetch!
    described_class.process_web_fetch!(url: url)
  end

  let(:web_action) { "web_search" }
  let(:response_body) { data[:search_response] }

  let(:query) { "web search query" }
  let(:max_results) { 3 }
  let(:url) { "https://example.com" }

  describe ".process_web_search!" do
    it "sends HTTP request with payload and headers" do
      results = run!

      expect(requests.size).to eq(1)
      expect(results.size).to eq(1)
      expect(results.first).to eq(
        { "title" => "Title one", "url" => "https://example.com/1", "content" => "Content one" },
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

    context "when connection times out" do
      before { stub_request(:post, "https://ollama.com/api/web_search").to_timeout }

      it "returns timeout error" do
        expect { run! }.to raise_error(Adapters::OllamaGateway::HTTPError, "HTTP Timeout: execution expired")
      end
    end
  end

  describe ".process_web_fetch!" do
    let(:web_action) { "web_fetch" }
    let(:response_body) { data[:fetch_response] }

    it "sends HTTP request with payload and headers" do
      result = run_fetch!

      expect(requests.size).to eq(1)
      expect(result).to eq(
        {
          "title" => "Example Page",
          "content" => "This is the content of the page.",
          "links" => ["https://example.com", "https://example.com/about"],
        },
      )

      request = requests.first
      expect(request.body).to eq({ url: url }.to_json)
      expect(request.headers["Authorization"]).to eq("Bearer #{api_key}")
      expect(request.headers["Content-Type"]).to eq("application/json")
    end

    context "when response status is not 200" do
      let(:response_status) { 500 }
      let(:response_body) { "Internal Server Error" }

      it "raises HTTPError" do
        error_message = "Error: HTTP 500 - Internal Server Error"
        expect { run_fetch! }.to raise_error(Adapters::OllamaGateway::HTTPError, error_message)

        expect(requests.size).to eq(1)
      end
    end

    context "when connection times out" do
      before { stub_request(:post, "https://ollama.com/api/web_fetch").to_timeout }

      it "returns timeout error" do
        expect { run_fetch! }.to raise_error(Adapters::OllamaGateway::HTTPError, "HTTP Timeout: execution expired")
      end
    end
  end
end
