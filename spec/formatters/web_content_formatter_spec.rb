# frozen_string_literal: true

describe Formatters::WebContentFormatter do
  subject(:formatter) { described_class.new }

  let(:remote_content_class) { Entities::RemoteContent }
  let(:content_pointer_class) { Value::ContentPointer }

  describe "#format" do
    context "with complete content in standard format" do
      let(:fetch_result) do
        remote_content_class.new(
          title: "Example Domain",
          url: "https://example.com",
          content: "This domain is for use in illustrative examples",
          related_content: [
            content_pointer_class.new(link: "https://example.com/more"),
            content_pointer_class.new(link: "https://example.com/docs"),
            content_pointer_class.new(link: "https://example.com/about"),
          ],
          source_type: :fetch,
        )
      end

      it "formats web content with structured output" do
        formatted_result = formatter.format(fetch_result)
        expected = <<~OUTPUT.chomp
          ## Example Domain
          **URL:** https://example.com
          **Source type:** fetch

          ### Content Preview (48 chars)
          This domain is for use in illustrative examples
          [... Content truncated. Use `include_full_content: true` to see full content ...]

          ### Links
          - **Main URL:** https://example.com
          - **Related links (3):**
            [https://example.com/more](https://example.com/more) | [https://example.com/docs](https://example.com/docs) | [https://example.com/about](https://example.com/about)
        OUTPUT

        expect(formatted_result).to eq(expected)
      end
    end

    context "with long content in standard format" do
      let(:long_content) { "This is a long content. " * 100 }
      let(:fetch_result) do
        remote_content_class.new(
          title: "Long Content Page",
          url: "https://example.com/long",
          content: long_content,
          related_content: [],
          source_type: :fetch,
        )
      end

      it "truncates long content with preview" do
        formatted_result = formatter.format(fetch_result)
        expect(formatted_result).to include("### Content Preview (1000 chars)")
        expect(formatted_result).to include("[... Content truncated.")
        expect(formatted_result).not_to include(long_content)
      end
    end

    context "with full content option" do
      let(:fetch_result) do
        remote_content_class.new(
          title: "Example Domain",
          url: "https://example.com",
          content: "This domain is for use in illustrative examples",
          related_content: [],
          source_type: :fetch,
        )
      end

      it "includes full content when requested" do
        formatted_result = formatter.format(fetch_result, include_full_content: true)
        expected = <<~OUTPUT.chomp
          ## Example Domain
          **URL:** https://example.com
          **Source type:** fetch

          ### Full Content
          This domain is for use in illustrative examples

          ### Links
          - **Main URL:** https://example.com
        OUTPUT

        expect(formatted_result).to eq(expected)
      end
    end

    context "with empty content" do
      let(:fetch_result) do
        remote_content_class.new(
          title: "Empty Page",
          url: "https://example.com/empty",
          content: "",
          related_content: [],
          source_type: :fetch,
        )
      end

      it "formats web content without content section" do
        formatted_result = formatter.format(fetch_result)
        expected = <<~OUTPUT.chomp
          ## Empty Page
          **URL:** https://example.com/empty
          **Source type:** fetch

          ### Links
          - **Main URL:** https://example.com/empty
        OUTPUT

        expect(formatted_result).to eq(expected)
      end
    end

    context "with links disabled" do
      let(:fetch_result) do
        remote_content_class.new(
          title: "Example Domain",
          url: "https://example.com",
          content: "This domain is for use in illustrative examples",
          related_content: [
            content_pointer_class.new(link: "https://example.com/more"),
          ],
          source_type: :fetch,
        )
      end

      it "formats web content without links section when disabled" do
        formatted_result = formatter.format(fetch_result, include_links: false)
        expected = <<~OUTPUT.chomp
          ## Example Domain
          **URL:** https://example.com
          **Source type:** fetch

          ### Content Preview (48 chars)
          This domain is for use in illustrative examples
          [... Content truncated. Use `include_full_content: true` to see full content ...]
        OUTPUT

        expect(formatted_result).to eq(expected)
      end
    end

    context "with compact format" do
      let(:fetch_result) do
        remote_content_class.new(
          title: "Example Domain",
          url: "https://example.com",
          content: "This domain is for use in illustrative examples",
          related_content: [
            content_pointer_class.new(link: "https://example.com/more"),
          ],
          source_type: :fetch,
        )
      end

      it "formats web content in compact format" do
        formatted_result = formatter.format(fetch_result, compact: true)
        expected = <<~OUTPUT.chomp
          === Example Domain ===
          URL: https://example.com
          Preview: This domain is for use in illustrative examples...
          Links: 1 related
        OUTPUT

        expect(formatted_result).to eq(expected)
      end
    end

    context "with custom content preview length" do
      let(:fetch_result) do
        remote_content_class.new(
          title: "Example Domain",
          url: "https://example.com",
          content: "This domain is for use in illustrative examples with more content",
          related_content: [],
          source_type: :fetch,
        )
      end

      it "uses custom content preview length" do
        formatted_result = formatter.format(fetch_result, content_preview_length: 30)
        expect(formatted_result).to include("### Content Preview (30 chars)")
        expect(formatted_result).to include("This domain is for use...")
      end
    end
  end
end
