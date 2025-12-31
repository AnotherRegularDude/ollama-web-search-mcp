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

  context "with content and links" do
    it "formats web fetch results with metadata, content, and links in markdown format by default" do
      expected_output = <<~OUTPUT.chomp
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

      expect(result).to eq(expected_output)
    end

    # JSON theme has been removed - only Markdown is supported now
  end

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

    it "returns a no content message in markdown format by default" do
      expected_output = <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com
        No content found for URL: #{url}
      OUTPUT
      expect(result).to eq(expected_output)
    end

    # JSON theme has been removed - only Markdown is supported now
  end

  context "with content but no links" do
    let(:result_content) do
      Entities::RemoteContent.new(
        title: "Content Only Page",
        url:,
        content:,
        related_content: [],
        source_type: :fetch,
      )
    end

    it "formats web fetch results with metadata and content only in markdown format" do
      expected_output = <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com
        **Content:**
        ---
        Example content for testing
        ---
      OUTPUT

      expect(result).to eq(expected_output)
    end

    # JSON theme has been removed - only Markdown is supported now
  end

  context "with empty content but valid links" do
    let(:result_content) do
      Entities::RemoteContent.new(
        title: "Links Only Page",
        url:,
        content: "",
        related_content: related_links.map { |link| Value::ContentPointer.new(link:) },
        source_type: :fetch,
      )
    end

    it "formats web fetch results with metadata and links when content is empty but links are present" do
      expected_output = <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com
        **Links:**
        - [https://example.com/related1](https://example.com/related1)
        - [https://example.com/related2](https://example.com/related2)
      OUTPUT

      expect(result).to eq(expected_output)
    end

    # JSON theme has been removed - only Markdown is supported now
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

    it "handles URLs with query parameters and fragments correctly in markdown format" do
      expected_output = <<~OUTPUT.chomp
        **Source:** fetch
        **URL:** https://example.com/path?query=value&other=test#fragment
        **Content:**
        ---
        Content with special URL
        ---
      OUTPUT

      expect(result).to eq(expected_output)
    end

    # JSON theme has been removed - only Markdown is supported now
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

    it "handles very long content and URLs without truncation" do
      expect(result.length).to be > 500
      expect(result).to include(long_content)
      expect(result).to include(long_url)
    end
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

    it "handles unicode content and URLs correctly" do
      expect(result).to include("你好世界 🌟🎉")
      expect(result).to include("https://example.com/你好")
    end
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

    it "handles duplicate URLs in related content" do
      expect(result).to include("https://example.com/same")
      expect(result).to include("https://example.com/different")
    end
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

    it "uses default max_chars value when nil is passed" do
      expect(result).to include(long_content)
      expect(result.length).to be > 500
    end
  end
end
