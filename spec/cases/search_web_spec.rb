# frozen_string_literal: true

require "json"

describe Cases::SearchWeb do
  include_context "ollama request context"

  def run
    described_class.call(query, **{ max_results: }.compact)
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
    expect(first.title).to eq("Example Search Result 1")
    expect(first.url).to eq("https://example.com/result1")
    expect(first.content).to eq("This is the content of the first search result.")

    expect(requests.size).to eq(1)
    expect(requests.first.body).to be_json_as({ query: "mars mission", max_results: 2 })
  end

  context "without max_results" do
    let(:query) { "default count" }
    let(:max_results) { nil }

    it "falls back to default max results" do
      run!

      expect(requests.size).to eq(1)
      expect(requests.first.body).to be_json_as({ query: "default count", max_results: 5 })
    end
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

  context "when testing formatter output" do
    def run_formatter(options = {})
      Cases::Formatter::SearchResults.call(run!, query:, options:)
    end

    # JSON theme has been removed - only Markdown is supported now

    it "formats results correctly for Markdown theme" do
      result = run_formatter(theme: "markdown")
      output = result.value!

      expect(output).to include("Search Results")
      expect(output).to include("mars mission")
      expect(output).to include("Example Search Result 1")
      expect(output).to include("https://example.com/result1")
      expect(output).to include("This is the content of the first search result.")
    end
  end

  context "when testing truncation options" do
    let(:long_content) { "A" * 150_000 }
    let(:response_body) do
      {
        results: [
          {
            title: "Long Content Result",
            url: "https://example.com/long",
            content: long_content,
            related_content: [],
          },
        ],
      }.to_json
    end

    it "truncates content when it exceeds max_chars limit" do
      # When content is too large to fit within max_chars, it should be truncated
      result = Cases::Formatter::SearchResults.call(
        run!,
        query:,
        options: { max_chars: 120_000 },
      )
      expect(result).to be_success

      # The output should be shorter than the original content
      output = result.value!
      expect(output.length).to be < 150_000
      expect(output).to include("Long Content Result")
      expect(output).to include("https://example.com/long")
    end

    it "does not truncate when truncate option is false" do
      result = Cases::Formatter::SearchResults.call(
        run!,
        query:,
        options: { truncate: false },
      )
      output = result.value!

      # With truncate: false, content should not be truncated
      expect(output).to include("A" * 150_000)
    end
  end
end
