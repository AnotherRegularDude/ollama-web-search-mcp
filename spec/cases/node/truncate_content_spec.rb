# frozen_string_literal: true

describe Cases::Node::TruncateContent do
  def run!
    described_class.call!(root_node, **{ remaining_length: }.compact)
  end

  let(:text1) { "This is some content".dup }
  let(:text2) { "This is more content".dup }
  let(:content_node1) { Value::Node.new(type: :content, data: { text: text1 }) }
  let(:content_node2) { Value::Node.new(type: :content, data: { text: text2 }) }
  let(:root_node) do
    Value::RootNode.new(metadata: {}, children: [content_node1, content_node2])
  end

  let(:remaining_length) { 1_000 }

  it "returns success without modifying nodes" do
    run!

    expect(content_node1.data[:text]).to eq("This is some content")
    expect(content_node2.data[:text]).to eq("This is more content")
  end

  context "when there are no content nodes" do
    let(:header_node) { Value::Node.new(type: :header, data: { text: "Header" }) }
    let(:root_node) { Value::RootNode.new(metadata: {}, children: [header_node]) }

    let(:remaining_length) { 100 }

    it "returns success without errors" do
      expect { run! }.not_to raise_error
    end
  end

  context "when truncation is needed" do
    let(:text1) { ("A" * 100) }
    let(:text2) { ("B" * 60) }
    let(:text3) { ("C" * 80) }
    let(:content_node3) { Value::Node.new(type: :content, data: { text: text3 }) }
    let(:root_node) do
      Value::RootNode.new(metadata: {}, children: [content_node1, content_node2, content_node3])
    end

    let(:remaining_length) { 150 }

    it "truncates content evenly using water-filling algorithm" do
      # With a budget of 150, we should get:
      # 1. Fair share = 150/3 = 50
      # 2. content1: min(50, 100) = 50, remaining = 100
      # 3. content2: min(100/2, 60) = 50, remaining = 50
      # 4. content3: min(50/1, 80) = 50
      run!

      expect(content_node1.data[:text].length).to eq(50)
      expect(content_node2.data[:text].length).to eq(50)
      expect(content_node3.data[:text].length).to eq(50)
    end
  end

  context "when remaining_length is 0" do
    let(:text1) { "This is some content".dup }
    let(:text2) { "This is more content".dup }

    let(:remaining_length) { 0 }

    it "responses with token limit error" do
      expect { run! }.to raise_error(described_class::Failure, /:small_token_limit/)

      expect(content_node1.data[:text]).to eq("This is some content")
      expect(content_node2.data[:text]).to eq("This is more content")
    end
  end

  context "when remaining_length is negative" do
    let(:remaining_length) { -150 }

    let(:error_message) { ":small_token_limit => \"Token limit smaller than empty layout size\"" }

    it "raises small token limit error" do
      expect { run! }.to raise_error(described_class::Failure, error_message)
    end
  end

  context "when content contains unicode characters" do
    let(:text1) { "Unicode content: 你好世界 🌟" * 10 }
    let(:text2) { "More unicode: 🎉🎊" * 5 }
    let(:remaining_length) { 10 }

    it "handles unicode characters correctly" do
      expect { run! }.not_to raise_error
    end
  end
end
