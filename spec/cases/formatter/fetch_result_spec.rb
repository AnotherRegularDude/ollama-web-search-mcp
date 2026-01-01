# frozen_string_literal: true

describe Cases::Formatter::FetchResult do
  def run!
    described_class.call!(result_content, options:)
  end

  before { stub_const("Cases::Formatter::Base::DEFAULT_OPTIONS", { truncate: true, max_chars: 999 }) }

  subject(:result) { run! }

  let(:url) { "https://example.com" }
  let(:content) { "Example content for testing" }
  let(:related_links) { ["https://example.com/related1", "https://example.com/related2"] }
  let(:options) { Hash[] }

  let(:result_content) do
    Entities::RemoteContent.new(
      title: "Example Page",
      url:,
      content:,
      related_content: related_links.map { |link| Value::ContentPointer.new(link:) },
      source_type: :fetch,
    )
  end

  let(:expected_output) do
    <<~OUTPUT.chomp
      **Source:** fetch
      **URL:** https://example.com
      **Content:**
      ---
      Example content for testing
      ---
      **Links:**
      - [https://example.com/related1](https://example.com/related1)
      - [https://example.com/related2](https://example.com/related2)
    OUTPUT
  end

  specify { expect(result).to eq(expected_output) }

  context "with empty content" do
    let(:result_content) do
      Entities::RemoteContent.new(
        title: "Empty Content Page",
        url:,
        content: "",
        related_content: [],
        source_type: :fetch,
      )
    end

    let(:expected_output) do
      <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com
        No content found for URL: #{url}
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "without links" do
    let(:result_content) do
      Entities::RemoteContent.new(
        title: "Content Only Page",
        url:,
        content:,
        related_content: [],
        source_type: :fetch,
      )
    end

    let(:expected_output) do
      <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com
        **Content:**
        ---
        Example content for testing
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with only links" do
    let(:result_content) do
      Entities::RemoteContent.new(
        title: "Links Only Page",
        url:,
        content: "",
        related_content: related_links.map { |link| Value::ContentPointer.new(link:) },
        source_type: :fetch,
      )
    end

    let(:expected_output) do
      <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com
        **Links:**
        - [https://example.com/related1](https://example.com/related1)
        - [https://example.com/related2](https://example.com/related2)
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with very long content and URLs" do
    let(:long_url) { "https://example.com/#{"very/" * 50}#{"long/" * 50}path.html" }
    let(:long_content) { "A" * 1_000 }
    let(:result_content) do
      Entities::RemoteContent.new(
        title: "Long Content Page",
        url: long_url,
        content: long_content,
        related_content: [],
        source_type: :fetch,
      )
    end

    let(:expected_output) do
      <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** #{long_url}
        **Content:**
        ---
        #{"A" * 421}
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with unicode content and URLs" do
    let(:unicode_content) { "Unicode content: 你好世界 🌟🎉" }
    let(:unicode_url) { "https://example.com/你好" }
    let(:result_content) do
      Entities::RemoteContent.new(
        title: "Unicode Page",
        url: unicode_url,
        content: unicode_content,
        related_content: [],
        source_type: :fetch,
      )
    end

    let(:expected_output) do
      <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com/你好
        **Content:**
        ---
        Unicode content: 你好世界 🌟🎉
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with multiple related links to same URL" do
    let(:same_url) { "https://example.com/same" }
    let(:result_content) do
      Entities::RemoteContent.new(
        title: "Duplicate Links Page",
        url: "https://example.com",
        content: "Content with duplicate links",
        related_content: [
          Value::ContentPointer.new(link: same_url),
          Value::ContentPointer.new(link: same_url),
          Value::ContentPointer.new(link: "https://example.com/different"),
        ],
        source_type: :fetch,
      )
    end

    let(:expected_output) do
      <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com
        **Content:**
        ---
        Content with duplicate links
        ---
        **Links:**
        - [https://example.com/same](https://example.com/same)
        - [https://example.com/same](https://example.com/same)
        - [https://example.com/different](https://example.com/different)
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with truncation options" do
    let(:result_content) do
      Entities::RemoteContent.new(
        title: "Truncated Result",
        url: "https://example.com",
        content: long_content,
        related_content: [],
        source_type: :fetch,
      )
    end
    let(:long_content) { "A" * 200 }
    let(:options) { Hash[max_chars: 200, truncate: true] }

    let(:expected_output) do
      <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com
        **Content:**
        ---
        #{"A" * 132}
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with max_chars: nil and truncate: true" do
    let(:long_content) { "A" * 1000 }
    let(:result_content) do
      Entities::RemoteContent.new(
        title: "Test Page",
        url: "https://example.com",
        content: long_content,
        related_content: [],
        source_type: :fetch,
      )
    end
    let(:options) { Hash[max_chars: nil, truncate: true] }

    let(:expected_output) do
      <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com
        **Content:**
        ---
        #{"A" * 931}
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with truncate: false" do
    let(:long_content) { "A" * 1_000 }
    let(:result_content) do
      Entities::RemoteContent.new(
        title: "Test Page",
        url: "https://example.com",
        content: long_content,
        related_content: [],
        source_type: :fetch,
      )
    end
    let(:options) { Hash[truncate: false] }

    let(:expected_output) do
      <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com
        **Content:**
        ---
        #{"A" * 1_000}
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end
end
