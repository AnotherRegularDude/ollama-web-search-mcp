# frozen_string_literal: true

describe Cases::Formatter::SearchResults do
  subject(:result) { run! }

  def run!
    described_class.call!(results, query:, options: options || {})
  end

  let(:query) { "test query" }

  let(:results) do
    [
      Entities::RemoteContent.new(
        title: "Ruby Programming",
        url: "https://ruby-lang.org",
        content: "Ruby is a dynamic programming language",
        source_type: :search,
      ),
      Entities::RemoteContent.new(
        title: "Ruby on Rails",
        url: "https://rubyonrails.org",
        content: "Rails is a web framework for Ruby",
        source_type: :search,
      ),
    ]
  end

  context "with empty results" do
    let(:results) { [] }
    let(:options) { nil }

    it "returns a no results message in markdown format by default" do
      expect(result).to eq("No results found for query: #{query}")
    end

    # JSON theme has been removed - only Markdown is supported now
  end

  context "with results" do
    let(:options) { nil }

    context "with markdown format" do
      let(:query) { "ruby programming" }

      it "formats search results with query in markdown format by default" do
        expected_output = <<~OUTPUT.chomp
          Search Results — "ruby programming"
          ### [Ruby Programming](https://ruby-lang.org)
          **URL:** https://ruby-lang.org
          **Source:** search
          **Content:**
          ---
          Ruby is a dynamic programming language
          ---
          ### [Ruby on Rails](https://rubyonrails.org)
          **URL:** https://rubyonrails.org
          **Source:** search
          **Content:**
          ---
          Rails is a web framework for Ruby
          ---
        OUTPUT

        expect(result).to eq(expected_output)
      end
    end

    # JSON theme has been removed - only Markdown is supported now

    context "with very long query strings" do
      let(:long_query) { "A" * 100 }
      let(:query) { long_query }
      let(:results) do
        [
          Entities::RemoteContent.new(
            title: "Test Result",
            url: "https://example.com",
            content: "Test content",
            source_type: :search,
          ),
        ]
      end

      it "handles very long query strings" do
        expect(result).to include(long_query)
        expect(result).to include("Test Result")
      end
    end

    context "with results containing empty titles or URLs" do
      let(:results) do
        [
          Entities::RemoteContent.new(
            title: "",
            url: "https://example.com",
            content: "Content with empty title",
            source_type: :search,
          ),
          Entities::RemoteContent.new(
            title: "Normal Title",
            url: "",
            content: "Content with empty URL",
            source_type: :search,
          ),
        ]
      end

      it "handles empty titles and URLs" do
        expect(result).to include("Content with empty title")
        expect(result).to include("Content with empty URL")
      end
    end

    context "with mixed source types in results" do
      let(:results) do
        [
          Entities::RemoteContent.new(
            title: "Search Result",
            url: "https://example1.com",
            content: "Search content",
            source_type: :search,
          ),
          Entities::RemoteContent.new(
            title: "Fetch Result",
            url: "https://example2.com",
            content: "Fetch content",
            source_type: :fetch,
          ),
        ]
      end

      it "handles mixed source types correctly" do
        expect(result).to include("Search Result")
        expect(result).to include("Fetch Result")
        expect(result).to include("search")
        expect(result).to include("fetch")
      end
    end

    context "with unicode characters in query and content" do
      let(:query) { "Unicode query: 你好 🌟" }
      let(:results) do
        [
          Entities::RemoteContent.new(
            title: "Unicode Title: 你好",
            url: "https://example.com",
            content: "Unicode content: 🌟🎉",
            source_type: :search,
          ),
        ]
      end

      it "handles unicode characters correctly" do
        expect(result).to include("Unicode query: 你好 🌟")
        expect(result).to include("Unicode Title: 你好")
        expect(result).to include("Unicode content: 🌟🎉")
      end
    end

    context "when render service fails" do
      before { allow(Cases::Node::RenderMarkdown).to receive(:call).and_return(render_response) }

      let(:results) do
        [
          Entities::RemoteContent.new(
            title: "Test Result",
            url: "https://example.com",
            content: "Test content",
            source_type: :search,
          ),
        ]
      end

      let(:render_response) { Resol::Failure.new(Resol::Service::Failure.new(:unknown_node_type, "Unknown node type")) }

      it "handles render service failures" do
        service_result = described_class.call(results, query:, options: {})

        expect(service_result.failure?).to eq(true)
        expect(service_result.error.code).to eq(:unknown_node_type)
        expect(service_result.error.message).to eq(":unknown_node_type => \"Unknown node type\"")
      end
    end
  end
end
