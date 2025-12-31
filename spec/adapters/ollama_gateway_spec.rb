# frozen_string_literal: true

describe Adapters::OllamaGateway do
  include_context "ollama request context"

  subject(:gateway) { described_class }

  let(:api_key) { "test-api-key" }
  let(:query) { "test query" }
  let(:url) { "https://example.com" }

  let(:request) { requests.first }

  describe ".process_web_search!" do
    let(:web_action) { "web_search" }
    let(:response_body) { data[:search_response] }
    let(:max_results) { 2 }

    it "makes a POST request to the Ollama API with the correct parameters" do
      gateway.process_web_search!(query:, max_results:)

      expect(requests.size).to eq(1)

      expect(request.uri.to_s).to eq("https://ollama.com:443/api/web_search")
      expect(request.body).to be_json_as(query: "test query", max_results: 2)
      expect(request.headers["Authorization"]).to eq("Bearer test-api-key")
      expect(request.headers["Content-Type"]).to eq("application/json")
    end

    it "returns an array of raw search results on success" do
      results = gateway.process_web_search!(query:, max_results:)

      expect(results).to be_an(Array)
      expect(results.size).to eq(2)
      expect(results.first.to_json).to be_json_as(
        title: "Example Search Result 1",
        url: "https://example.com/result1",
        content: "This is the content of the first search result.",
        related_content: [
          title: "Related Link 1",
          url: "https://example.com/related1",
        ],
      )
    end

    context "when API returns more results than max_results" do
      let(:response_body) do
        {
          results: [
            { title: "Result 1", url: "https://example.com/1", content: "Content 1",
              related_content: [], },
            { title: "Result 2", url: "https://example.com/2", content: "Content 2",
              related_content: [], },
            { title: "Result 3", url: "https://example.com/3", content: "Content 3",
              related_content: [], },
            { title: "Result 4", url: "https://example.com/4", content: "Content 4",
              related_content: [], },
          ],
        }.to_json
      end

      it "limits results to the specified max_results" do
        results = gateway.process_web_search!(query:, max_results: 2)

        expect(results.map { it["title"] }).to eq(["Result 1", "Result 2"])
      end
    end

    context "when the API request fails" do
      let(:response_status) { 500 }
      let(:response_body) { "Internal Server Error" }

      it "raises an HTTPError" do
        expect { gateway.process_web_search!(query:, max_results:) }
          .to raise_error(Adapters::OllamaGateway::HTTPError, "Error: HTTP 500 - Internal Server Error")
      end
    end

    context "when the API response is invalid JSON" do
      let(:response_body) { "{invalid json}" }

      it "raises a JSON::ParserError" do
        expect { gateway.process_web_search!(query:, max_results:) }.to raise_error(JSON::ParserError)
      end
    end

    context "when the request times out" do
      before { stub_request(:post, "https://ollama.com/api/web_search").to_timeout }

      it "raises an HTTPError for timeout" do
        expect { gateway.process_web_search!(query:, max_results:) }
          .to raise_error(Adapters::OllamaGateway::HTTPError, /HTTP Timeout/)
      end
    end
  end

  describe ".process_web_fetch!" do
    let(:web_action) { "web_fetch" }
    let(:response_body) { data[:fetch_response] }

    let(:result) { gateway.process_web_fetch!(url:) }

    it "makes a POST request to the Ollama API with the correct parameters" do
      gateway.process_web_fetch!(url:)

      expect(requests.size).to eq(1)

      expect(request.uri.to_s).to eq("https://ollama.com:443/api/web_fetch")
      expect(request.body).to be_json_as(url: "https://example.com")
      expect(request.headers["Authorization"]).to eq("Bearer test-api-key")
      expect(request.headers["Content-Type"]).to eq("application/json")
    end

    it "returns a raw fetch result on success" do
      result = gateway.process_web_fetch!(url:)

      expect(result).to be_a(Hash)
      expect(result.to_json).to be_json_as(
        title: "Example Web Page",
        url: "https://example.com",
        content: "This is the main content of the fetched web page.",
        related_content: [
          {
            title: "Home Page",
            url: "https://example.com",
          },
          {
            title: "About Us",
            url: "https://example.com/about",
          },
        ],
      )
    end

    context "when the API request fails" do
      let(:response_status) { 404 }
      let(:response_body) { "Not Found" }

      it "raises an HTTPError" do
        expect { gateway.process_web_fetch!(url:) }
          .to raise_error(Adapters::OllamaGateway::HTTPError, "Error: HTTP 404 - Not Found")
      end
    end

    context "when the API response is invalid JSON" do
      let(:response_body) { "{invalid json}" }

      it "raises a JSON::ParserError" do
        expect { gateway.process_web_fetch!(url:) }.to raise_error(JSON::ParserError)
      end
    end

    context "when the request times out" do
      before { stub_request(:post, "https://ollama.com/api/web_fetch").to_timeout }

      it "raises an HTTPError for timeout" do
        expect { gateway.process_web_fetch!(url:) }
          .to raise_error(Adapters::OllamaGateway::HTTPError, /HTTP Timeout/)
      end
    end
  end
end
