# frozen_string_literal: true

describe Cases::Formatter::SearchResults do
  subject(:result) { run! }

  def run!
    described_class.call!(results, query:, options:)
  end

  let(:query) { "test query" }
  let(:options) { Hash[] }

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

  let(:expected_output) do
    <<~OUTPUT.chomp
      Search Results — "test query"
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
  end

  specify { expect(result).to eq(expected_output) }

  context "with empty results" do
    let(:results) { [] }

    let(:expected_output) do
      <<~OUTPUT.chomp
        No results found for query: #{query}
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with very long query strings" do
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
    let(:query) { "A" * 100 }

    let(:expected_output) do
      <<~OUTPUT.chomp
        Search Results — "#{"A" * 100}"
        ### [Test Result](https://example.com)
        **URL:** https://example.com
        **Source:** search
        **Content:**
        ---
        Test content
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
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

    let(:expected_output) do
      <<~OUTPUT.chomp
        Search Results — "test query"
        ### [](https://example.com)
        **URL:** https://example.com
        **Source:** search
        **Content:**
        ---
        Content with empty title
        ---
        ### [Normal Title]()
        **URL:**#{" "}
        **Source:** search
        **Content:**
        ---
        Content with empty URL
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with empty content in results" do
    let(:results) do
      [
        Entities::RemoteContent.new(
          title: "Empty Content Result",
          url: "https://example.com/empty",
          content: "",
          source_type: :search,
        ),
        Entities::RemoteContent.new(
          title: "Normal Result",
          url: "https://example.com/normal",
          content: "Normal content",
          source_type: :search,
        ),
      ]
    end

    let(:expected_output) do
      <<~OUTPUT.chomp
        Search Results — "test query"
        ### [Empty Content Result](https://example.com/empty)
        **URL:** https://example.com/empty
        **Source:** search
        **Content:**
        ---

        ---
        ### [Normal Result](https://example.com/normal)
        **URL:** https://example.com/normal
        **Source:** search
        **Content:**
        ---
        Normal content
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with very long content and URLs" do
    let(:results) do
      [
        Entities::RemoteContent.new(
          title: "Long Content Result",
          url: long_url,
          content: long_content,
          source_type: :search,
        ),
      ]
    end
    let(:long_url) { "https://example.com/#{"very/" * 50}#{"long/" * 50}path.html" }
    let(:long_content) { "A" * 1000 }

    let(:expected_output) do
      <<~OUTPUT.chomp
        Search Results — "test query"
        ### [Long Content Result](#{long_url})
        **URL:** #{long_url}
        **Source:** search
        **Content:**
        ---
        #{long_content}
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with unicode content and URLs" do
    let(:results) do
      [
        Entities::RemoteContent.new(
          title: "Unicode Result: 你好",
          url: unicode_url,
          content: unicode_content,
          source_type: :search,
        ),
      ]
    end
    let(:unicode_url) { "https://example.com/你好" }
    let(:unicode_content) { "Unicode content: 你好世界 🌟🎉" }

    let(:expected_output) do
      <<~OUTPUT.chomp
        Search Results — "test query"
        ### [Unicode Result: 你好](https://example.com/你好)
        **URL:** https://example.com/你好
        **Source:** search
        **Content:**
        ---
        Unicode content: 你好世界 🌟🎉
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with truncation options" do
    let(:results) do
      [
        Entities::RemoteContent.new(
          title: "Truncated Result",
          url: "https://example.com",
          content: long_content,
          source_type: :search,
        ),
      ]
    end
    let(:long_content) { "A" * 200 }
    let(:options) { Hash[max_chars: 200, truncate: true] }

    let(:expected_output) do
      <<~OUTPUT.chomp
        Search Results — "test query"
        ### [Truncated Result](https://example.com)
        **URL:** https://example.com
        **Source:** search
        **Content:**
        ---
        #{"A" * 57}
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with max_chars: nil and truncate: true" do
    let(:results) do
      [
        Entities::RemoteContent.new(
          title: "Test Result",
          url: "https://example.com",
          content: long_content,
          source_type: :search,
        ),
      ]
    end
    let(:long_content) { "A" * 1000 }
    let(:options) { Hash[max_chars: nil, truncate: true] }

    let(:expected_output) do
      <<~OUTPUT.chomp
        Search Results — "test query"
        ### [Test Result](https://example.com)
        **URL:** https://example.com
        **Source:** search
        **Content:**
        ---
        #{long_content}
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with truncate: false" do
    let(:results) do
      [
        Entities::RemoteContent.new(
          title: "Test Result",
          url: "https://example.com",
          content: long_content,
          source_type: :search,
        ),
      ]
    end
    let(:long_content) { "A" * 1000 }
    let(:options) { Hash[truncate: false] }

    let(:expected_output) do
      <<~OUTPUT.chomp
        Search Results — "test query"
        ### [Test Result](https://example.com)
        **URL:** https://example.com
        **Source:** search
        **Content:**
        ---
        #{long_content}
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
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

    let(:expected_output) do
      <<~OUTPUT.chomp
        Search Results — "test query"
        ### [Search Result](https://example1.com)
        **URL:** https://example1.com
        **Source:** search
        **Content:**
        ---
        Search content
        ---
        ### [Fetch Result](https://example2.com)
        **URL:** https://example2.com
        **Source:** fetch
        **Content:**
        ---
        Fetch content
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
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

    let(:expected_output) do
      <<~OUTPUT.chomp
        Search Results — "Unicode query: 你好 🌟"
        ### [Unicode Title: 你好](https://example.com)
        **URL:** https://example.com
        **Source:** search
        **Content:**
        ---
        Unicode content: 🌟🎉
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
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

    it "fails with service failure data" do
      service_result = described_class.call(results, query:, options: {})
      expect(service_result.failure?).to eq(true)
      expect(service_result.error.code).to eq(:unknown_node_type)
      expect(service_result.error.message).to eq(":unknown_node_type => \"Unknown node type\"")
    end
  end
end
