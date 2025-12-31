# frozen_string_literal: true

describe Cases::Formatter::FetchResult do
  subject(:result) { run! }

  def run!
    described_class.call!(result_content)
  end

  let(:url) { "https://example.com" }
  let(:content) { "Example content for testing" }
  let(:related_links) { ["https://example.com/related1", "https://example.com/related2"] }

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

  context "with URL containing special characters" do
    let(:result_content) do
      Entities::RemoteContent.new(
        title: "Special URL Page",
        url: "https://example.com/path?query=value&other=test#fragment",
        content: "Content with special URL",
        related_content: [],
        source_type: :fetch,
      )
    end

    let(:expected_output) do
      <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com/path?query=value&other=test#fragment
        **Content:**
        ---
        Content with special URL
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end

  context "with very long content and URLs" do
    let(:long_content) { "A" * 1000 }
    let(:long_url) { "https://example.com/#{"very/" * 50}#{"long/" * 50}path.html" }
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
        #{long_content}
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

  context "with options {max_chars: nil, truncate: true}" do
    def run!
      described_class.call!(result_content, options: { max_chars: nil, truncate: true })
    end

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

    let(:expected_output) do
      <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com
        **Content:**
        ---
        #{long_content}
        ---
      OUTPUT
    end

    specify { expect(result).to eq(expected_output) }
  end
end
