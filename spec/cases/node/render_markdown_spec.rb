# frozen_string_literal: true

describe Cases::Node::RenderMarkdown do
  let(:query) { "test query" }

  context "when rendering a search root node" do
    let(:header_text) { "Search Results — \"test query\"" }
    let(:header_node) { Value::Node.new(type: :header, data: { text: header_text }) }

    let(:first_result_title) { "Example Website 1" }
    let(:first_result_url) { "https://example1.com" }
    let(:first_result_source) { :search }
    let(:first_result_content_text) { "This is the content of the first result." }
    let(:first_result_content_node) { Value::Node.new(type: :content, data: { text: first_result_content_text }) }
    let(:first_result_node) do
      Value::Node.new(
        type: :result,
        data: { title: first_result_title, url: first_result_url, source: first_result_source },
        children: [first_result_content_node],
      )
    end

    let(:second_result_title) { "Example Website 2" }
    let(:second_result_url) { "https://example2.com" }
    let(:second_result_source) { :search }
    let(:second_result_content_text) { "This is the content of the second result." }
    let(:second_result_content_node) { Value::Node.new(type: :content, data: { text: second_result_content_text }) }
    let(:second_result_node) do
      Value::Node.new(
        type: :result,
        data: { title: second_result_title, url: second_result_url, source: second_result_source },
        children: [second_result_content_node],
      )
    end

    let(:root_node) do
      Value::RootNode.new(
        metadata: {},
        children: [header_node, first_result_node, second_result_node],
      )
    end

    it "renders search results as Markdown" do
      result = described_class.call(root_node)

      expect(result).to be_success

      expected_output = <<~MARKDOWN.chomp
        #{header_text}
        ### [#{first_result_title}](#{first_result_url})
        **URL:** #{first_result_url}
        **Source:** #{first_result_source}
        **Content:**
        ---
        #{first_result_content_text}
        ---
        ### [#{second_result_title}](#{second_result_url})
        **URL:** #{second_result_url}
        **Source:** #{second_result_source}
        **Content:**
        ---
        #{second_result_content_text}
        ---
      MARKDOWN

      expect(result.value!).to eq(expected_output)
    end
  end

  context "when rendering a fetch root node" do
    let(:url) { "https://example.com/page" }
    let(:source) { :fetch }
    let(:content_text) { "This is the fetched content." }
    let(:content_node) { Value::Node.new(type: :content, data: { text: content_text }) }

    let(:first_link) { "https://example.com/related1" }
    let(:second_link) { "https://example.com/related2" }
    let(:links_data) { [first_link, second_link] }
    let(:links_node) { Value::Node.new(type: :links, data: { links: links_data }) }

    let(:metadata_node) { Value::Node.new(type: :metadata, data: { url:, source: }) }

    let(:root_node) do
      Value::RootNode.new(
        metadata: {},
        children: [metadata_node, content_node, links_node],
      )
    end

    it "renders fetched content as Markdown" do
      result = described_class.call(root_node)

      expect(result).to be_success

      expected_output = <<~MARKDOWN.chomp
        **Source:** #{source}
        **URL:** #{url}
        **Content:**
        ---
        #{content_text}
        ---
        **Links:**
        - [#{first_link}](#{first_link})
        - [#{second_link}](#{second_link})
      MARKDOWN

      expect(result.value!).to eq(expected_output)
    end

    context "when there are no links" do
      let(:links_data) { [] }

      it "renders links section with None" do
        result = described_class.call(root_node)

        expect(result).to be_success

        expected_output = <<~MARKDOWN.chomp
          **Source:** #{source}
          **URL:** #{url}
          **Content:**
          ---
          #{content_text}
          ---
          **Links:**
          - None
        MARKDOWN

        expect(result.value!).to eq(expected_output)
      end
    end
  end

  context "when rendering header node" do
    let(:header_text) { "Test Header" }
    let(:header_node) do
      Value::Node.new(type: :header, data: { text: header_text })
    end

    let(:root_node) do
      Value::RootNode.new(
        metadata: {},
        children: [header_node],
      )
    end

    it "renders header as plain text" do
      result = described_class.call(root_node)

      expect(result).to be_success
      expect(result.value!).to eq("Test Header")
    end
  end

  context "when rendering result node" do
    let(:title) { "Test Result" }
    let(:url) { "https://example.com" }
    let(:source) { :search }
    let(:content_text) { "Result content" }
    let(:content_node) { Value::Node.new(type: :content, data: { text: content_text }) }
    let(:result_node) do
      Value::Node.new(
        type: :result,
        data: { title:, url:, source: },
        children: [content_node],
      )
    end

    let(:root_node) do
      Value::RootNode.new(
        metadata: {},
        children: [result_node],
      )
    end

    it "renders result as Markdown" do
      result = described_class.call(root_node)

      expect(result).to be_success

      expected_output = <<~MARKDOWN.chomp
        ### [#{title}](#{url})
        **URL:** #{url}
        **Source:** #{source}
        **Content:**
        ---
        #{content_text}
        ---
      MARKDOWN

      expect(result.value!).to eq(expected_output)
    end

    context "when result has no content child" do
      let(:result_node) do
        Value::Node.new(
          type: :result,
          data: { title:, url:, source: },
          children: [],
        )
      end

      it "renders result without content section" do
        result = described_class.call(root_node)

        expect(result).to be_success

        expected_output = <<~MARKDOWN.chomp
          ### [#{title}](#{url})
          **URL:** #{url}
          **Source:** #{source}
        MARKDOWN

        expect(result.value!).to eq(expected_output)
      end
    end
  end

  context "when rendering metadata node" do
    let(:url) { "https://example.com" }
    let(:source) { :fetch }
    let(:metadata_node) do
      Value::Node.new(type: :metadata, data: { url:, source: })
    end

    let(:root_node) do
      Value::RootNode.new(
        metadata: {},
        children: [metadata_node],
      )
    end

    it "renders metadata as Markdown" do
      result = described_class.call(root_node)

      expect(result).to be_success

      expected_output = <<~MARKDOWN.chomp
        **Source:** #{source}
        **URL:** #{url}
      MARKDOWN

      expect(result.value!).to eq(expected_output)
    end
  end

  context "when rendering content node" do
    let(:content_text) { "This is content" }
    let(:content_node) do
      Value::Node.new(type: :content, data: { text: content_text })
    end

    let(:root_node) do
      Value::RootNode.new(
        metadata: {},
        children: [content_node],
      )
    end

    it "renders content with proper formatting" do
      result = described_class.call(root_node)

      expect(result).to be_success

      expected_output = <<~MARKDOWN.chomp
        **Content:**
        ---
        #{content_text}
        ---
      MARKDOWN

      expect(result.value!).to eq(expected_output)
    end
  end

  context "when rendering links node" do
    let(:first_link) { "https://example1.com" }
    let(:second_link) { "https://example2.com" }
    let(:links) { [first_link, second_link] }
    let(:links_node) do
      Value::Node.new(type: :links, data: { links: })
    end

    let(:root_node) do
      Value::RootNode.new(
        metadata: {},
        children: [links_node],
      )
    end

    it "renders links as Markdown list" do
      result = described_class.call(root_node)

      expect(result).to be_success

      expected_output = <<~MARKDOWN.chomp
        **Links:**
        - [#{first_link}](#{first_link})
        - [#{second_link}](#{second_link})
      MARKDOWN

      expect(result.value!).to eq(expected_output)
    end

    context "when there are no links" do
      let(:links) { [] }

      it "renders empty links section" do
        result = described_class.call(root_node)

        expect(result).to be_success

        expected_output = <<~MARKDOWN.chomp
          **Links:**
          - None
        MARKDOWN

        expect(result.value!).to eq(expected_output)
      end
    end
  end

  context "when rendering unknown node type" do
    let(:unknown_node) do
      Value::Node.new(type: :unknown, data: { custom_data: "value" })
    end

    let(:root_node) do
      Value::RootNode.new(
        metadata: {},
        children: [unknown_node],
      )
    end

    it "returns an error for unknown node types" do
      result = described_class.call(root_node)

      expect(result).to be_failure
      expect(result.error.code).to eq(:unknown_node_type)
      expect(result.error.data).to include("Unknown node type: unknown")
    end
  end

  context "when rendering with very long content" do
    let(:long_content) { "A" * 1000 }
    let(:content_node) { Value::Node.new(type: :content, data: { text: long_content }) }
    let(:result_node) do
      Value::Node.new(
        type: :result,
        data: { title: "Long Content", url: "https://example.com", source: :search },
        children: [content_node],
      )
    end
    let(:root_node) do
      Value::RootNode.new(
        metadata: {},
        children: [result_node],
      )
    end

    it "handles very long content without truncation" do
      result = described_class.call(root_node)
      expect(result).to be_success
      expect(result.value!.length).to be > 500
      expect(result.value!).to include("A" * 1000)
    end
  end

  context "when rendering multiple content nodes" do
    let(:first_content) { "First content" }
    let(:second_content) { "Second content" }
    let(:first_content_node) { Value::Node.new(type: :content, data: { text: first_content }) }
    let(:second_content_node) { Value::Node.new(type: :content, data: { text: second_content }) }
    let(:result_node) do
      Value::Node.new(
        type: :result,
        data: { title: "Multi Content", url: "https://example.com", source: :search },
        children: [first_content_node, second_content_node],
      )
    end
    let(:root_node) do
      Value::RootNode.new(
        metadata: {},
        children: [result_node],
      )
    end

    it "renders multiple content nodes in sequence" do
      result = described_class.call(root_node)
      expect(result).to be_success
      expect(result.value!).to include("First content")
      expect(result.value!).to include("Second content")
    end
  end
end
